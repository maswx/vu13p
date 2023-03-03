#!/bin/bash
# -*- coding: utf-8 -*-
#========================================================================
#        author   : masw
#        email    : masw@masw.tech     
#        creattime: 2023年03月04日 星期六 00时07分14秒
#========================================================================


wget -c https://mirrors.edge.kernel.org/pub/software/utils/pciutils/pciutils-3.9.0.tar.gz

tar -xf pciutils-3.9.0.tar.gz

cd pciutils-3.9.0

make 

sudo make install 

cd -
