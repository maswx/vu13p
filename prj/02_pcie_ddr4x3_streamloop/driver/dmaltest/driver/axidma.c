#include "./axidma.h"
#include "./axidma_cfg.h"
/**
 * 打印单个MM2S DMA描述符的详细内容
 * @param desc_ptr 描述符指针
 * @param desc_index 描述符索引（用于显示）
 */
void print_s2mm_dma_registers(s2mm_dma_t *dma);
void print_mm2s_descriptor(volatile uint32_t *desc_ptr)
{
    if (!desc_ptr) {
        printf("[ERROR] 描述符指针为NULL\n");
        return;
    }

    printf("\n===== 描述符 =======\n");
    printf("描述符地址: %p\n", (void*)desc_ptr);

    // 下一描述符地址
    uint32_t next_desc_lo = desc_ptr[0];
    uint32_t next_desc_hi = desc_ptr[1];
    printf("下一描述符地址: 0x%08x%08x\n", next_desc_hi, next_desc_lo);
    if (next_desc_lo == 0 && next_desc_hi == 0) {
        printf("  (这是链表中的最后一个描述符)\n");
    }

    // 缓冲区地址
    uint32_t buffer_addr_lo = desc_ptr[2];
    uint32_t buffer_addr_hi = desc_ptr[3];
    printf("缓冲区地址: 0x%08x%08x\n", buffer_addr_hi, buffer_addr_lo);

    // 保留字段
    printf("保留字段: 0x%08x\n", desc_ptr[4]);

    // 控制字
    uint32_t control = desc_ptr[6];
    printf("控制字: 0x%08x\n", control);
    printf("  - 缓冲区长度: %u 字节\n", control & 0x3FFFFFF);

    // 控制位
    if (control & 0x8000000) printf("  - SOP: 是 (包起始)\n");
    if (control & 0x4000000) printf("  - EOP: 是 (包结束)\n");

    // 可选的其他控制位
    if (control & 0x10000000) printf("  - TXSOF: 是\n");
    if (control & 0x20000000) printf("  - TXEOF: 是\n");

    // 状态字
    uint32_t status = desc_ptr[7];
    printf("状态字: 0x%08x\n", status);

    // 状态位
    printf("  - 完成状态: %s\n", (status & 0x80000000) ? "已完成" : "未完成");

    if (status & 0x80000000) {  // 如果已完成，显示更多状态信息
        printf("  - 解码错误: %s\n", (status & 0x40000000) ? "有错误" : "无错误");
        printf("  - 从属错误: %s\n", (status & 0x20000000) ? "有错误" : "无错误");
        printf("  - 内部错误: %s\n", (status & 0x10000000) ? "有错误" : "无错误");
        printf("  - 实际传输长度: %u 字节\n", status & 0x3FFFFFF);

        // 检查传输长度是否与请求长度匹配
        uint32_t requested_len = control & 0x3FFFFFF;
        uint32_t actual_len = status & 0x3FFFFFF;

        if (requested_len != actual_len) {
            printf("  [警告] 实际传输长度(%u)与请求长度(%u)不匹配!\n",
                   actual_len, requested_len);
        }
    }

    // 应用数据（通常用于用户自定义数据）
    printf("应用数据: 0x%08x\n", desc_ptr[7]);

    // 额外的调试信息：计算描述符的物理地址
    printf("描述符物理地址估计: 0x%lx\n",
           (uintptr_t)desc_ptr & 0xFFFFFFFFFFFFF000UL);  // 假设页对齐
}

// 打开设备文件并映射内存
int init_mm2s_dma(mm2s_dma_t *dma, const char *filename) {
    struct stat st;

    // 打开DMA控制器
    dma->dma_fd = open(BAR_SPACE_FD, O_RDWR | O_SYNC);
    if (dma->dma_fd < 0) {
        perror("Failed to open DMA controller");
        return -1;
    }

    // 映射DMA寄存器
    dma->dma_regs = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED,
                          dma->dma_fd, DMA_DEV_BASE_ADDR);
    if (dma->dma_regs == MAP_FAILED) {
        perror("Failed to map DMA registers");
        close(dma->dma_fd);
        return -1;
    }

    // 映射描述符空间
    dma->desc_base = mmap(NULL, DMA_DESC_ALL_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                           dma->dma_fd, DMA_DESC_BASE_ADDR);
    if (dma->desc_base == MAP_FAILED) {
        perror("Failed to map descriptor space");
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 打开数据文件
    dma->data_fd = open(H2C0_BUFFER_FD, O_RDWR | O_SYNC);
    if (dma->data_fd < 0) {
        perror("Failed to open data device");
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 打开事件文件
    dma->event_fd = open(MM2S_INTERP_FD, O_RDONLY);
    if (dma->event_fd < 0) {
        perror("Failed to open event device");
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 获取输入文件大小
    if (stat(filename, &st) < 0) {
        perror("Failed to get file size");
        close(dma->event_fd);
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }
    dma->file_size = st.st_size;

    // 确定缓冲区大小
    dma->buffer_size = (dma->file_size < MM2S_BUFFER_SIZE) ? dma->file_size : MM2S_BUFFER_SIZE;

    // 分配内存缓冲区，而不是映射
    dma->buffer = malloc(dma->buffer_size);
    if (dma->buffer == NULL) {
        perror("Failed to allocate buffer memory");
        close(dma->event_fd);
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    dma->bytes_sent = 0;
    dma->running = 0;

    // 确定是否使用循环模式
    dma->is_cyclic = (dma->file_size > dma->buffer_size);

    return 0;
}
// 加载文件数据到缓冲区
int load_file_to_buffer(mm2s_dma_t *dma, const char *filename) {
    int fd;
    ssize_t bytes_read = 0;
    size_t total_read = 0;
    char *buf_ptr = (char *)dma->buffer;

    fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open input file");
        return -1;
    }

    // 读取文件内容到缓冲区
    while (total_read < dma->buffer_size &&
           (bytes_read = read(fd, buf_ptr + total_read,
                             dma->buffer_size - total_read)) > 0) {
        total_read += bytes_read;
    }

    if (bytes_read < 0) {
        perror("Error reading file");
        close(fd);
        return -1;
    }

    close(fd);

    // 将缓冲区写入H2C设备
    ssize_t bytes_written = 0;
    size_t total_written = 0;

    while (total_written < total_read) {
        bytes_written = write(dma->data_fd, buf_ptr + total_written, total_read - total_written);
        if (bytes_written < 0) {
            if (errno == EINTR) continue;
            perror("Error writing to H2C device");
            return -1;
        }
        total_written += bytes_written;
    }

    printf("Loaded %zu bytes from file to buffer and wrote to H2C device\n", total_written);
    return 0;
}
// 配置MM2S描述符链
int setup_mm2s_descriptors(mm2s_dma_t *dma) {
    uint8_t *mm2s_desc_base = (uint8_t *)dma->desc_base ; // MM2S描述符在高32KB
    uint64_t remaining_size = dma->file_size;
    uint64_t buffer_offset = MM2S_BUFFER_BASEADDR ;
    uint32_t desc_idx = 0;
    uint64_t transfer_size;
    
    // 计算需要的描述符数量
    if (dma->file_size <= MM2S_ONE_PACKET_SIZE) {
        // 如果文件小于单个包大小，只需一个描述符
        dma->desc_count = 1;
        transfer_size = dma->file_size;
    } else {
        // 计算需要多少个MM2S_ONE_PACKET_SIZE的描述符
        dma->desc_count = (dma->file_size + MM2S_ONE_PACKET_SIZE - 1) / MM2S_ONE_PACKET_SIZE;
        if (dma->desc_count > MAX_DESC_COUNT) {//MAX_DESC_COUNT定义在头文件中 = 512
            dma->desc_count = MAX_DESC_COUNT;
        }
        transfer_size = MM2S_ONE_PACKET_SIZE;
    }
    
    printf("Setting up %d MM2S descriptors\n", dma->desc_count);
    
    // 配置每个描述符
    for (desc_idx = 0; desc_idx < dma->desc_count; desc_idx++) {
        volatile uint8_t *desc = mm2s_desc_base + desc_idx * DESC_SIZE;
        uint64_t next_desc_addr = ((desc_idx + 1) % dma->desc_count) * DESC_SIZE + DMA_DESC_BASE_ADDR ;
        uint64_t buffer_addr = buffer_offset;
        uint32_t control = 0;
       
        // 如果剩余大小小于传输大小，调整传输大小
        if (remaining_size < transfer_size) {
            transfer_size = remaining_size;
        }
        
        // 设置下一个描述符地址
        *(volatile uint32_t *)(desc + NXTDESC_OFFSET) = next_desc_addr & 0xFFFFFFFC;
        *(volatile uint32_t *)(desc + NXTDESC_MSB_OFFSET) = next_desc_addr >> 32;
        
        // 设置缓冲区地址
        *(volatile uint32_t *)(desc + BUFFER_ADDR_OFFSET) = buffer_addr & 0xFFFFFFFF;
        *(volatile uint32_t *)(desc + BUFFER_ADDR_MSB_OFFSET) = buffer_addr >> 32;
        
        // 设置控制字段
        control = transfer_size & 0x3FFFFFF; // 传输大小
        
        // 设置SOF和EOF标志
        if (desc_idx == 0 || buffer_offset == 0) {
            control |= CONTROL_TXSOF; // 第一个描述符或新包的开始
        }
        if ((desc_idx == (dma->desc_count - 1)) || remaining_size == transfer_size) {
            control |= CONTROL_TXEOF; // 最后一个描述符或包的结束
        }
        control |= CONTROL_TXSOF ; // 第一个描述符或新包的开始
        control |= CONTROL_TXEOF; // 最后一个描述符或包的结束
        *(volatile uint32_t *)(desc + CONTROL_OFFSET) = control;

        // 清除状态字段
        *(volatile uint32_t *)(desc + STATUS_OFFSET) = 0;
        
        buffer_offset += transfer_size;
        remaining_size -= transfer_size;
        
        if (remaining_size == 0) {
            break;
        }
    }
    
    return 0;
}
// 启动MM2S DMA传输
int start_mm2s_dma(mm2s_dma_t *dma) {
    uint32_t dmacr, dmasr;
    uint64_t first_desc_addr = DMA_DESC_BASE_ADDR ; // MM2S描述符起始地址
    uint64_t tail_desc_addr;
    
    // 等待DMA处于停止状态
    dmasr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMASR);
    if (!(dmasr & DMASR_HALTED)) {
        // 如果DMA未停止，先停止它
        dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR);
        dmacr &= ~DMACR_RS;
        *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR) = dmacr;
        
        // 等待DMA停止
        do {
            dmasr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMASR);
        } while (!(dmasr & DMASR_HALTED));
    }
    
    // 软复位DMA
    dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR);
    dmacr |= DMACR_RESET;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR) = dmacr;
    
    // 等待复位完成
    do {
        dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR);
    } while (dmacr & DMACR_RESET);
    
    // 设置当前描述符指针
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_CURDESC) = first_desc_addr & 0xFFFFFFFC;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_CURDESC_MSB) = first_desc_addr >> 32;
    
    // 配置DMA控制寄存器
    dmacr = DMACR_IOC_IRQ | DMACR_ERR_IRQ;
    
    // 如果需要循环模式
    if (dma->is_cyclic) {
        dmacr |= DMACR_CYCLIC;
    }
    
    // 启动DMA
    dmacr |= DMACR_RS;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR) = dmacr;
    
    // 设置尾描述符指针
    if (dma->desc_count > 1) {
        tail_desc_addr =  (dma->desc_count - 1) * DESC_SIZE;
    } else {
        tail_desc_addr = 0;
    }
    
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_TAILDESC) = tail_desc_addr & 0xFFFFFFFC;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_TAILDESC_MSB) = tail_desc_addr >> 32;
    
    dma->running = 1;
    printf("MM2S DMA started\n");
    
    return 0;
}

// 中断处理线程
void *mm2s_event_handler_thread(void *arg) {
    mm2s_dma_t *dma = (mm2s_dma_t *)arg;
    uint32_t event_data;
    ssize_t bytes_read;
 
    printf("MM2S中断处理线程启动, 等待中断\n");


    while (dma->running) {
        // 读取事件
        bytes_read = read(dma->event_fd, &event_data, sizeof(event_data));
        if (bytes_read <= 0) {
            if (errno == EAGAIN || errno == EINTR) {
                continue;
            }
            perror("Error reading event");
            break;
        }
        
        printf("Received mm2s interrupt event: 0x%08x\n", event_data);
        // 检查DMA状态
        uint32_t dmasr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMASR);
        
        // 清除中断标志
        if (dmasr & DMASR_IOC_IRQ) {
            *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMASR) = DMASR_IOC_IRQ;
            printf("IOC interrupt cleared\n");
            
            // 更新已发送字节数
            dma->bytes_sent += MM2S_ONE_PACKET_SIZE;
            if (dma->bytes_sent > dma->file_size) {
                dma->bytes_sent = dma->file_size;
            }
            
            printf("Bytes sent: %lu / %lu\n", dma->bytes_sent, dma->file_size);
            
            // 如果所有数据都已发送，停止DMA
            if (dma->bytes_sent >= dma->file_size && !dma->is_cyclic) {
                printf("All data sent, stopping DMA\n");
                uint32_t dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR);
                dmacr &= ~DMACR_RS;
                *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR) = dmacr;
                dma->running = 0;
                break;
            }
        }
        
        // 处理错误中断
        if (dmasr & DMASR_ERR_IRQ) {
            *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMASR) = DMASR_ERR_IRQ;
            printf("Error mm2s interrupt received, DMA status: 0x%08x\n", dmasr);
            
            // 如果发生错误，停止 MM2S 的 DMA
            uint32_t dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR);
            dmacr &= ~DMACR_RS;
            *(volatile uint32_t *)((uint8_t *)dma->dma_regs + MM2S_DMACR) = dmacr;
            dma->running = 0;
            break;
        }
    }
    
    return NULL;
}

// 初始化工作队列
int init_work_queue(work_queue_t *queue, int capacity) {
    queue->items = (work_item_t *)malloc(capacity * sizeof(work_item_t));
    if (!queue->items) {
        perror("Failed to allocate work queue items");
        return -1;
    }
    
    queue->capacity = capacity;
    queue->head = 0;
    queue->tail = 0;
    queue->count = 0;
    
    if (pthread_mutex_init(&queue->mutex, NULL) != 0) {
        perror("Failed to initialize mutex");
        free(queue->items);
        return -1;
    }
    
    if (pthread_cond_init(&queue->not_empty, NULL) != 0) {
        perror("Failed to initialize not_empty condition");
        pthread_mutex_destroy(&queue->mutex);
        free(queue->items);
        return -1;
    }
    
    if (pthread_cond_init(&queue->not_full, NULL) != 0) {
        perror("Failed to initialize not_full condition");
        pthread_cond_destroy(&queue->not_empty);
        pthread_mutex_destroy(&queue->mutex);
        free(queue->items);
        return -1;
    }
    
    return 0;
}

// 入队工作项
int enqueue_work(work_queue_t *queue, void *buffer, size_t size, int frame_index) {
    pthread_mutex_lock(&queue->mutex);
    
    // 等待队列非满
    while (queue->count == queue->capacity) {
        pthread_cond_wait(&queue->not_full, &queue->mutex);
    }
    
    // 添加工作项
    work_item_t *item = &queue->items[queue->tail];
    item->buffer = buffer;
    item->size = size;
    item->frame_index = frame_index;
    clock_gettime(CLOCK_REALTIME, &item->ts);
    
    // 更新队列
    queue->tail = (queue->tail + 1) % queue->capacity;
    queue->count++;
    
    // 通知消费者
    pthread_cond_signal(&queue->not_empty);
    pthread_mutex_unlock(&queue->mutex);
    
    return 0;
}

// 出队工作项
int dequeue_work(work_queue_t *queue, work_item_t *item) {
    pthread_mutex_lock(&queue->mutex);
    
    // 等待队列非空
    while (queue->count == 0) {
        pthread_cond_wait(&queue->not_empty, &queue->mutex);
    }
    
    // 获取工作项
    *item = queue->items[queue->head];
    
    // 更新队列
    queue->head = (queue->head + 1) % queue->capacity;
    queue->count--;
    
    // 通知生产者
    pthread_cond_signal(&queue->not_full);
    pthread_mutex_unlock(&queue->mutex);
    
    return 0;
}

// 销毁工作队列
void destroy_work_queue(work_queue_t *queue) {
    pthread_mutex_destroy(&queue->mutex);
    pthread_cond_destroy(&queue->not_empty);
    pthread_cond_destroy(&queue->not_full);
    free(queue->items);
}

// 初始化S2MM DMA
int init_s2mm_dma(s2mm_dma_t *dma, const char *output_dir) {
    memset(dma, 0, sizeof(s2mm_dma_t));
    strncpy(dma->output_dir, output_dir, sizeof(dma->output_dir) - 1);

    // 打开DMA控制器
    dma->dma_fd = open(BAR_SPACE_FD, O_RDWR | O_SYNC);
    if (dma->dma_fd < 0) {
        perror("Failed to open DMA controller");
        return -1;
    }

    // 映射DMA寄存器
    dma->dma_regs = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED,
                          dma->dma_fd, DMA_DEV_BASE_ADDR);
    if (dma->dma_regs == MAP_FAILED) {
        perror("Failed to map DMA registers");
        close(dma->dma_fd);
        return -1;
    }

    // 映射描述符空间
    dma->desc_base = mmap(NULL, DMA_DESC_ALL_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                           dma->dma_fd, DMA_DESC_BASE_ADDR);
    if (dma->desc_base == MAP_FAILED) {
        perror("Failed to map descriptor space");
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 打开数据文件
    dma->data_fd = open(C2H0_BUFFER_FD, O_RDWR | O_SYNC);
    if (dma->data_fd < 0) {
        perror("Failed to open data device");
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 打开事件文件
    dma->event_fd = open(S2MM_INTERP_FD, O_RDONLY);
    if (dma->event_fd < 0) {
        perror("Failed to open event device");
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 设置缓冲区大小和描述符数量
    dma->buffer_size = S2MM_BUFFER_SIZE;
    dma->desc_count = MAX_DESC_COUNT;
    dma->desc_size = DESC_SIZE;
    dma->segment_size = dma->buffer_size / dma->desc_count;
	printf("dma->buffer_size  = 0x%08lx\n", dma->buffer_size);
	printf("dma->desc_count   = 0x%08x\n", dma->desc_count);
	printf("dma->segment_size = 0x%08lx\n", dma->segment_size);

    // 分配内存缓冲区，而不是映射
    dma->buffer = malloc(dma->buffer_size);
    if (dma->buffer == NULL) {
        perror("Failed to allocate buffer memory");
        close(dma->event_fd);
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 分配描述符状态数组
    dma->desc_status = (desc_status_t *)calloc(dma->desc_count, sizeof(desc_status_t));
    if (!dma->desc_status) {
        perror("Failed to allocate descriptor status array");
        free(dma->buffer);
        close(dma->event_fd);
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    // 初始化工作队列
    if (init_work_queue(&dma->work_queue, S2MM_WORK_QUEUE) != 0) {
        free(dma->desc_status);
        free(dma->buffer);
        close(dma->event_fd);
        close(dma->data_fd);
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
        munmap(dma->dma_regs, 4096);
        close(dma->dma_fd);
        return -1;
    }

    dma->running = 0;
    dma->frame_count = 0;

    return 0;
}


// 设置S2MM描述符
int setup_s2mm_descriptors(s2mm_dma_t *dma) {
    uint8_t *s2mm_desc_base = (uint8_t *)dma->desc_base + DMA_DESC_ALL_SIZE/2; // S2MM描述符在低32KB
    
    printf("Setting up %d S2MM descriptors, segment size: %zu bytes\n", 
           dma->desc_count, dma->segment_size);
    
    // 配置每个描述符
    for (uint32_t i = 0; i < dma->desc_count; i++) {
        volatile uint8_t *desc = s2mm_desc_base + i * dma->desc_size;
        uint64_t next_desc_addr = ((i + 1) % dma->desc_count) * dma->desc_size + DMA_DESC_ALL_SIZE/2 + DMA_DESC_BASE_ADDR ;
        uint64_t buffer_addr = S2MM_BUFFER_BASEADDR + i * dma->segment_size; // 缓冲区偏移量
        
        // 设置下一个描述符地址
        *(volatile uint32_t *)(desc + NXTDESC_OFFSET) = next_desc_addr & 0xFFFFFFFC;
        *(volatile uint32_t *)(desc + NXTDESC_MSB_OFFSET) = next_desc_addr >> 32;
        
        // 设置缓冲区地址
        *(volatile uint32_t *)(desc + BUFFER_ADDR_OFFSET) = buffer_addr & 0xFFFFFFFF;
        *(volatile uint32_t *)(desc + BUFFER_ADDR_MSB_OFFSET) = buffer_addr >> 32;
        
        // 设置控制字段 - 缓冲区大小
        *(volatile uint32_t *)(desc + CONTROL_OFFSET) = dma->segment_size & 0x3FFFFFF;
        
        // 清除状态字段
        *(volatile uint32_t *)(desc + STATUS_OFFSET) = 0;
        
        // 初始化描述符状态
        dma->desc_status[i].processed = 0;
        dma->desc_status[i].status = 0;
        dma->desc_status[i].bytes_received = 0;
        dma->desc_status[i].is_sof = 0;
        dma->desc_status[i].is_eof = 0;
    }
    
    return 0;
}

// 启动S2MM DMA
int start_s2mm_dma(s2mm_dma_t *dma) {
    uint32_t dmacr, dmasr;
    uint64_t first_desc_addr = DMA_DESC_BASE_ADDR + DMA_DESC_ALL_SIZE/2; // S2MM描述符起始地址
    //uint64_t tail_desc_addr = (dma->desc_count - 1) * dma->desc_size + first_desc_addr;
    uint64_t tail_desc_addr = DMA_DESC_BASE_ADDR + DMA_DESC_ALL_SIZE/2;
    // 等待DMA处于停止状态
    dmasr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMASR);
    if (!(dmasr & DMASR_HALTED)) {
        // 如果DMA未停止，先停止它
        dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMACR);
        dmacr &= ~DMACR_RS;
        *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMACR) = dmacr;
        
        // 等待DMA停止
        do {
            dmasr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMASR);
        } while (!(dmasr & DMASR_HALTED));
    }
    
    // 软复位DMA
    dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMACR);
    dmacr |= DMACR_RESET;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMACR) = dmacr;
    
    // 等待复位完成
    do {
        dmacr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMACR);
    } while (dmacr & DMACR_RESET);
    
    // 设置当前描述符指针
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_CURDESC)     = first_desc_addr & 0xFFFFFFFC;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_CURDESC_MSB) = first_desc_addr >> 32;
    
    // 配置DMA控制寄存器 - 启用循环模式和中断
    dmacr = DMACR_CYCLIC | DMACR_IOC_IRQ | DMACR_ERR_IRQ;
    
    // 启动DMA
    dmacr |= DMACR_RS;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMACR) = dmacr;
    
    // 设置尾描述符指针
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_TAILDESC) = tail_desc_addr & 0xFFFFFFFC;
    *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_TAILDESC_MSB) = tail_desc_addr >> 32;
    
    dma->running = 1;
    printf("S2MM DMA started in cyclic mode\n");
    
    return 0;
}

// 清理S2MM DMA资源
void cleanup_s2mm_dma(s2mm_dma_t *dma) {
    if (dma->desc_status) {
        free(dma->desc_status);
    }

    if (dma->buffer) {
        free(dma->buffer);
    }

    if (dma->desc_base != MAP_FAILED) {
        munmap(dma->desc_base, DMA_DESC_ALL_SIZE);
    }

    if (dma->dma_regs != MAP_FAILED) {
        munmap(dma->dma_regs, 4096);
    }

    if (dma->event_fd >= 0) {
        close(dma->event_fd);
    }

    if (dma->data_fd >= 0) {
        close(dma->data_fd);
    }

    if (dma->dma_fd >= 0) {
        close(dma->dma_fd);
    }

    destroy_work_queue(&dma->work_queue);
}

// 保存接收到的帧到文件
int save_frame_to_file(s2mm_dma_t *dma, void *buffer, size_t size, int frame_index) {
    char filename[512];
    FILE *fp;
    
    // 创建文件名
    snprintf(filename, sizeof(filename), "%s/frame_%06d.dat", dma->output_dir, frame_index);
    
    // 打开文件
    fp = fopen(filename, "wb");
    if (!fp) {
        perror("Failed to open output file");
        return -1;
    }
    
    // 写入数据
    if (fwrite(buffer, 1, size, fp) != size) {
        perror("Failed to write data to file");
        fclose(fp);
        return -1;
    }
    
    fclose(fp);
    printf("Saved frame %d to %s, size: %zu bytes\n", frame_index, filename, size);
    
    return 0;
}

// 工作线程 - 处理工作队列中的项目
void *worker_thread(void *arg) {
    s2mm_dma_t *dma = (s2mm_dma_t *)arg;
    work_item_t item;
    
    printf("Worker thread started\n");
    
    while (dma->running) {
        // 从队列中获取工作项
        if (dequeue_work(&dma->work_queue, &item) == 0) {
            // 保存帧到文件
            save_frame_to_file(dma, item.buffer, item.size, item.frame_index);
        }
    }
    
    // 处理队列中剩余的工作项
    while (dma->work_queue.count > 0) {
        if (dequeue_work(&dma->work_queue, &item) == 0) {
            save_frame_to_file(dma, item.buffer, item.size, item.frame_index);
        }
    }
    
    printf("Worker thread exiting\n");
    return NULL;
}
// 处理S2MM描述符的状态
void process_descriptors(s2mm_dma_t *dma) {
    uint8_t *s2mm_desc_base = (uint8_t *)dma->desc_base;
    int sof_index = -1;
    int eof_index = -1;
    int found_frame = 0;

    // 使用静态变量记住上次检查的位置
    static int last_checked_index = 0;

    // 从上次检查的位置开始，遍历一圈描述符
    int i = last_checked_index;
    uint32_t checked_count = 0;

    while (checked_count < dma->desc_count) {
        uint8_t *desc = s2mm_desc_base + i * dma->desc_size;
        uint32_t status = *(uint32_t *)(desc + STATUS_OFFSET);

        // 如果描述符已完成且未处理
        if ((status & STATUS_COMPLETED) && !dma->desc_status[i].processed) {
            // 更新描述符状态
            dma->desc_status[i].status = status;
            dma->desc_status[i].bytes_received = status & 0x3FFFFFF; // 提取接收到的字节数
            dma->desc_status[i].is_sof = (status & STATUS_RXSOF) ? 1 : 0;
            dma->desc_status[i].is_eof = (status & STATUS_RXEOF) ? 1 : 0;

            // 检查SOF标志
            if (dma->desc_status[i].is_sof) {
                sof_index = i;
            }

            // 检查EOF标志
            if (dma->desc_status[i].is_eof && sof_index >= 0) {
                eof_index = i;
                found_frame = 1;
                // 更新下一次开始检查的位置为EOF之后的描述符
                last_checked_index = (i + 1) % dma->desc_count;
                break;
            }
        }

        // 移动到下一个描述符
        i = (i + 1) % dma->desc_count;
        checked_count++;
    }

    // 如果找到完整的帧
    if (found_frame) {
        size_t frame_size = 0;
        void *frame_buffer = NULL;

        // 计算帧大小
        if (sof_index <= eof_index || (sof_index > eof_index && sof_index > last_checked_index)) {
            // 帧在连续的描述符中，或者SOF在环形缓冲区的后半部分
            int start = sof_index;
            int end = eof_index;

            if (sof_index > eof_index) {
                // 帧跨越了环形缓冲区的边界
                end = eof_index + dma->desc_count;
            }

            // 计算总帧大小
            for (int j = start; j <= end; j++) {
                int idx = j % dma->desc_count;
                frame_size += dma->desc_status[idx].bytes_received;
            }

            // 分配帧缓冲区
            frame_buffer = malloc(frame_size);
            if (!frame_buffer) {
                perror("Failed to allocate frame buffer");
                return;
            }

            // 从C2H设备读取数据
            size_t offset = 0;
            for (int j = start; j <= end; j++) {
                int idx = j % dma->desc_count;
                size_t bytes = dma->desc_status[idx].bytes_received;
                off_t device_offset = idx * dma->segment_size;

                // 使用lseek设置读取位置
                if (lseek(dma->data_fd, device_offset, SEEK_SET) == -1) {
                    perror("Failed to seek in C2H device");
                    free(frame_buffer);
                    return;
                }

                // 从设备读取数据
                ssize_t bytes_read = 0;
                size_t total_read = 0;

                while (total_read < bytes) {
                    bytes_read = read(dma->data_fd, (uint8_t *)frame_buffer + offset + total_read, bytes - total_read);
                    if (bytes_read < 0) {
                        if (errno == EINTR) continue;
                        perror("Error reading from C2H device");
                        free(frame_buffer);
                        return;
                    }
                    total_read += bytes_read;
                }

                offset += bytes;

                // 标记描述符为已处理
                dma->desc_status[idx].processed = 1;
            }
        }

        // 提交工作项到队列
        dma->frame_count++;
        enqueue_work(&dma->work_queue, frame_buffer, frame_size, dma->frame_count);
        printf("Enqueued frame %d, size: %zu bytes (SOF: %d, EOF: %d)\n",
               dma->frame_count, frame_size, sof_index, eof_index);
    } else if (checked_count >= dma->desc_count) {
        // 如果检查了所有描述符但没有找到完整的帧，重置检查位置
        // 这可以防止在异常情况下卡住
        last_checked_index = 0;
    }
}

// 中断处理线程
void *s2mm_event_handler_thread(void *arg) {
    s2mm_dma_t *dma = (s2mm_dma_t *)arg;
    uint32_t event_data;
    ssize_t bytes_read;
    
    printf("S2MM中断处理线程启动, 等待中断\n");
    
    while (dma->running) {
        // 读取事件
        bytes_read = read(dma->event_fd, &event_data, sizeof(event_data));
        if (bytes_read <= 0) {
            if (errno == EAGAIN || errno == EINTR) {
                continue;
            }
            perror("Error reading event");
            break;
        }
        
        printf("Received s2mm interrupt event: 0x%08x\n", event_data);
        
        // 检查DMA状态
        uint32_t dmasr = *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMASR);
        
        // 清除中断标志
        if (dmasr & DMASR_IOC_IRQ) {
            *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMASR) = DMASR_IOC_IRQ;
            printf("IOC interrupt cleared\n");
            
            // 处理描述符
            process_descriptors(dma);
        }
        
        // 处理错误中断
        if (dmasr & DMASR_ERR_IRQ) {
            *(volatile uint32_t *)((uint8_t *)dma->dma_regs + S2MM_DMASR) = DMASR_ERR_IRQ;
            printf("Error s2mm interrupt received, DMA status: 0x%08x\n", dmasr);
            
            // 如果发生错误，可以选择是否停止DMA
            // 在这里我们选择继续运行，只记录错误
        }
    }
    
    return NULL;
}

// 主函数
int main(int argc, char *argv[]) {
    mm2s_dma_t mm2s_dma;
    s2mm_dma_t s2mm_dma;
    int ret;
    
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input file> <output_directory>\n", argv[0]);
        return 1;
    }
   


    // 检查输出目录是否存在
    struct stat st = {0};
    if (stat(argv[2], &st) == -1) {
        // 目录不存在，创建它
        if (mkdir(argv[2], 0755) == -1) {
            perror("Failed to create output directory");
            return 1;
        }
    } else if (!S_ISDIR(st.st_mode)) {
        fprintf(stderr, "%s is not a directory\n", argv[2]);
        return 1;
    }
    
	printf("initial s2mm !\n");

    // 初始化DMA
    ret = init_s2mm_dma(&s2mm_dma, argv[2]);
    if (ret < 0) {
        fprintf(stderr, "Failed to initialize S2MM DMA\n");
        return 1;
    }
    
    // 设置S2MM描述符
    ret = setup_s2mm_descriptors(&s2mm_dma);
    if (ret < 0) {
        fprintf(stderr, "Failed to setup S2MM descriptors\n");
        cleanup_s2mm_dma(&s2mm_dma);
        return 1;
    }
    
    // 创建工作线程
    ret = pthread_create(&s2mm_dma.worker_thread, NULL, worker_thread, &s2mm_dma);
    if (ret < 0) {
        perror("Failed to create worker thread");
        cleanup_s2mm_dma(&s2mm_dma);
        return 1;
    }
    
    // 创建事件处理线程
    ret = pthread_create(&s2mm_dma.event_thread, NULL, s2mm_event_handler_thread, &s2mm_dma);
    if (ret < 0) {
        perror("Failed to create event thread");
        s2mm_dma.running = 0;
        pthread_join(s2mm_dma.worker_thread, NULL);
        cleanup_s2mm_dma(&s2mm_dma);
        return 1;
    }
    
    // 启动DMA传输
    ret = start_s2mm_dma(&s2mm_dma);
    if (ret < 0) {
        fprintf(stderr, "Failed to start S2MM DMA\n");
        s2mm_dma.running = 0;
        pthread_join(s2mm_dma.event_thread, NULL);
        pthread_join(s2mm_dma.worker_thread, NULL);
        cleanup_s2mm_dma(&s2mm_dma);
        return 1;
    }
   

	printf("S2MM ready!\n");



    // 初始化MM2S DMA
    ret = init_mm2s_dma(&mm2s_dma, argv[1]);
    if (ret < 0) {
        fprintf(stderr, "Failed to initialize DMA\n");
        return 1;
    }
    
    // 加载文件到缓冲区
    ret = load_file_to_buffer(&mm2s_dma, argv[1]);
    if (ret < 0) {
        fprintf(stderr, "Failed to load file to buffer\n");
        return 1;
    }
    
	printf("setup mm2s descriptors!\n");
    // 设置MM2S描述符
    ret = setup_mm2s_descriptors(&mm2s_dma);
    if (ret < 0) {
        fprintf(stderr, "Failed to setup MM2S descriptors\n");
        return 1;
    }
    
    // 创建事件处理线程
    ret = pthread_create(&mm2s_dma.event_thread, NULL, mm2s_event_handler_thread, &mm2s_dma);
    if (ret < 0) {
        perror("Failed to create event thread");
        return 1;
    }
    
    // 启动DMA传输
    ret = start_mm2s_dma(&mm2s_dma);
    if (ret < 0) {
        fprintf(stderr, "Failed to start MM2S DMA\n");
        return 1;
    }
    
    // 等待事件处理线程结束
    pthread_join(mm2s_dma.event_thread, NULL);
    printf("MM2S DMA is done. \n");







    
    // 停止DMA
    s2mm_dma.running = 0;
    
    // 停止DMA控制器
    uint32_t dmacr = *(volatile uint32_t *)((uint8_t *)s2mm_dma.dma_regs + S2MM_DMACR);
    dmacr &= ~DMACR_RS;
    *(volatile uint32_t *)((uint8_t *)s2mm_dma.dma_regs + S2MM_DMACR) = dmacr;
    
    printf("waiting s2mm dma done ..... \n");
    // 等待线程结束
    pthread_join(s2mm_dma.event_thread, NULL);
    pthread_join(s2mm_dma.worker_thread, NULL);
    
    // 清理资源
    cleanup_s2mm_dma(&s2mm_dma);

    // mm2s清理资源
    if (mm2s_dma.buffer) {
        free(mm2s_dma.buffer);
    }
    munmap(mm2s_dma.desc_base, DMA_DESC_ALL_SIZE);
    munmap(mm2s_dma.dma_regs, 4096);
    close(mm2s_dma.event_fd);
    close(mm2s_dma.data_fd);
    close(mm2s_dma.dma_fd);
    
    printf("DMA transfer completed\n");
    printf("S2MM DMA stopped. Received %d frames.\n", s2mm_dma.frame_count);
    return 0;
}



/**
 * 打印MM2S DMA控制器的寄存器和描述符信息
 * @param mm2s_dma MM2S DMA控制器结构体指针
 * @param verbose 是否打印详细信息
 */
void print_mm2s_dma_registers(mm2s_dma_t *mm2s_dma)
{
    if (!mm2s_dma) {
        printf("[ERROR] MM2S DMA结构体指针为NULL\n");
        return;
    }

    volatile uint32_t *dma_regs = mm2s_dma->dma_regs;
    volatile uint32_t *desc_base = mm2s_dma->desc_base;

    if (!dma_regs) {
        printf("[ERROR] MM2S DMA寄存器指针为NULL\n");
        return;
    }

    printf("\n===== MM2S DMA寄存器状态 =====\n");

    // 控制寄存器 (MM2S_DMACR, 0x00)
    uint32_t dmacr = dma_regs[0x00/4];
    printf("MM2S控制寄存器(0x00): 0x%08x\n", dmacr);
    printf("  - 运行状态: %s\n", (dmacr & 0x1) ? "启用" : "禁用");
    printf("  - 复位状态: %s\n", (dmacr & 0x4) ? "复位中" : "正常");
    printf("  - Keyhole模式: %s\n", (dmacr & 0x8) ? "启用" : "禁用");
    printf("  - 循环模式: %s\n", (dmacr & 0x10) ? "启用" : "禁用");
    printf("  - IOC_IrqEn: %s\n", (dmacr & 0x1000) ? "启用" : "禁用");
    printf("  - Dly_IrqEn: %s\n", (dmacr & 0x2000) ? "启用" : "禁用");
    printf("  - Err_IrqEn: %s\n", (dmacr & 0x4000) ? "启用" : "禁用");
    printf("  - IRQThreshold: %u\n", (dmacr >> 16) & 0xFF);
    printf("  - IRQDelay: %u\n", (dmacr >> 24) & 0xFF);

    // 状态寄存器 (MM2S_DMASR, 0x04)
    uint32_t dmasr = dma_regs[0x04/4];
    printf("MM2S状态寄存器(0x04): 0x%08x\n", dmasr);
    printf("  - DMA引擎状态: %s\n", (dmasr & 0x1) ? "停止" : "运行中");
    printf("  - 空闲状态: %s\n", (dmasr & 0x2) ? "空闲" : "忙碌");
    printf("  - DMA内部错误: %s\n", (dmasr & 0x10) ? "有错误" : "无错误");
    printf("  - DMA从属错误: %s\n", (dmasr & 0x20) ? "有错误" : "无错误");
    printf("  - DMA解码错误: %s\n", (dmasr & 0x40) ? "有错误" : "无错误");
    printf("  - SG内部错误: %s\n", (dmasr & 0x100) ? "有错误" : "无错误");
    printf("  - SG从属错误: %s\n", (dmasr & 0x200) ? "有错误" : "无错误");
    printf("  - SG解码错误: %s\n", (dmasr & 0x400) ? "有错误" : "无错误");
    printf("  - IOC中断: %s\n", (dmasr & 0x1000) ? "已触发" : "未触发");
    printf("  - 延迟中断: %s\n", (dmasr & 0x2000) ? "已触发" : "未触发");
    printf("  - 错误中断: %s\n", (dmasr & 0x4000) ? "已触发" : "未触发");
    printf("  - IRQThresholdStatus: %u\n", (dmasr >> 16) & 0xFF);
    printf("  - IRQDelayStatus: %u\n", (dmasr >> 24) & 0xFF);

    // 当前描述符地址
    printf("MM2S当前描述符地址(0x08): 0x%08x\n", dma_regs[0x08/4]);
    printf("MM2S当前描述符MSB(0x0C): 0x%08x\n", dma_regs[0x0C/4]);

    // 尾描述符地址
    printf("MM2S尾描述符地址(0x10): 0x%08x\n", dma_regs[0x10/4]);
    printf("MM2S尾描述符MSB(0x14): 0x%08x\n", dma_regs[0x14/4]);

    // 描述符信息
    if (desc_base) {
        printf("\n===== MM2S描述符内容 =====\n");

        // 假设描述符结构为8个32位字
        printf("描述符地址: %p\n", (void*)desc_base);
        printf("  [0] 下一描述符地址: 0x%08x\n", desc_base[0]);
        printf("  [1] 下一描述符MSB: 0x%08x\n", desc_base[1]);
        printf("  [2] 缓冲区地址: 0x%08x\n", desc_base[2]);
        printf("  [3] 缓冲区地址MSB: 0x%08x\n", desc_base[3]);
        printf("  [4] 保留: 0x%08x\n", desc_base[4]);

        // 控制字
        uint32_t control = desc_base[6];
        printf("  [5] 控制: 0x%08x\n", control);
        printf("      - 缓冲区长度: %u 字节\n", control & 0x3FFFFFF);
        printf("      - SOP: %s\n", (control & 0x8000000) ? "是" : "否");
        printf("      - EOP: %s\n", (control & 0x4000000) ? "是" : "否");

        // 状态字
        uint32_t status = desc_base[7];
        printf("  [6] 状态: 0x%08x\n", status);
        printf("      - 完成状态: %s\n", (status & 0x80000000) ? "已完成" : "未完成");
        printf("      - 解码错误: %s\n", (status & 0x40000000) ? "有错误" : "无错误");
        printf("      - 从属错误: %s\n", (status & 0x20000000) ? "有错误" : "无错误");
        printf("      - 内部错误: %s\n", (status & 0x10000000) ? "有错误" : "无错误");
        printf("      - 实际传输长度: %u 字节\n", status & 0x3FFFFFF);

        printf("  [7] 应用数据: 0x%08x\n", desc_base[7]);

        // 如果是详细模式，打印更多描述符
        if (mm2s_dma->desc_count > 1) {
            printf("\n===== 额外的MM2S描述符 =====\n");
            for (uint32_t i = 1; i < mm2s_dma->desc_count; i++) {
                volatile uint32_t *next_desc = desc_base + (i * 8); // 假设每个描述符占8个32位字
                printf("描述符 #%d 地址: %p\n", i, (void*)next_desc);
                printf("  [0] 下一描述符地址: 0x%08x\n", next_desc[0]);
                printf("  [1] 下一描述符MSB: 0x%08x\n", next_desc[1]);
                printf("  [2] 缓冲区地址: 0x%08x\n", next_desc[2]);
                printf("  [3] 缓冲区地址MSB: 0x%08x\n", next_desc[3]);
                printf("  [5] 控制: 0x%08x\n", next_desc[5]);
                printf("  [6] 状态: 0x%08x\n", next_desc[6]);
            }
        }
    } else {
        printf("[警告] MM2S描述符基地址为NULL\n");
    }

    // 打印其他重要寄存器（如果有）
    if (1) {
        printf("\n===== 其他MM2S寄存器 =====\n");
        printf("MM2S_SA(0x18): 0x%08x\n", dma_regs[0x18/4]);
        printf("MM2S_SA_MSB(0x1C): 0x%08x\n", dma_regs[0x1C/4]);
        printf("MM2S_LENGTH(0x28): 0x%08x\n", dma_regs[0x28/4]);
    }

    printf("\n");
}

void print_s2mm_dma_registers(s2mm_dma_t *dma)
{
    if (!dma) {
        printf("[ERROR] S2MM DMA结构体指针为NULL\n");
        return;
    }

    volatile uint32_t *dma_regs  = dma->dma_regs;
    volatile uint32_t *desc_base = dma->desc_base;

    if (!dma_regs) {
        printf("[ERROR] S2MM DMA寄存器指针为NULL\n");
        return;
    }

    printf("\n===== S2MM DMA寄存器状态 =====\n");

    // 控制寄存器 (S2MM_DMACR, 0x00)
    uint32_t dmacr = dma_regs[0x30/4];
    printf("S2MM控制寄存器(0x00): 0x%08x\n", dmacr);
    printf("  - 运行状态: %s\n", (dmacr & 0x1) ? "启用" : "禁用");
    printf("  - 复位状态: %s\n", (dmacr & 0x4) ? "复位中" : "正常");
    printf("  - Keyhole模式: %s\n", (dmacr & 0x8) ? "启用" : "禁用");
    printf("  - 循环模式: %s\n", (dmacr & 0x10) ? "启用" : "禁用");
    printf("  - IOC_IrqEn: %s\n", (dmacr & 0x1000) ? "启用" : "禁用");
    printf("  - Dly_IrqEn: %s\n", (dmacr & 0x2000) ? "启用" : "禁用");
    printf("  - Err_IrqEn: %s\n", (dmacr & 0x4000) ? "启用" : "禁用");
    printf("  - IRQThreshold: %u\n", (dmacr >> 16) & 0xFF);
    printf("  - IRQDelay: %u\n", (dmacr >> 24) & 0xFF);

    // 状态寄存器 (S2MM_DMASR, 0x04)
    uint32_t dmasr = dma_regs[0x34/4];
    printf("S2MM状态寄存器(0x04): 0x%08x\n", dmasr);
    printf("  - DMA引擎状态: %s\n", (dmasr & 0x1) ? "停止" : "运行中");
    printf("  - 空闲状态: %s\n", (dmasr & 0x2) ? "空闲" : "忙碌");
    printf("  - DMA内部错误: %s\n", (dmasr & 0x10) ? "有错误" : "无错误");
    printf("  - DMA从属错误: %s\n", (dmasr & 0x20) ? "有错误" : "无错误");
    printf("  - DMA解码错误: %s\n", (dmasr & 0x40) ? "有错误" : "无错误");
    printf("  - SG内部错误: %s\n", (dmasr & 0x100) ? "有错误" : "无错误");
    printf("  - SG从属错误: %s\n", (dmasr & 0x200) ? "有错误" : "无错误");
    printf("  - SG解码错误: %s\n", (dmasr & 0x400) ? "有错误" : "无错误");
    printf("  - IOC中断: %s\n", (dmasr & 0x1000) ? "已触发" : "未触发");
    printf("  - 延迟中断: %s\n", (dmasr & 0x2000) ? "已触发" : "未触发");
    printf("  - 错误中断: %s\n", (dmasr & 0x4000) ? "已触发" : "未触发");
    printf("  - IRQThresholdStatus: %u\n", (dmasr >> 16) & 0xFF);
    printf("  - IRQDelayStatus: %u\n", (dmasr >> 24) & 0xFF);

    // 当前描述符地址
    printf("S2MM当前描述符地址(0x38): 0x%08x\n", dma_regs[0x38/4]);
    printf("S2MM当前描述符MSB(0x3C): 0x%08x\n", dma_regs[0x3C/4]);

    // 尾描述符地址
    printf("S2MM尾描述符地址(0x40): 0x%08x\n", dma_regs[0x40/4]);
    printf("S2MM尾描述符MSB(0x44): 0x%08x\n", dma_regs[0x44/4]);

    // 描述符信息
    if (desc_base) {
        printf("\n===== S2MM描述符内容 =====\n");

        // 假设描述符结构为8个32位字
        printf("描述符地址: %p\n", (void*)desc_base);
        printf("  [0] 下一描述符地址: 0x%08x\n", desc_base[0]);
        printf("  [1] 下一描述符MSB: 0x%08x\n", desc_base[1]);
        printf("  [2] 缓冲区地址: 0x%08x\n", desc_base[2]);
        printf("  [3] 缓冲区地址MSB: 0x%08x\n", desc_base[3]);
        printf("  [4] 保留: 0x%08x\n", desc_base[4]);

        // 控制字
        uint32_t control = desc_base[6];
        printf("  [5] 控制: 0x%08x\n", control);
        printf("      - 缓冲区长度: %u 字节\n", control & 0x3FFFFFF);
        printf("      - SOP: %s\n", (control & 0x8000000) ? "是" : "否");
        printf("      - EOP: %s\n", (control & 0x4000000) ? "是" : "否");

        // 状态字
        uint32_t status = desc_base[7];
        printf("  [6] 状态: 0x%08x\n", status);
        printf("      - 完成状态: %s\n", (status & 0x80000000) ? "已完成" : "未完成");
        printf("      - 解码错误: %s\n", (status & 0x40000000) ? "有错误" : "无错误");
        printf("      - 从属错误: %s\n", (status & 0x20000000) ? "有错误" : "无错误");
        printf("      - 内部错误: %s\n", (status & 0x10000000) ? "有错误" : "无错误");
        printf("      - 实际传输长度: %u 字节\n", status & 0x3FFFFFF);

        printf("  [7] 应用数据: 0x%08x\n", desc_base[7]);

        // 如果是详细模式，打印更多描述符
        if (dma->desc_count > 1) {
            printf("\n===== 额外的S2MM描述符 =====\n");
            //for (uint32_t i = 1; i < dma->desc_count; i++) {
            for (uint32_t i = 1; i < 3; i++) {
                volatile uint32_t *next_desc = desc_base + (i * 8); // 假设每个描述符占8个32位字
                printf("描述符 #%d 地址: %p\n", i, (void*)next_desc);
                printf("  [0] 下一描述符地址: 0x%08x\n", next_desc[0]);
                printf("  [1] 下一描述符MSB: 0x%08x\n", next_desc[1]);
                printf("  [2] 缓冲区地址: 0x%08x\n", next_desc[2]);
                printf("  [3] 缓冲区地址MSB: 0x%08x\n", next_desc[3]);
                printf("  [5] 控制: 0x%08x\n", next_desc[5]);
                printf("  [6] 状态: 0x%08x\n", next_desc[6]);
            }
        }
    } else {
        printf("[警告] S2MM描述符基地址为NULL\n");
    }

    // 打印其他重要寄存器（如果有）
    if (1) {
        printf("\n===== 其他S2MM寄存器 =====\n");
        printf("S2MM_SA    (0x48): 0x%08x\n", dma_regs[0x48/4]);
        printf("S2MM_SA_MSB(0x4C): 0x%08x\n", dma_regs[0x4C/4]);
        printf("S2MM_LENGTH(0x58): 0x%08x\n", dma_regs[0x58/4]);
    }

    printf("\n");
}
