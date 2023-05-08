# 设置编译器和编译选项
CC=gcc
LIB_PATH = /opt/Xilinx/Vitis/2022.2/data/embeddedsw

CFLAGS  = -Wall -I.
CFLAGS += -I$(LIB_PATH)/lib/bsp/standalone_v8_0/src/microblaze/
CFLAGS += -I$(LIB_PATH)/lib/bsp/standalone_v8_0/src/common/
CFLAGS += -I$(LIB_PATH)/XilinxProcessorIPLib/drivers/intc_v3_15/src/
CFLAGS += -I$(LIB_PATH)/XilinxProcessorIPLib/drivers/common_v1_2/src
CFLAGS += -I$(LIB_PATH)/XilinxProcessorIPLib/drivers/axidma_v9_15/src
CFLAGS += -I$(LIB_PATH)/XilinxProcessorIPLib/drivers/iic_v3_9/src
CFLAGS += -I$(LIB_PATH)/XilinxProcessorIPLib/drivers/clk_wiz_v1_5/src

# 定义源文件目录和目标文件目录
SRCDIR  = .
SRCDIR += $(LIB_PATH)/lib/bsp/standalone_v8_0/src/microblaze/
SRCDIR += $(LIB_PATH)/lib/bsp/standalone_v8_0/src/common/
SRCDIR += $(LIB_PATH)/XilinxProcessorIPLib/drivers/intc_v3_15/src/
SRCDIR += $(LIB_PATH)/XilinxProcessorIPLib/drivers/common_v1_2/src
SRCDIR += $(LIB_PATH)/XilinxProcessorIPLib/drivers/axidma_v9_15/src
SRCDIR += $(LIB_PATH)/XilinxProcessorIPLib/drivers/iic_v3_9/src
SRCDIR += $(LIB_PATH)/XilinxProcessorIPLib/drivers/clk_wiz_v1_5/src

OBJDIR=./obj

# 找到所有源文件
SRCS=$(wildcard $(SRCDIR)/*.c)

# 将源文件路径替换为目标文件路径
OBJS=$(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCS))

# 定义目标可执行文件名
TARGET=main

# 默认目标，编译可执行文件
all: $(TARGET)

# 编译每个源文件
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# 链接所有目标文件以生成可执行文件
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

# 清理目标文件和可执行文件
clean:
	rm -f $(OBJDIR)/*.o $(TARGET)

