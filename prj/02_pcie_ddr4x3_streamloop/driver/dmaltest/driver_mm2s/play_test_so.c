/**
 * @file play_test_so.c
 * @brief 通过动态库调用AXI DMA MM2S驱动的测试程序
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <termios.h>
#include <dlfcn.h>

// 函数指针类型定义
typedef struct axidma_mm2s_t* (*init_func_t)(int);
typedef void (*free_func_t)(struct axidma_mm2s_t*);
typedef int (*play_file_func_t)(struct axidma_mm2s_t*, const char*);
typedef int (*play_memory_func_t)(struct axidma_mm2s_t*, const void*, uint64_t);
typedef int (*stop_func_t)(struct axidma_mm2s_t*);
typedef int (*wait_func_t)(struct axidma_mm2s_t*);

// 全局变量
static void *lib_handle = NULL;
static struct axidma_mm2s_t *g_ctx = NULL;
static stop_func_t axidma_mm2s_stop_func = NULL;

// 信号处理函数
static void signal_handler(int sig)
{
    if (g_ctx && axidma_mm2s_stop_func) {
        printf("\nReceived signal %d, stopping DMA transfer...\n", sig);
        axidma_mm2s_stop_func(g_ctx);
    }
    exit(0);
}

// 设置终端为非规范模式，用于检测按键
static void setup_terminal(void)
{
    struct termios new_termios;
    tcgetattr(STDIN_FILENO, &new_termios);
    new_termios.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &new_termios);
}

// 恢复终端设置
static void restore_terminal(void)
{
    struct termios new_termios;
    tcgetattr(STDIN_FILENO, &new_termios);
    new_termios.c_lflag |= (ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &new_termios);
}

int main(int argc, char *argv[])
{
    if (argc < 2 || argc > 3) {
        fprintf(stderr, "Usage: %s <filename> [cyclic]\n", argv[0]);
        return 1;
    }
    
    const char *filename = argv[1];
    int is_cyclic = (argc == 3 && strcmp(argv[2], "cyclic") == 0);
    
    // 加载动态库
    lib_handle = dlopen("./libaxidma_mm2s.so", RTLD_LAZY);
    if (!lib_handle) {
        fprintf(stderr, "Failed to load library: %s\n", dlerror());
        return 1;
    }
    
    // 获取函数指针
    init_func_t axidma_mm2s_init_func = (init_func_t)dlsym(lib_handle, "axidma_mm2s_init");
    free_func_t axidma_mm2s_free_func = (free_func_t)dlsym(lib_handle, "axidma_mm2s_free");
    play_file_func_t axidma_mm2s_play_file_func = (play_file_func_t)dlsym(lib_handle, "axidma_mm2s_play_file");
    axidma_mm2s_stop_func = (stop_func_t)dlsym(lib_handle, "axidma_mm2s_stop");
    wait_func_t axidma_mm2s_wait_func = (wait_func_t)dlsym(lib_handle, "axidma_mm2s_wait");
    
    // 检查函数指针是否有效
    if (!axidma_mm2s_init_func || !axidma_mm2s_free_func || !axidma_mm2s_play_file_func ||
        !axidma_mm2s_stop_func || !axidma_mm2s_wait_func) {
        fprintf(stderr, "Failed to get function pointers: %s\n", dlerror());
        dlclose(lib_handle);
        return 1;
    }
    
    // 注册信号处理函数
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    // 设置终端为非规范模式
    setup_terminal();
    
    printf("Initializing AXI DMA MM2S driver...\n");
    g_ctx = axidma_mm2s_init_func(is_cyclic);
    if (!g_ctx) {
        fprintf(stderr, "Failed to initialize AXI DMA MM2S driver\n");
        dlclose(lib_handle);
        restore_terminal();
        return 1;
    }
    
    printf("Playing file: %s (Cyclic mode: %s)\n", filename, is_cyclic ? "enabled" : "disabled");
    int ret = axidma_mm2s_play_file_func(g_ctx, filename);
    if (ret != 0) {
        fprintf(stderr, "Failed to play file: %s\n", filename);
        axidma_mm2s_free_func(g_ctx);
        dlclose(lib_handle);
        restore_terminal();
        return 1;
    }
    
    printf("DMA transfer started. Press any key to stop...\n");
    
    // 等待DMA传输完成
    axidma_mm2s_wait_func(g_ctx);
    
    printf("DMA transfer completed\n");
    
    // 释放资源
    axidma_mm2s_free_func(g_ctx);
    g_ctx = NULL;
    
    // 关闭动态库
    dlclose(lib_handle);
    lib_handle = NULL;
    
    // 恢复终端设置
    restore_terminal();
    
    return 0;
}

