#include "stdio.h"
#include <assert.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdarg.h>
#include <syslog.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <dirent.h>
#include <string.h>
/* ltoh: little to host */
/* htol: little to host */
#if __BYTE_ORDER == __LITTLE_ENDIAN
#  define ltohl(x)       (x)
#  define ltohs(x)       (x)
#  define htoll(x)       (x)
#  define htols(x)       (x)
#elif __BYTE_ORDER == __BIG_ENDIAN
#  define ltohl(x)     __bswap_32(x)
#  define ltohs(x)     __bswap_16(x)
#  define htoll(x)     __bswap_32(x)
#  define htols(x)     __bswap_16(x)
#endif
 
#define MAP_SIZE (1024*1024UL)
#define MAP_MASK (MAP_SIZE - 1)
 
#define FPGA_AXI_START_ADDR (0)
 
void *control_base;
int control_fd;
int c2h_dma_fd;
int h2c_dma_fd;
 
static unsigned int h2c_fpga_ddr_addr;
static unsigned int c2h_fpga_ddr_addr;
 
 
static int open_control(char *filename)
{
    int fd;
    fd = open(filename, O_RDWR | O_SYNC);
    if(fd == -1)
    {
        printf("open control error\n");
        return -1;
    }
    return fd;
}
static void *mmap_control(int fd,long mapsize)
{
    void *vir_addr;
    vir_addr = mmap(0, mapsize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    return vir_addr;
}
void write_control(int offset,uint32_t val)
{
    uint32_t writeval = htoll(val);
    *((uint32_t *)(control_base+offset)) = writeval;
}
uint32_t read_control(int offset)
{
    uint32_t read_result = *((uint32_t *)(control_base+offset));
    read_result = ltohl(read_result);
    return read_result;
}
 
 
void put_data_to_fpga_ddr(unsigned int fpga_ddr_addr,short int *buffer,unsigned int len)
{
    if(h2c_dma_fd >= 0)
    {
		printf("write data to fpga\n");
        lseek(h2c_dma_fd,fpga_ddr_addr,SEEK_SET);
        write(h2c_dma_fd,buffer,len*2);
    }
}
void get_data_from_fpga_ddr(unsigned int fpga_ddr_addr,short int  *buffer,unsigned int len)
{
    if(c2h_dma_fd >= 0)
    {
		printf("read data from fpga\n");
        lseek(c2h_dma_fd,fpga_ddr_addr,SEEK_SET);
        read(c2h_dma_fd,buffer,len*2);
    }
}
 
int pcie_init()
{
    c2h_dma_fd = open("/dev/xdma0_c2h_0",O_RDONLY);
    if(c2h_dma_fd < 0)
	{
		printf("error in c2h_dma_fd %x\n", c2h_dma_fd);
	}
    h2c_dma_fd = open("/dev/xdma0_h2c_0",O_WRONLY);
    //h2c_dma_fd = open("/dev/xdma0_h2c_0",O_RDONLY);
    if(h2c_dma_fd < 0)
	{
		printf("error in h2c_dma_fd\n");
	}
    control_fd = open_control("/dev/xdma0_control");
    if(control_fd < 0)
	{
		printf("error in ctrl\n");
	}
    control_base = mmap_control(control_fd,MAP_SIZE);
    return 1;
}
void pcie_deinit()
{
    close(c2h_dma_fd);
    close(h2c_dma_fd);
    close(control_fd);
}

int main(void){
	int i=0;
    int len=128;
	short int *bufferin = (short int *)malloc(len*(sizeof(short int)));
	short int *bufferot = (short int *)malloc(len*(sizeof(short int)));
	for(i = 0; i < len;i++)
	{
		bufferin[i] = i;
		bufferot[i] = 0;
	}
    h2c_fpga_ddr_addr = 0xc0000000;
    c2h_fpga_ddr_addr = 0xc0000000;
	printf("fpga_ddr_addr = %x\n", h2c_fpga_ddr_addr);
    printf("c2h_dma_fd = %x\n", c2h_dma_fd);
    printf("h2c_dma_fd = %x\n", h2c_dma_fd);
    printf("control_fd = %x\n", control_fd);
	pcie_init();

	put_data_to_fpga_ddr  (h2c_fpga_ddr_addr,bufferin,len);
	get_data_from_fpga_ddr(c2h_fpga_ddr_addr,bufferot,len);

	for(i = 0; i < len;i++)
		printf("bufferin[%02d]=%d, bufferot[%02d]=%d\n",i,bufferin[i], i,bufferot[i]);

	pcie_deinit();
	free(bufferin);
	free(bufferot);
	return 0;
}




