// doublebasemul_asm_cache_16_32 doublebasemul_asm_acc_cache_32_32 doublebasemul_asm_acc_cache_32_16
#include "macros.i"

.syntax unified
.thumb

// doublebasemul_asm_cache_16_32(int32_t r_tmp_ptr[4], int16_t aprimeptr[2], int16_t aptr[4], int16_t bptr[4], int32_t zeta);
.global doublebasemul_asm_cache_16_32
.type doublebasemul_asm_cache_16_32, %function
.align 2
doublebasemul_asm_cache_16_32:
  push.w {r4-r11, lr}

  rtmp_ptr   .req r0
  aprime_ptr .req r1
  aptr    .req r2
  bptr    .req r3
  zeta    .req r4
  poly0   .req r6
  poly1   .req r5
  poly2   .req r8
  poly3   .req r7
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12

  ldr.w zeta, [sp, #9*4] //load zeta from stack

  movw.w  q, #3329
  ### qinv=0x6ba8f301
  // movw qinv, #62209
  // movt qinv, #27560
  mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  strh.w tmp, [aprime_ptr, #0]
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #0]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #4]

  neg.w zeta, zeta

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  strh.w tmp, [aprime_ptr, #2]
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #8]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #12]

  pop.w {r4-r11, pc}


// doublebasemul_asm_acc_cache_32_32(int32_t r_tmp_ptr[4], int16_t aprimeptr[2], int16_t aptr[4], int16_t bptr[4], int32_t zeta);
.global doublebasemul_asm_acc_cache_32_32
.type doublebasemul_asm_acc_cache_32_32, %function
.align 2
doublebasemul_asm_acc_cache_32_32:
  push.w {r4-r11, lr}

  rtmp_ptr   .req r0
  aprime_ptr .req r1
  aptr    .req r2
  bptr    .req r3
  zeta    .req r4
  poly0   .req r6
  poly1   .req r5
  poly2   .req r8
  poly3   .req r7
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12
  tmp2    .req r14

  ldr.w zeta, [sp, #9*4] 
  movw.w  q, #3329
  ### qinv=0x6ba8f301
  // movw qinv, #62209
  // movt qinv, #27560
  mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  strh.w tmp, [aprime_ptr, #0]
  ldr.w tmp2, [rtmp_ptr, #0]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #0]
  
  ldr.w tmp2, [rtmp_ptr, #4]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #4]

  neg.w zeta, zeta

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  strh.w tmp, [aprime_ptr, #2]
  ldr.w tmp2, [rtmp_ptr, #8]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #8]

  ldr.w tmp2, [rtmp_ptr, #12]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #12]

  pop.w {r4-r11, pc}

// doublebasemul_asm_acc_cache_32_16(int16_t r[4], int32_t r_tmp_ptr[4], int16_t aprimeptr[2], int16_t a_ptr[4], int16_t b_ptr[4], int32_t zeta);
.unreq rtmp_ptr
.unreq aprime_ptr
.unreq aptr
.unreq bptr
.unreq zeta
.unreq tmp2

.global doublebasemul_asm_acc_cache_32_16
.type doublebasemul_asm_acc_cache_32_16, %function
.align 2
doublebasemul_asm_acc_cache_32_16:
  push.w {r4-r11, lr}

  rptr    .req r0
  rtmp_ptr .req r1
  aprime_ptr .req r2
  aptr    .req r3
  bptr    .req r4
  zeta    .req r14
  poly0   .req r6
  poly1   .req r5
  poly2   .req r8
  poly3   .req r7
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12
  tmp2    .req r4

  ldr.w bptr, [sp, #9*4]
  ldr.w zeta, [sp, #10*4]

  movw.w  q, #3329
  ### qinv=0x6ba8f301
  movw qinv, #62209
  movt qinv, #27560
  mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  strh.w tmp, [aprime_ptr, #0]
  ldr.w tmp2, [rtmp_ptr, #0]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #0]
  
  ldr.w tmp2, [rtmp_ptr, #4]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #2]

  neg.w zeta, zeta

  ldr.w bptr, [sp, #9*4]
  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  strh.w tmp, [aprime_ptr, #2]
  ldr.w tmp2, [rtmp_ptr, #8]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #4]

  ldr.w tmp2, [rtmp_ptr, #12]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #6]

  pop.w {r4-r11, pc}


// doublebasemul_asm_opt_16_32 doublebasemul_asm_acc_opt_32_32 doublebasemul_asm_acc_opt_32_16
.unreq rtmp_ptr
.unreq aprime_ptr
.unreq aptr
.unreq bptr
.unreq zeta
.unreq tmp2

// doublebasemul_asm_opt_16_32(int32_t r_tmp_ptr[4], int16_t aprimeptr[2], int16_t aptr[4], int16_t bptr[4]);
.global doublebasemul_asm_opt_16_32
.type doublebasemul_asm_opt_16_32, %function
.align 2
doublebasemul_asm_opt_16_32:
  push.w {r4-r11, lr}

  rtmp_ptr   .req r0
  aprime_ptr .req r1
  aptr    .req r2
  bptr    .req r3
  tmp2    .req r4
  poly0   .req r6
  poly1   .req r5
  poly2   .req r8
  poly3   .req r7
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12

  // movw.w  q, #3329
  ### qinv=0x6ba8f301
  // movw qinv, #62209
  // movt qinv, #27560
  // mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]

  ldrsh.w tmp, [aprime_ptr, #0]
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #0]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #4]

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  ldrsh.w tmp, [aprime_ptr, #2]
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #8]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #12]

  pop.w {r4-r11, pc}

// doublebasemul_asm_acc_opt_32_32(int32_t r_tmp_ptr[4], int16_t aprimeptr[2], int16_t aptr[4], int16_t bptr[4]);
.global doublebasemul_asm_acc_opt_32_32
.type doublebasemul_asm_acc_opt_32_32, %function
.align 2
doublebasemul_asm_acc_opt_32_32:
  push.w {r4-r11, lr}

  rtmp_ptr   .req r0
  aprime_ptr .req r1
  aptr    .req r2
  bptr    .req r3
  tmp2    .req r4
  poly0   .req r6
  poly1   .req r5
  poly2   .req r8
  poly3   .req r7
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12

  // movw.w  q, #3329
  ### qinv=0x6ba8f301
  // movw qinv, #62209
  // movt qinv, #27560
  // mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]

  ldrsh.w tmp, [aprime_ptr, #0]
  ldr.w tmp2, [rtmp_ptr, #0]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #0]
  
  ldr.w tmp2, [rtmp_ptr, #4]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #4]

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  ldrsh.w tmp, [aprime_ptr, #2]
  ldr.w tmp2, [rtmp_ptr, #8]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  str.w tmp, [rtmp_ptr, #8]

  ldr.w tmp2, [rtmp_ptr, #12]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  str.w tmp, [rtmp_ptr, #12]

  pop.w {r4-r11, pc}

// doublebasemul_asm_acc_opt_32_16(int16_t r_ptr[4], int32_t r_tmp_ptr[4], int16_t aprimeptr[2], int16_t aptr[4], int16_t bptr[4]);
.unreq rtmp_ptr
.unreq aprime_ptr
.unreq aptr
.unreq bptr
.unreq tmp2

.global doublebasemul_asm_acc_opt_32_16
.type doublebasemul_asm_acc_opt_32_16, %function
.align 2
doublebasemul_asm_acc_opt_32_16:
  push.w {r4-r11, lr}

  rptr    .req r0
  rtmp_ptr .req r1
  aprime_ptr .req r2
  aptr    .req r3
  bptr    .req r4
  poly0   .req r6
  poly1   .req r5
  poly2   .req r8
  poly3   .req r7
  q       .req r9
  alpha2  .req r10
  qinv    .req r11
  tmp     .req r12
  tmp2    .req r14

  ldr.w bptr, [sp, #9*4]

  movw.w  q, #3329
  ### qinv=0x6ba8f301
  movw qinv, #62209
  movt qinv, #27560
  mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]

  ldrsh.w tmp, [aprime_ptr, #0]
  ldr.w tmp2, [rtmp_ptr, #0]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #0]
  
  ldr.w tmp2, [rtmp_ptr, #4]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #2]

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  ldrsh.w tmp, [aprime_ptr, #2]
  ldr.w tmp2, [rtmp_ptr, #8]
  mla.w tmp, tmp, poly3, tmp2
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #4]

  ldr.w tmp2, [rtmp_ptr, #12]
  mla.w tmp, poly0, poly3, tmp2
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #6]

  pop.w {r4-r11, pc}