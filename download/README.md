
通过脚本下载bit文件

## 添加路径

```bash
cd download
echo "export PATH=\$PATH:`pwd`" >> ~/.zshrc  #如果你用zsh 就执行这句话; 强推使用ohmyzsh ! YYDS
echo "export PATH=\$PATH:`pwd`" >> ~/.bashrc #如果你用bash就执行这句话
```



## 下载 bit 文件

在你的bit文件路径处执行：

```
downloadbit.sh ./xxxxxxxxxxx.bit
```


## 2.下载 bin 文件

```bash
downloadbit.sh -bin ./xxxxxxxxxxx.bit

#NOTES: 内部会自动将bit文件转换成合适的bin文件，然后再下载bin;
```


enjoy !

