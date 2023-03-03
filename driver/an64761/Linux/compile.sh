#!/bin/bash

## NOTES: 

make PCIUTILS_PATH=../pcieutils/pciutils-3.9.0


## 
# for reference only
# ➜  Linux git:(main) ✗ ./mcap -x 8011
# Xilinx MCAP device found
# Unable to get the Register Base
# ➜  Linux git:(main) ✗ sudo ./mcap -x 0x8011
# [sudo] password for dbg:
# Xilinx MCAP device found
# ➜  Linux git:(main) ✗ sudo ./mcap -x 0x8012
# Xilinx MCAP device not found .. Exiting ...
# ➜  Linux git:(main) ✗ sudo ./mcap -x 8012
# Xilinx MCAP device not found .. Exiting ...
# ➜  Linux git:(main) ✗ sudo ./mcap -x 0x8011
# Xilinx MCAP device found
# ➜  Linux git:(main) ✗ sudo ./mcap -x 0x8011 -a 0x354 b
# Xilinx MCAP device found
# ➜  Linux git:(main) ✗ sudo ./mcap -x 0x8011 -a 0x354 b
# Xilinx MCAP device found
# Read 0x00000001 @ 0x354
# ➜  Linux git:(main) ✗ sudo ./mcap -x 0x8011 -a 0x355 b
# Xilinx MCAP device found
# Read 0x00000000 @ 0x355
