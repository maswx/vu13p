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


#ifndef FPGA_MMIO_UTILS_H_
#define  FPGA_MMIO_UTILS_H_

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <errno.h>
#include <inttypes.h>
#include <iostream>
#include <iomanip>

using namespace std;

#define FAUT_CONDITION do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)



class fpga_mmio {
    private :
        void *virt_page_base;
        int fp_dev_mem;
        uint32_t PAGE_SIZE;

    public :

        fpga_mmio (void) {}
        
        template <class access_type>
        int fpga_poke (uint32_t register_offset, access_type val) {
            access_type *tmp_addr;
            tmp_addr = (access_type *)((uint8_t *)virt_page_base + register_offset);

            *tmp_addr = val;
            return 0;
        }

        template <class access_type>
        access_type fpga_peek (uint32_t register_offset) {
            access_type *tmp_addr;
            tmp_addr = (access_type *)((uint8_t *)virt_page_base + register_offset);
            return(*tmp_addr);
        }


        template <class addr_type>
        int fpga_mmio_init(addr_type base_address, uint32_t PAGE_SIZE_i) {
            PAGE_SIZE = PAGE_SIZE_i;

            if((fp_dev_mem = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FAUT_CONDITION;
            fflush(stdout);

            //cout << " Base Address = " << hex << "0x" << base_address << endl;
            virt_page_base = mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fp_dev_mem, base_address & ~(PAGE_SIZE-1));
            //cout << " Virtual Base Address = " << hex << virt_page_base << endl;
            if(virt_page_base == (void *) -1) FAUT_CONDITION;

            return 0;
        }

        int fpga_mmio_clean() {
            if(munmap(virt_page_base, PAGE_SIZE) == -1) FAUT_CONDITION;
            close(fp_dev_mem);
            return 0;
        }
};
#endif
