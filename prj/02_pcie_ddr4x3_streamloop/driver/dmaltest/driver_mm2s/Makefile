CC = gcc
CFLAGS = -Wall -Wextra -O2 -g -fPIC
LDFLAGS = -lpthread -ldl

# 目标文件
LIB_TARGET = libaxidma_mm2s.so
TEST_TARGET = play_test
TEST_SO_TARGET = play_test_so

# 源文件
LIB_SRCS = axidma_mm2s.c
TEST_SRCS = play_test.c
TEST_SO_SRCS = play_test_so.c

# 目标规则
all: $(LIB_TARGET) $(TEST_TARGET) $(TEST_SO_TARGET)

# 编译动态库
$(LIB_TARGET): $(LIB_SRCS)
	$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

# 编译测试程序（直接链接）
$(TEST_TARGET): $(TEST_SRCS)
	$(CC) $(CFLAGS) -o $@ $< -L. -laxidma_mm2s -Wl,-rpath,. $(LDFLAGS)

# 编译测试程序（动态加载）
$(TEST_SO_TARGET): $(TEST_SO_SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# 清理规则
clean:
	rm -f $(LIB_TARGET) $(TEST_TARGET) $(TEST_SO_TARGET)

# 安装规则
install: $(LIB_TARGET)
	install -m 755 $(LIB_TARGET) /usr/local/lib/
	ldconfig

# 运行规则
run: $(TEST_TARGET)
	./$(TEST_TARGET)

run_so: $(TEST_SO_TARGET)
	./$(TEST_SO_TARGET)

.PHONY: all clean install run run_so

