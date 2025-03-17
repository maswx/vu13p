
# 使用

```shell
unzip ./hdl_2023r2_2156ac7.zip 
vim ./hdl-main/scripts/adi_env.tcl 
// 把set required_vivado_version "2023.2" 修改成你的版本
set required_vivado_version "2024.1"

cd ./hdl-main/library/ 
make -j8
```
