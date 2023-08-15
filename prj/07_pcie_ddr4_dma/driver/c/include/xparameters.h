//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年05月08日 星期一 19时48分09秒
//========================================================================

#ifndef __XPARAMETERS_H__
#define __XPARAMETERS_H__

#define XPAR_XIIC_NUM_INSTANCES     1          /* Number of instances */

#define XPAR_IIC_0_DEVICE_ID        90         /* Device ID for instance */
#define XPAR_IIC_0_BASEADDR         0x00840000 /* Device base address */
#define XPAR_IIC_0_TEN_BIT_ADR      FALSE      /* Supports 10 bit addresses */
#define XPAR_IIC_0_GPO_WIDTH        1

#define XPAR_IIC_1_DEVICE_ID        90         /* Device ID for instance */
#define XPAR_IIC_1_BASEADDR         0x00840000 /* Device base address */
#define XPAR_IIC_1_TEN_BIT_ADR      FALSE      /* Supports 10 bit addresses */
#define XPAR_IIC_1_GPO_WIDTH        1

#define XPAR_INTC_0_DEVICE_ID           1
#define XPAR_INTC_MAX_NUM_INTR_INPUTS   1
#define XPAR_INTC_0_IIC_0_VEC_ID        1
#define IIC_INTR_ID                     1
#define XPAR_XINTC_NUM_INSTANCES        1
#define XPAR_INTC_0_BASEADDR         0x00800000//, /* Register base address */
#define XPAR_INTC_0_ACK_BEFORE       0         //, /* Ack before or after service */
#define XPAR_INTC_1_DEVICE_ID        1         //, /* Unique ID  of device */
#define XPAR_INTC_1_BASEADDR         0x00800000//, /* Register base address */
#define XPAR_INTC_1_ACK_BEFORE       0         //, /* Ack before or after service */





#endif
