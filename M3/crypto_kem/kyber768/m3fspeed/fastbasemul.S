// basemul_asm_opt_16_32 basemul_asm_acc_opt_32_32 basemul_asm_acc_opt_32_16
#include "macros.i"

.syntax unified
.thumb

// void basemul_asm_opt_16_32(int32_t * r_tmp, const int16_t * a, const int16_t * b, const int16_t * aprime_ptr)
.global basemul_asm_opt_16_32
.type basemul_asm_opt_16_32, %function
.align 2
basemul_asm_opt_16_32:
  push.w {r4-r11, lr}
  rtmp_ptr .req r0
  aptr    .req r1
  bptr    .req r2
  aprime_ptr .req r3
  poly0   .req r4
  poly1   .req r6
  poly2   .req r5
  poly3   .req r7
  q       .req r8
  alpha2  .req r9
  qinv    .req r10
  tmp     .req r11
  tmp2    .req r12
  loop    .req r14

  // movw.w  q, #3329
  ### qinv=0x6ba8f301
  // movw qinv, #62209
  // movt qinv, #27560
  // mov.w alpha2, #8

  movw loop, #64
  1:
    ldrsh.w poly1, [aptr,  #2]
    ldrsh.w poly0, [aptr], #4
    ldrsh.w poly3, [bptr, #2]
    ldrsh.w poly2, [bptr], #4

    ldrsh.w tmp, [aprime_ptr], #2
    mul.w tmp, tmp, poly3
    mla.w tmp, poly0, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    mul.w tmp, poly0, poly3
    mla.w tmp, poly1, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    ldrsh.w poly1, [aptr,  #2]
    ldrsh.w poly0, [aptr], #4
    ldrsh.w poly3, [bptr, #2]
    ldrsh.w poly2, [bptr], #4

    ldrsh.w tmp, [aprime_ptr], #2
    mul.w tmp, tmp, poly3
    mla.w tmp, poly0, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    mul.w tmp, poly0, poly3
    mla.w tmp, poly1, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    subs.w loop, #1
  bne.w 1b

  pop.w {r4-r11, pc}



// basemul_asm_acc_opt_32_32(int32_t* r_tmp, int16_t* aptr, int16_t* bptr, int16_t* aprimeptr);
.global basemul_asm_acc_opt_32_32
.type basemul_asm_acc_opt_32_32, %function
.align 2
basemul_asm_acc_opt_32_32:
  push.w {r4-r11, lr}
  rtmp_ptr    .req r0
  aptr    .req r1
  bptr    .req r2
  aprime_ptr .req r3
  poly0   .req r4
  poly1   .req r6
  poly2   .req r5
  poly3   .req r7
  q       .req r8
  alpha2  .req r9
  qinv    .req r10
  tmp     .req r11
  tmp2    .req r12
  loop    .req r14

  // movw.w  q, #3329
  ### qinv=0x6ba8f301
  // movw qinv, #62209
  // movt qinv, #27560
  // mov.w alpha2, #8

  movw loop, #64
  1:
    ldrsh.w poly1, [aptr,  #2]
    ldrsh.w poly0, [aptr], #4
    ldrsh.w poly3, [bptr, #2]
    ldrsh.w poly2, [bptr], #4

    ldrsh.w tmp, [aprime_ptr], #2
    ldr.w tmp2, [rtmp_ptr]
    mla.w tmp, tmp, poly3, tmp2
    mla.w tmp, poly0, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    ldr.w tmp2, [rtmp_ptr]
    mla.w tmp, poly0, poly3, tmp2
    mla.w tmp, poly1, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    ldrsh.w poly1, [aptr,  #2]
    ldrsh.w poly0, [aptr], #4
    ldrsh.w poly3, [bptr, #2]
    ldrsh.w poly2, [bptr], #4

    ldrsh.w tmp, [aprime_ptr], #2
    ldr.w tmp2, [rtmp_ptr]
    mla.w tmp, tmp, poly3, tmp2
    mla.w tmp, poly0, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    ldr.w tmp2, [rtmp_ptr]
    mla.w tmp, poly0, poly3, tmp2
    mla.w tmp, poly1, poly2, tmp
    str.w tmp, [rtmp_ptr], #4

    subs.w loop, #1
  bne.w 1b

  pop.w {r4-r11, pc}


.unreq poly0 
.unreq poly1 
.unreq poly2 
.unreq poly3 
.unreq q     
.unreq alpha2
.unreq qinv  
.unreq tmp   
.unreq tmp2  
.unreq loop
.unreq rtmp_ptr

// basemul_asm_acc_opt_32_16(int16_t* rptr, int16_t* aptr, int16_t* bptr, int16_t* aprimeptr, int32_t* r_tmp);
.global basemul_asm_acc_opt_32_16
.type basemul_asm_acc_opt_32_16, %function
.align 2
basemul_asm_acc_opt_32_16:
  push.w {r4-r11, lr}
  rptr    .req r0
  aptr    .req r1
  bptr    .req r2
  aprime_ptr .req r3
  rtmp_ptr .req r4
  poly0   .req r5
  poly1   .req r7
  poly2   .req r6
  poly3   .req r8
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12
  loop    .req r14
  tmp2    .req r14

  ldr.w rtmp_ptr, [sp, #9*4]
  movw.w  q, #3329
  ### qinv=0x6ba8f301
  movw qinv, #62209
  movt qinv, #27560
  mov.w alpha2, #8

  movw loop, #64
  1:
    push {loop}

    ldrsh.w poly1, [aptr,  #2]
    ldrsh.w poly0, [aptr], #4
    ldrsh.w poly3, [bptr, #2]
    ldrsh.w poly2, [bptr], #4

    ldrsh.w tmp, [aprime_ptr], #2
    ldr.w tmp2, [rtmp_ptr], #4
    mla.w tmp, tmp, poly3, tmp2
    mla.w tmp, poly0, poly2, tmp
    plant_red q, alpha2, qinv, tmp
    strh.w tmp, [rptr], #2

    ldr.w tmp2, [rtmp_ptr], #4
    mla.w tmp, poly0, poly3, tmp2
    mla.w tmp, poly1, poly2, tmp
    plant_red q, alpha2, qinv, tmp
    strh.w tmp, [rptr], #2

    ldrsh.w poly1, [aptr,  #2]
    ldrsh.w poly0, [aptr], #4
    ldrsh.w poly3, [bptr, #2]
    ldrsh.w poly2, [bptr], #4

    ldrsh.w tmp, [aprime_ptr], #2
    ldr.w tmp2, [rtmp_ptr], #4
    mla.w tmp, tmp, poly3, tmp2
    mla.w tmp, poly0, poly2, tmp
    plant_red q, alpha2, qinv, tmp
    strh.w tmp, [rptr], #2

    ldr.w tmp2, [rtmp_ptr], #4
    mla.w tmp, poly0, poly3, tmp2
    mla.w tmp, poly1, poly2, tmp
    plant_red q, alpha2, qinv, tmp
    strh.w tmp, [rptr], #2
    pop {loop}
    subs.w loop, #1
  bne.w 1b

  pop.w {r4-r11, pc}
