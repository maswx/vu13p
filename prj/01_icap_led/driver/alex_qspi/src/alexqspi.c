// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2019-2023 The Regents of the University of California
 */

#include <ctype.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <linux/pci.h>

//#include <mqnic/mqnic.h>
#include "bitfile.h"
#include "flash.h"
#include "reg_block.h"

#define reg_read32(reg) (*((volatile uint32_t *)(reg)))
#define reg_write32(reg, val) (*((volatile uint32_t *)(reg))) = (val)



// log by masw@masw.tech 二次开发这仅仅需要关心一下两个变量
#define AXILBUS "/dev/xdma0_user"
#define ALEXQSPI_ADDR 0x00000000 









#define MAX_SEGMENTS 8

uint32_t reverse_bits_32(uint32_t x)
{
    x = ((x & 0x55555555) <<  1) | ((x & 0xAAAAAAAA) >>  1);
    x = ((x & 0x33333333) <<  2) | ((x & 0xCCCCCCCC) >>  2);
    x = ((x & 0x0F0F0F0F) <<  4) | ((x & 0xF0F0F0F0) >>  4);
    x = ((x & 0x00FF00FF) <<  8) | ((x & 0xFF00FF00) >>  8);
    x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16);
    return x;
}

uint16_t reverse_bits_16(uint16_t x)
{
    x = ((x & 0x5555) << 1) | ((x & 0xAAAA) >> 1);
    x = ((x & 0x3333) << 2) | ((x & 0xCCCC) >> 2);
    x = ((x & 0x0F0F) << 4) | ((x & 0xF0F0) >> 4);
    x = ((x & 0x00FF) << 8) | ((x & 0xFF00) >> 8);
    return x;
}

uint8_t reverse_bits_8(uint8_t x)
{
    x = ((x & 0x55) << 1) | ((x & 0xAA) >> 1);
    x = ((x & 0x33) << 2) | ((x & 0xCC) >> 2);
    x = ((x & 0x0F) << 4) | ((x & 0xF0) >> 4);
    return x;
}

char* stristr(const char *str1, const char *str2)
{
    const char* p1 = str1;
    const char* p2 = str2;
    const char* r = *p2 == 0 ? str1 : 0;

    while (*p1 != 0 && *p2 != 0)
    {
        if (tolower(*p1) == tolower(*p2))
        {
            if (r == 0)
            {
                r = p1;
            }

            p2++;
        }
        else
        {
            p2 = str2;
            if (r != 0)
            {
                p1 = r + 1;
            }

            if (tolower(*p1) == tolower(*p2))
            {
                r = p1;
                p2++;
            }
            else
            {
                r = 0;
            }
        }

        p1++;
    }

    return *p2 == 0 ? (char *)r : 0;
}


int flash_read_progress(struct flash_device *fdev, size_t addr, size_t len, void *dest)
{
    int ret = 0;
    size_t remain = len;
    size_t seg;
    int step = 0x10000;

    printf("Start address: 0x%08lx\n", addr);
    printf("Length: 0x%08lx\n", len);

    while (remain > 0)
    {
        if (remain > step)
        {
            // longer than step, trim
            if ((addr + step) & (step-1))
            {
                // align to step size
                seg = step - ((addr + step) & (step-1));
            }
            else
            {
                // already aligned
                seg = step;
            }
        }
        else
        {
            // shorter than step
            seg = remain;
        }

        printf("Read address 0x%08lx, length 0x%08lx (%ld%%)\r", addr, seg, (100*(len-remain))/len);
        fflush(stdout);

        ret = flash_read(fdev, addr, seg, dest);

        if (ret) {
            fprintf(stderr, "\nRead failed\n");
            goto err;
        }

        addr += seg;
        remain -= seg;
        dest += seg;
    }

    printf("\n");

err:
    return ret;
}

int flash_write_progress(struct flash_device *fdev, size_t addr, size_t len, const void *src)
{
    int ret = 0;
    size_t remain = len;
    size_t seg;
    int step = 0x10000;

    printf("Start address: 0x%08lx\n", addr);
    printf("Length: 0x%08lx\n", len);

    step = fdev->write_buffer_size > step ? fdev->write_buffer_size : step;

    while (remain > 0)
    {
        if (remain > step)
        {
            // longer than step, trim
            if ((addr + step) & (step-1))
            {
                // align to step size
                seg = step - ((addr + step) & (step-1));
            }
            else
            {
                // already aligned
                seg = step;
            }
        }
        else
        {
            // shorter than step
            seg = remain;
        }

        printf("Write address 0x%08lx, length 0x%08lx (%ld%%)\r", addr, seg, (100*(len-remain))/len);
        fflush(stdout);

        ret = flash_write(fdev, addr, seg, src);

        if (ret) {
            fprintf(stderr, "\nWrite failed\n");
            goto err;
        }

        addr += seg;
        remain -= seg;
        src += seg;
    }

    printf("\n");

err:
    return ret;
}

int flash_write_verify_progress(struct flash_device *fdev, size_t addr, size_t len, const void *src)
{
    int ret = 0;
    size_t remain = len;
    size_t seg;
    int step = 0x10000;
    const uint8_t *ptr = src;
    uint8_t *check_buf;

    printf("Start address: 0x%08lx\n", addr);
    printf("Length: 0x%08lx\n", len);

    step = fdev->write_buffer_size > step ? fdev->write_buffer_size : step;

    check_buf = calloc(step, 1);

    if (!check_buf)
        return -1;

    while (remain > 0)
    {
        if (remain > step)
        {
            // longer than step, trim
            if ((addr + step) & (step-1))
            {
                // align to step size
                seg = step - ((addr + step) & (step-1));
            }
            else
            {
                // already aligned
                seg = step;
            }
        }
        else
        {
            // shorter than step
            seg = remain;
        }

        printf("Write/verify address 0x%08lx, length 0x%08lx (%ld%%)\r", addr, seg, (100*(len-remain))/len);
        fflush(stdout);

        ret = flash_write(fdev, addr, seg, ptr);

        if (ret) {
            fprintf(stderr, "\nWrite failed\n");
            goto err;
        }

        for (int read_attempts = 3; read_attempts >= 0; read_attempts--)
        {
            ret = flash_read(fdev, addr, seg, check_buf);

            if (ret) {
                fprintf(stderr, "\nRead failed\n");
                goto err;
            }

            if (memcmp(ptr, check_buf, seg))
            {
                fprintf(stderr, "\nVerify failed (%d more attempts)\n", read_attempts);

                for (size_t k = 0; k < seg; k++)
                {
                    if (ptr[k] != check_buf[k])
                    {
                        fprintf(stderr, "flash offset 0x%08lx: expected 0x%02x, read 0x%02x\n",
                            addr+k, ptr[k], check_buf[k]);
                    }
                }

                if (read_attempts > 0)
                    continue;

                ret = -1;
                goto err;
            }
        }

        addr += seg;
        remain -= seg;
        ptr += seg;
    }

    printf("\n");

err:
    free(check_buf);
    return ret;
}

int flash_erase_progress(struct flash_device *fdev, size_t addr, size_t len)
{
    int ret;
    size_t remain = len;
    size_t seg;
    int step = 0x10000;

    printf("Start address: 0x%08lx\n", addr);
    printf("Length: 0x%08lx\n", len);

    step = fdev->erase_block_size > step ? fdev->erase_block_size : step;

    while (remain > 0)
    {
        if (remain > step)
        {
            // longer than step, trim
            if ((addr + step) & (step-1))
            {
                // align to step size
                seg = step - ((addr + step) & (step-1));
            }
            else
            {
                // already aligned
                seg = step;
            }
        }
        else
        {
            // shorter than step
            seg = remain;
        }

        printf("Erase address 0x%08lx, length 0x%08lx (%ld%%)\r", addr, seg, ((100*(len-remain))/len));
        fflush(stdout);

        ret = flash_erase(fdev, addr, seg);

        if (ret)
            return ret;

        addr += seg;
        remain -= seg;
    }

    printf("\n");

    return 0;
}

int write_str_to_file(const char *file_name, const char *str)
{
    int ret = 0;
    FILE *fp = fopen(file_name, "w");

    if (!fp)
    {
        perror("failed to open file");
        return -1;
    }

    if (fputs(str, fp) == EOF)
    {
        perror("failed to write to file");
        ret = -1;
    }

    fclose(fp);
    return ret;
}

int write_1_to_file(const char *file_name)
{
    return write_str_to_file(file_name, "1");
}

#define FILE_TYPE_BIN 0
#define FILE_TYPE_HEX 1
#define FILE_TYPE_BIT 2

int file_type_from_ext(const char *file_name)
{
    char *ptr;
    char buffer[32];

    ptr = strrchr(file_name, '.');

    if (!ptr)
    {
        return FILE_TYPE_BIN;
    }

    ptr++;

    for (int i = 0; i < sizeof(buffer)-1 && *ptr; i++)
    {
        buffer[i] = tolower(*ptr++);
        buffer[i+1] = 0;
    }

    if (strcmp(buffer, "hex") == 0 || strcmp(buffer, "mcs") == 0)
    {
        return FILE_TYPE_HEX;
    }

    if (strcmp(buffer, "bit") == 0)
    {
        return FILE_TYPE_BIT;
    }

    return FILE_TYPE_BIN;
}

int pcie_hot_reset(const char *pci_port_path)
{
    int fd;
    char path[PATH_MAX+32];
    char buf[32];

    snprintf(path, sizeof(path), "%s/config", pci_port_path);

    fd = open(path, O_RDWR);

    if (!fd)
    {
        perror("Failed to open config region of port");
        return -1;
    }

    // set and then clear secondary bus reset bit (mask 0x0040)
    // in the bridge control register (offset 0x3e)
    pread(fd, buf, 2, PCI_BRIDGE_CONTROL);

    buf[2] = buf[0] | PCI_BRIDGE_CTL_BUS_RESET;
    buf[3] = buf[1];

    pwrite(fd, buf+2, 2, PCI_BRIDGE_CONTROL);

    usleep(10000);

    pwrite(fd, buf, 2, PCI_BRIDGE_CONTROL);

    close(fd);

    return 0;
}

int pcie_disable_fatal_err(const char *pci_port_path)
{
    int fd;
    char path[PATH_MAX+32];
    char buf[32];
    int offset;

    snprintf(path, sizeof(path), "%s/config", pci_port_path);

    fd = open(path, O_RDWR);

    if (!fd)
    {
        perror("Failed to open config region of port");
        return -1;
    }

    // clear SERR bit (mask 0x0100) in command register (offset 0x04)
    pread(fd, buf, 2, PCI_COMMAND);

    buf[1] &= ~(PCI_COMMAND_SERR >> 8);

    pwrite(fd, buf, 2, PCI_COMMAND);

    // clear fatal error reporting bit (mask 0x0004) in
    // PCIe capability device control register (offset 0x08)

    // find PCIe capability (ID 0x10)
    pread(fd, buf, 1, PCI_CAPABILITY_LIST);

    offset = buf[0] & 0xfc;

    while (offset > 0)
    {
        pread(fd, buf, 2, offset);

        if (buf[0] == PCI_CAP_ID_EXP)
            break;

        offset = buf[1] & 0xfc;
    }

    // clear bit
    if (offset)
    {
        pread(fd, buf, 2, offset+PCI_EXP_DEVCTL);

        buf[0] &= ~PCI_EXP_DEVCTL_FERE;

        pwrite(fd, buf, 2, offset+PCI_EXP_DEVCTL);
    }

    close(fd);

    return 0;
}
void writeBinaryFile(const char* filename, const void* data, size_t size) {
    FILE* file = fopen(filename, "wb"); // "wb" 表示以二进制写入方式打开文件
    if (file == NULL) {
        perror("Error opening file");
        return;
    }

    size_t elements_written = fwrite(data, 1, size, file);
    if (elements_written != size) {
        perror("Error writing to file");
    }

    fclose(file);
}
//==================================================================================================
//==================================================================================================
//==================================================================================================
//==================================================================================================
//add by masw@masw.tech

int main(int argc, char *argv[])
{
    int    axilte ;
    int    golden_stage1 = 0;
    void  *mapped_base;
    off_t  base_offset  = ALEXQSPI_ADDR ;
    size_t mapping_size = 4 * 1024; // 映射的大小，4K , 最小4k对齐
    struct flash_device *pri_flash = NULL;

	//========================================================================================================================================
    // 读取外部bin文件, 保存到内存中，然后写入flash

    // 读取bin文件
    if (argc < 2) {
        printf("Usage: %s <input file> [bin_filename]\n", argv[0]);
        return -1;
    }
    FILE *fp = fopen(argv[1], "rb");
    if (fp == NULL) {
        printf("open file failed!\n");
        return -1;
    }
    // 获取文件大小
    fseek(fp, 0, SEEK_END);
    size_t size = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    // 读取文件内容
    void *buf = malloc(size);
    char *pri_buf = calloc(0x08000000, 1);
    memset(pri_buf, 0xff, 0x08000000);
    memcpy(pri_buf, buf , size);
    //void *buf = malloc(0x08000000);
    if (buf == NULL) {
        printf("malloc failed!\n");
        fclose(fp);
        return -1;
    }
    fread(buf, 1, size, fp);
    fclose(fp);
    // 这里还需要判断一下外部输入参数的个数
    if(argc == 3){
        // 判定 argv[2] 是否是制定字符串 goldenimage
        if (strcmp(argv[2], "goldenimage") == 0) {
            // 如果是，将buf中的内容写入flash
            printf("Warnning : ------- your will write to golden flash; input string \'yes\' for confirm: \n");
            printf("Warnning : ------- your will write to golden flash; input string \'yes\' for confirm: \n");
            printf("Warnning : ------- your will write to golden flash; input string \'yes\' for confirm: \n");
            // 需要外部输入yes字符串以确认操作
            char confirm[4];
            scanf("%s", confirm);
            if (strcmp(confirm, "yes") != 0) {//如果不是yes
                printf("input string is not \'yes\'; writting to multibool stage!\n");
            }
            else{
                golden_stage1 = 1;
            }
        }
    }

    //========================================================================================================================================
    // 打开设备文件
    axilte = open(AXILBUS , O_RDWR | O_SYNC);//axi lite设备
    if (axilte == -1) {
        perror("Failed to open device");
        close(axilte);
        return -1;
    }
    // 映射设备文件到内存
    mapped_base = mmap(NULL, mapping_size, PROT_READ | PROT_WRITE, MAP_SHARED, axilte, base_offset);
    if (mapped_base == MAP_FAILED) {
        perror("Failed to map memory");
        close(axilte);
        return -1;
    }
	//printf("mapped_base = %016lx\n", (uintptr_t)mapped_base);
    // 将映射的地址转换为指定类型的指针
	//========================================================================================================================================
	struct mqnic_reg_block *flash_rb = (struct mqnic_reg_block *)malloc(sizeof(struct mqnic_reg_block));
	//    uint32_t type         ; --------------> 读回  8'h60: reg_rd_data <= 32'h0000C120;             // SPI flash ctrl: Type
	//    uint32_t version      ; --------------> 读回  8'h64: reg_rd_data <= 32'h00000200;             // SPI flash ctrl: Version
	//    volatile uint8_t *base;
	//    volatile uint8_t *regs; -------------->       8'h70:
	//};
	flash_rb -> base    = (volatile uint8_t *) mapped_base ;
	flash_rb -> regs    = (volatile uint8_t *)(mapped_base + 0x70);
	flash_rb -> type    = reg_read32  (flash_rb -> base + 0x60);
	flash_rb -> version = reg_read32  (flash_rb -> base + 0x64);
	size_t segment_offset   = reg_read32  (flash_rb -> base + 0x6C) & 0xfffff000;
    printf("multiboot stage2 address = 0x%08lx\n", segment_offset);
	//printf("flash_rb -> base    = %016x\n" , flash_rb -> base   );
	//printf("flash_rb -> regs    = %016x\n" , flash_rb -> regs   );
	//printf("flash_rb -> type    = %016x\n" , flash_rb -> type   );
	//printf("flash_rb -> version = %016x\n" , flash_rb -> version);


	//========================================================================================================================================

    pri_flash = flash_open_spi(4, flash_rb -> regs);
	pri_flash -> erase_block_size = 0x08000000;
    // round up length to block size
    //开始写入
    if(golden_stage1 == 1){
		printf("Erasing flash...\n");
    	flash_erase_progress(pri_flash, 0, size);
        printf("Writing to golden flash...\n");
        flash_write_verify_progress(pri_flash, 0, size, buf);
        //flash_write_progress(pri_flash, 0x00000000, size, buf);
		//flash_read_progress(pri_flash, 0, 0x08000000, buf);
		//flash_read_progress(struct flash_device *fdev, size_t addr, size_t len, void *dest)
		//writeBinaryFile("readbak.bin", buf, 0x0800000) ;
    }
    else{
        size += pri_flash -> erase_block_size - (segment_offset + size) ;
		printf("Erasing flash...\n");
    	flash_erase_progress(pri_flash, segment_offset, pri_flash -> erase_block_size);
        printf("Writing to multiboot flash...\n");
        flash_write_verify_progress(pri_flash, segment_offset, size, buf);
        //flash_write_progress(pri_flash, segment_offset, size, buf);
		//flash_read_progress(pri_flash, 0, 0x08000000, buf);
		//flash_read_progress(struct flash_device *fdev, size_t addr, size_t len, void *dest)
		//writeBinaryFile("readbak.bin", buf, 0x0800000) ;
    }


	// 结束咯
    free(buf);
	free(pri_flash);
    return 0;
}




