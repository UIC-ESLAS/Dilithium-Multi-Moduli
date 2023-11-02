#include "macros.i"

.syntax unified
.thumb


.global doublebasemul_asm
.type doublebasemul_asm, %function
.align 2
doublebasemul_asm:
  push.w {r4-r11, lr}

  rptr    .req r0
  aptr    .req r1
  bptr    .req r2
  zeta    .req r3
  poly0   .req r4
  poly1   .req r6
  poly2   .req r5
  poly3   .req r7
  q       .req r8
  alpha2  .req r9
  qinv    .req r10
  tmp     .req r11

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
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #0]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #2]

  neg.w zeta, zeta

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #4]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  strh.w tmp, [rptr, #6]

  pop.w {r4-r11, pc}

.global doublebasemul_asm_acc
.type doublebasemul_asm_acc, %function
.align 2
doublebasemul_asm_acc:
  push.w {r4-r11, lr}

  rptr    .req r0
  aptr    .req r1
  bptr    .req r2
  zeta    .req r3
  poly0   .req r4
  poly1   .req r6
  poly2   .req r5
  poly3   .req r7
  q       .req r8
  alpha2  .req r9
  qinv    .req r10
  tmp     .req r11
  res0    .req r12
  res1    .req r14

  movw.w  q, #3329
  ### qinv=0x6ba8f301
  movw qinv, #62209
  movt qinv, #27560
  mov.w alpha2, #8

  ldrsh.w poly0, [aptr, #0]
  ldrsh.w poly1, [aptr, #2]
  ldrsh.w poly2, [bptr, #0]
  ldrsh.w poly3, [bptr, #2]
  ldrsh.w res0, [rptr, #0]
  ldrsh.w res1, [rptr, #2]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  add.w res0, res0, tmp
  strh.w res0, [rptr, #0]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  add.w res1, res1, tmp
  strh.w res1, [rptr, #2]

  neg.w zeta, zeta

  ldrsh.w poly0, [aptr, #4]
  ldrsh.w poly1, [aptr, #6]
  ldrsh.w poly2, [bptr, #4]
  ldrsh.w poly3, [bptr, #6]
  ldrsh.w res0, [rptr, #4]
  ldrsh.w res1, [rptr, #6]

  plant_mul_const q, alpha2, zeta, poly1, tmp
  mul.w tmp, tmp, poly3
  mla.w tmp, poly0, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  add.w res0, res0, tmp
  strh.w res0, [rptr, #4]

  mul.w tmp, poly0, poly3
  mla.w tmp, poly1, poly2, tmp
  plant_red q, alpha2, qinv, tmp
  add.w res1, res1, tmp
  strh.w res1, [rptr, #6]

  pop.w {r4-r11, pc}

