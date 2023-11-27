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


/* Address Ranges as defined in VIvado IPI Address map */
/* NOTE: Be aware on any PCIe-AXI Address translation setup on the xDMA/PCIEBridge*/ 
/*       These address translations affect the address shown . THese address are  */
/*       exactly waht is populated on the IPI Address tab                         */
#define ICAP_BASE 0x00000000

/* Address Offset of various Peripheral Registers */ 
#define ICAP_CNTRL_REG           0x10C
#define ICAP_STATUS_REG          0x110
#define ICAP_WR_FIFO_REG         0x100
#define ICAP_WR_FIFO_VACANCY_REG 0x114

int ICAP_prog_binfile (fpga_mmio *fpga_ICAP, uint32_t *data_buffer, unsigned int binfile_length );
int ICAP_acess (fpga_mmio *fpga_ICAP);

int main(int argc, char **argv) {

    uint32_t base_address_ddr4;
    clock_t elspsed_time;

    fstream fpga_bin_file;

    if (argc != 2) {
        printf("usage: pcie_mmio fpga_bit_file\n");
        return -1;
    }

    // ------------ Init -----------------------
    fpga_mmio *my_fpga_ptr = new fpga_mmio;
   

    elspsed_time = clock();
    auto start_t = chrono::high_resolution_clock::now();

    my_fpga_ptr->fpga_mmio_init();



    fpga_bin_file.open(argv[1], ios::in | ios::binary);

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

    // ------------ Clean -----------------------
    my_fpga_ptr->fpga_mmio_clean();
    auto stop_t = chrono::high_resolution_clock::now();
    elspsed_time = (clock() - elspsed_time);
    chrono::duration<double> elapsed_hi_res = stop_t - start_t ;
    double high_res_elapsed_time = elapsed_hi_res.count();
    cout << "High_Res count  =  " <<  high_res_elapsed_time << "s\n";
    printf ("Elapsede time = %f secs\n", (double)elspsed_time/CLOCKS_PER_SEC);

    delete [] bitStream_buffer;
    return 0;
}

int ICAP_prog_binfile (fpga_mmio *fpga_ICAP, uint32_t *data_buffer, unsigned int binfile_length ) {

    uint32_t ret_data;
    uint32_t itn_count;
    uint32_t byte_swapped;
    // Reset the ICAP
    fpga_ICAP->fpga_regwrite(ICAP_CNTRL_REG, 0x8); 
    // Check if the ICAP is ready
    ret_data = fpga_ICAP->fpga_regread(ICAP_STATUS_REG); 
    printf (" Status Reg = %x\n", ret_data);
    itn_count = 0;
    while (ret_data != 0x5) {
        ret_data = fpga_ICAP->fpga_regread(ICAP_STATUS_REG); 
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
        fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, byte_swapped); 
        if (((i+1) % 60) == 0) {
            // Write to the COntrol register to drain the Data FIFO every 60 or writes 
            ret_data = fpga_ICAP->fpga_regread(ICAP_WR_FIFO_VACANCY_REG); 
            fpga_ICAP->fpga_regwrite(ICAP_CNTRL_REG, 0x1); 
            itn_count = 0;
            // Wait till Fifo is drained
            while (ret_data != 0x3F) {
                ret_data = fpga_ICAP->fpga_regread(ICAP_WR_FIFO_VACANCY_REG); 
                itn_count++; 
                if (itn_count > 1000) FAUT_CONDITION;
            }
        }
    }
    // Final ICAP Fifo Flush
    fpga_ICAP->fpga_regwrite(ICAP_CNTRL_REG, 0x1); 

   return 0;
}




int ICAP_IPROG_reset (fpga_mmio *fpga_ICAP) {
   printf ("Initiatig IPROG...............\n");
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0xFFFFFFFFUL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0xFFFFFFFFUL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0xAA995566UL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x20000000UL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x30020001UL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x00000000UL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x30080001UL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x0000000FUL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x20000000UL); 
   fpga_ICAP->fpga_regwrite(ICAP_WR_FIFO_REG, 0x20000000UL); 
   fpga_ICAP->fpga_regwrite(ICAP_CNTRL_REG, 0x1); 

   return 0;
}
