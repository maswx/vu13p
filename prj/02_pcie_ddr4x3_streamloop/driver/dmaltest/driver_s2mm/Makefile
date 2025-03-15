# AXI DMA S2MM驱动和测试程序的Makefile

CC = gcc
CFLAGS = -Wall -Wextra -O2 -g -fPIC
LDFLAGS = -lpthread -ldl

# 目标文件
LIB_SHARED = libaxidma_s2mm.so
LIB_STATIC = libaxidma_s2mm.a
TEST_DIRECT = recv_test
TEST_SO = recv_test_so

# 源文件和目标文件
SRC = axidma_s2mm.c
OBJ = $(SRC:.c=.o)
TEST_SRC = recv_test.c
TEST_OBJ = $(TEST_SRC:.c=.o)
TEST_SO_SRC = recv_test_so.c
TEST_SO_OBJ = $(TEST_SO_SRC:.c=.o)

# 默认目标
all: $(LIB_SHARED) $(LIB_STATIC) $(TEST_DIRECT) $(TEST_SO)

# 编译共享库
$(LIB_SHARED): $(OBJ)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

# 编译静态库
$(LIB_STATIC): $(OBJ)
	ar rcs $@ $^

# 编译直接测试程序（修改后不依赖库文件）
$(TEST_DIRECT): $(TEST_OBJ) $(SRC)
	$(CC) -o $@ $(TEST_OBJ) $(SRC) $(LDFLAGS)

# 编译动态库测试程序
$(TEST_SO): $(TEST_SO_OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

# 编译规则
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 清理
clean:
	rm -f $(OBJ) $(TEST_OBJ) $(TEST_SO_OBJ) $(LIB_SHARED) $(LIB_STATIC) $(TEST_DIRECT) $(TEST_SO)

# 安装
install: $(LIB_SHARED) $(LIB_STATIC)
	install -d $(DESTDIR)/usr/local/lib
	install -m 755 $(LIB_SHARED) $(DESTDIR)/usr/local/lib
	install -m 644 $(LIB_STATIC) $(DESTDIR)/usr/local/lib
	install -d $(DESTDIR)/usr/local/include
	install -m 644 axidma_s2mm.h $(DESTDIR)/usr/local/include
	ldconfig

.PHONY: all clean install

