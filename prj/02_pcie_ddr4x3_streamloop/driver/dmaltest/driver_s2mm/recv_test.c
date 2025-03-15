/**
 * @file recv_test.c
 * @brief AXI DMA S2MM接收测试程序
 */

#include "axidma_s2mm.h"
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

// 全局句柄，用于信号处理
static axidma_s2mm_t *g_handle = NULL;

// 信号处理函数
static void signal_handler(int sig)
{
    printf("Received signal %d, exiting...\n", sig);
    if (g_handle) {
        axidma_s2mm_stop(g_handle);
    }
    exit(0);
}

int main(int argc, char *argv[])
{
    const char *output_file = "received_data.bin";
    int run_time = 30;  // 默认运行30秒
    
    // 解析命令行参数
    if (argc > 1) {
        output_file = argv[1];
    }
    
    if (argc > 2) {
        run_time = atoi(argv[2]);
        if (run_time <= 0) {
            run_time = 30;
        }
    }
    
    printf("AXI DMA S2MM Receive Test\n");
    printf("Output file: %s\n", output_file);
    printf("Run time: %d seconds\n", run_time);
    
    // 设置信号处理
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    // 初始化AXI DMA S2MM
    g_handle = axidma_s2mm_init(output_file);
    if (!g_handle) {
        fprintf(stderr, "Failed to initialize AXI DMA S2MM\n");
        return 1;
    }
    
    // 启动AXI DMA S2MM传输
    if (axidma_s2mm_start(g_handle) != 0) {
        fprintf(stderr, "Failed to start AXI DMA S2MM\n");
        axidma_s2mm_free(g_handle);
        return 1;
    }
    
    printf("AXI DMA S2MM running, press Ctrl+C to stop...\n");
    
    // 运行指定时间
    sleep(run_time);
    
    // 停止AXI DMA S2MM传输
    axidma_s2mm_stop(g_handle);
    
    // 释放资源
    axidma_s2mm_free(g_handle);
    g_handle = NULL;
    
    printf("AXI DMA S2MM test completed\n");
    
    return 0;
}

