# Copyright (c) 2023 Alex Forencich
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# clock source
# STARTUPE3, IBUFG, IBUFGDS, IBUFDS_GTE4
set clk_src "STARTUPE3"

if {$clk_src == "STARTUPE3"} {

    # Fcfgmclk is 50 MHz +/- 15%, rounding to 15 ns period

    # frequency of clock source (in Hz)
    set clk_freq "50000000"
    # worst-case period for timing analysis (in ns)
    set clk_period "15"

} else {

    # clock pin
    set clk_pin {}
    # iostandard for clock pin
    set clk_iostandard "LVCMOS18"

    # frequency of clock source (in Hz)
    set clk_freq "50000000"
    # worst-case period for timing analysis (in ns)
    set clk_period [format "%.3f" [expr 1000000000.0 / $clk_freq]]

}

# desired baud rate
set baud "115200"

# number of groups to shift at the same time
# more groups reduces collisions at the expense of repetition rate
set group_count "32"

# iostandard for all pins
set iostandard "LVCMOS18"

# pins to skip
set skip_pins_by_index {}
set skip_pins_by_name {}

