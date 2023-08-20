//========================================================================
//        author   : masw
//        email    : masw@masw.tech     
//        creattime: 2023年08月20日 星期日 23时25分15秒
//========================================================================

/
#ifndef __ALEX_IIC_H__
#define __ALEX_IIC_H__


#include <stdint.h>
#include <stddef.h>

typedef int8_t   s8 ;
typedef int16_t  s16;
typedef int32_t  s32;
typedef int64_t  s64;
typedef uint8_t  u8 ;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

//typedef intptr_t INTPTR;
//typedef uintptr_t UINTPTR;

int alex_iic_wb_read (uintptr_t baseaddr, u8 iicaddr, u8 regaddr, u16 *readback);
int alex_iic_wb_write(uintptr_t baseaddr, u8 iicaddr, u8 regaddr, u16 *readback);



#endif
