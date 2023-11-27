/*
Copyright (c) 2017 Sanjay Rai (sanjay.rai@gmail.com) 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <inttypes.h>
#include <fstream>
#include <chrono>
#include "pcie_memio.h" 

using namespace std;

#define PAGE_SIZE (512*1024*1024UL)

/* Address Ranges as defined in VIvado IPI Address map */
/* NOTE: Be aware on any PCIe-AXI Address translation setup on the xDMA/PCIEBridge*/ 
/*       These address translations affect the address shown . THese address are  */
/*       exactly waht is populated on the IPI Address tab                         */
#define DDR4_BASE 0x10000000
#define BRAM_BASE 0x00000000
#define ICAP_BASE 0x00010000

/* Address Offset of various Peripheral Registers */ 
#define ICAP_CNTRL_REG           ICAP_BASE + 0x10C
#define ICAP_STATUS_REG          ICAP_BASE + 0x110
#define ICAP_WR_FIFO_REG         ICAP_BASE + 0x100
#define ICAP_WR_FIFO_VACANCY_REG ICAP_BASE + 0x114

int ICAP_prog_binfile (fpga_mmio *fpga_ICAP, uint32_t *data_buffer, unsigned int binfile_length );
int ICAP_acess (fpga_mmio *fpga_ICAP);
unsigned int AXI_Write (fpga_mmio *fpga_BRAM, uint32_t ADDR_OFFSET);
unsigned int AXI_Read (uint32_t *data_buf, fpga_mmio *fpga_BRAM, uint32_t ADDR_OFFSET);

int main(int argc, char **argv) {

    uint32_t base_address;
    uint32_t base_address_ddr4;
    clock_t elspsed_time;
    uint32_t *data_buf_ptr = new uint32_t [134217728];
    unsigned int xfer_count ;

    fstream fpga_bin_file;

    if (argc != 3) {
        printf("usage: pcie_mmio base_addr fpga_bin_file\n");
        return -1;
    }

    // ------------ Init -----------------------
    fpga_mmio *my_fpga_ptr = new fpga_mmio;
    base_address = strtoll(argv[1], 0, 0);
    

    elspsed_time = clock();
    auto start_t = chrono::high_resolution_clock::now();

    my_fpga_ptr->fpga_mmio_init<uint32_t>(base_address, PAGE_SIZE);

    fpga_bin_file.open(argv[2], ios::in | ios::binary);

    fpga_bin_file.seekg(0, fpga_bin_file.end);
    int file_size = fpga_bin_file.tellg();
    fpga_bin_file.seekg(0, fpga_bin_file.beg);
    cout << "File Size " << file_size << endl;

    char *bitStream_buffer = new char [file_size];
    uint32_t *bitstream_ptr;
    bitstream_ptr = (uint32_t *)bitStream_buffer;
    fpga_bin_file.read(bitStream_buffer, file_size);
    fpga_bin_file.close();

    ICAP_prog_binfile (my_fpga_ptr, bitstream_ptr, file_size );
    xfer_count = AXI_Write(my_fpga_ptr, BRAM_BASE);
    xfer_count = AXI_Read(data_buf_ptr, my_fpga_ptr, DDR4_BASE);

    // ------------ Clean -----------------------
    my_fpga_ptr->fpga_mmio_clean();
    auto stop_t = chrono::high_resolution_clock::now();
    elspsed_time = (clock() - elspsed_time);
    chrono::duration<double> elapsed_hi_res = stop_t - start_t ;
    double high_res_elapsed_time = elapsed_hi_res.count();
    cout << "High_Res count  =  " <<  high_res_elapsed_time << "s\n";
    cout << "Transfer Count = "<< xfer_count*4 << " Bytes | Bandwidth =  " << (xfer_count*4)/high_res_elapsed_time << "Bytes/s\n";
    printf ("Elapsede time = %f secs\n", (double)elspsed_time/CLOCKS_PER_SEC);

    delete [] bitStream_buffer;
    delete [] data_buf_ptr;
    return 0;
}

int ICAP_prog_binfile (fpga_mmio *fpga_ICAP, uint32_t *data_buffer, unsigned int binfile_length ) {

    uint32_t ret_data;
    uint32_t itn_count;
    uint32_t byte_swapped;
    // Reset the ICAP
    fpga_ICAP->fpga_poke<uint32_t>(ICAP_CNTRL_REG, 0x8); 
    // Check if the ICAP is ready
    ret_data = fpga_ICAP->fpga_peek<uint32_t>(ICAP_STATUS_REG); 
    printf (" Status Reg = %x\n", ret_data);
    itn_count = 0;
    while (ret_data != 0x5) {
        ret_data = fpga_ICAP->fpga_peek<uint32_t>(ICAP_STATUS_REG); 
        itn_count++; 
        if (itn_count > 1000) FAUT_CONDITION;
    }

    // ICAP Data File processing
    for (unsigned int i = 0 ; i < (binfile_length/4); i++) {
        byte_swapped = ((*data_buffer>>24)&0x000000ff) | \
                       ((*data_buffer>>8) &0x0000ff00) | \
                       ((*data_buffer<<8) &0x00ff0000) | \
                       ((*data_buffer<<24)&0xff000000);
        data_buffer++;
    
        //cout << "Writing =  " << hex << byte_swapped << endl;
        fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, byte_swapped); 
        if (((i+1) % 60) == 0) {
            // Write to the COntrol register to drain the Data FIFO every 60 or writes 
            ret_data = fpga_ICAP->fpga_peek<uint32_t>(ICAP_WR_FIFO_VACANCY_REG); 
            fpga_ICAP->fpga_poke<uint32_t>(ICAP_CNTRL_REG, 0x1); 
            itn_count = 0;
            // Wait till Fifo is drained
            while (ret_data != 0x3F) {
                ret_data = fpga_ICAP->fpga_peek<uint32_t>(ICAP_WR_FIFO_VACANCY_REG); 
                itn_count++; 
                if (itn_count > 1000) FAUT_CONDITION;
            }
        }
    }
    // Final ICAP Fifo Flush
    fpga_ICAP->fpga_poke<uint32_t>(ICAP_CNTRL_REG, 0x1); 

   return 0;
}


unsigned int AXI_Write (fpga_mmio *fpga_AXI, uint32_t ADDR_OFFSET) {

    uint32_t tmp_addr;
    unsigned int xfer_count = 0;

    for (unsigned int j = 0 ; j < 1024; j++) {
        tmp_addr = ADDR_OFFSET;
        for (unsigned int i = 0 ; i < (128*1024); i++) {
            fpga_AXI->fpga_poke<uint32_t>(tmp_addr, i); 
            xfer_count++;
            tmp_addr += 4;
        }
    }
   return xfer_count;
}

unsigned int AXI_Read (uint32_t *data_buf, fpga_mmio *fpga_AXI, uint32_t ADDR_OFFSET) {

    uint32_t tmp_addr;
    unsigned int xfer_count = 0;

    for (unsigned int j = 0 ; j < 1024; j++) {
        tmp_addr = ADDR_OFFSET;
        for (unsigned int i = 0 ; i < (128*1024); i++) {
            *data_buf = fpga_AXI->fpga_peek<uint32_t>(tmp_addr); 
            xfer_count++;
            data_buf++;
            tmp_addr += 4; 
        }
    }
   return xfer_count;
}


int ICAP_IPROG_reset (fpga_mmio *fpga_ICAP) {
   printf ("Initiatig IPROG...............\n");
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0xFFFFFFFFUL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0xFFFFFFFFUL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0xAA995566UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x20000000UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x30020001UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x00000000UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x30080001UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x0000000FUL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x20000000UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_WR_FIFO_REG, 0x20000000UL); 
   fpga_ICAP->fpga_poke<uint32_t>(ICAP_CNTRL_REG, 0x1); 

   return 0;
}
