/**
 * @file play_test.c
 * @brief AXI DMA MM2S驱动测试程序
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <termios.h>
#include <stdint.h>
#include "axidma_mm2s.h"

// 全局变量用于信号处理
static axidma_mm2s_t *g_ctx = NULL;

// 信号处理函数
static void signal_handler(int sig)
{
    if (g_ctx) {
        printf("\nReceived signal %d, stopping DMA transfer...\n", sig);
        axidma_mm2s_stop(g_ctx);
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
    bool is_cyclic = (argc == 3 && strcmp(argv[2], "cyclic") == 0);
    
    // 注册信号处理函数
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    // 设置终端为非规范模式
    setup_terminal();
    
    printf("Initializing AXI DMA MM2S driver...\n");
    g_ctx = axidma_mm2s_init(is_cyclic);
    if (!g_ctx) {
        fprintf(stderr, "Failed to initialize AXI DMA MM2S driver\n");
        restore_terminal();
        return 1;
    }
    
    printf("Playing file: %s (Cyclic mode: %s)\n", filename, is_cyclic ? "enabled" : "disabled");
    int ret = axidma_mm2s_play_file(g_ctx, filename);
    if (ret != 0) {
        fprintf(stderr, "Failed to play file: %s\n", filename);
        axidma_mm2s_free(g_ctx);
        restore_terminal();
        return 1;
    }
    
    printf("DMA transfer started. Press any key to stop...\n");
    
    // 等待DMA传输完成
    axidma_mm2s_wait(g_ctx);
    
    printf("DMA transfer completed\n");
    
    // 释放资源
    axidma_mm2s_free(g_ctx);
    g_ctx = NULL;
    
    // 恢复终端设置
    restore_terminal();
    
    return 0;
}

