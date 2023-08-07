
通过脚本下载bit文件

## 下载 bit 文件

```bash

make bitname=~/work/pciex16_ddr4_x4.bit

```

或者 直接修改Makefile 文件里的bitname ,然后 

```bash
make
```

## 2.下载 bin 文件

```bash
make binname=~/work/pciex16_ddr4_x4.bin
# log by masw:  vivado有时候会报错，有空再解决
```

## 3. 将bit文件转换为适合 vu13p下载的bin文件

```bash
make bit2bin bitname=~/work/pciex16_ddr4_x4.bit
# 会在当前路径下生成一个同名的bin文件
```


enjoy !

