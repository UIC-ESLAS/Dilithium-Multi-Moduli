#include "macros.i"

.syntax unified
.thumb

.global asm_barrett_reduce
.type asm_barrett_reduce,%function
.align 2
asm_barrett_reduce:
  push.w    {r4-r11, r14}

  poly        .req r0
  poly0       .req r1
  poly1       .req r2
  poly2       .req r3
  poly3       .req r4
  poly4       .req r5
  poly5       .req r6
  poly6       .req r7
  poly7       .req r8
  poly8       .req r14
  loop        .req r9
  barrettconst .req r10
  q           .req r11
  tmp         .req r12

  movw barrettconst, #20159
  movw q, #3329

  movw loop, #28
  1:
    ldrsh.w poly0, [poly, #0]
    ldrsh.w poly1, [poly, #2]
    ldrsh.w poly2, [poly, #4]
    ldrsh.w poly3, [poly, #6]
    ldrsh.w poly4, [poly, #8]
    ldrsh.w poly5, [poly, #10]
    ldrsh.w poly6, [poly, #12]
    ldrsh.w poly7, [poly, #14]
    ldrsh.w poly8, [poly, #16]

    barrett_red poly0, tmp, q, barrettconst
    barrett_red poly1, tmp, q, barrettconst
    barrett_red poly2, tmp, q, barrettconst
    barrett_red poly3, tmp, q, barrettconst
    barrett_red poly4, tmp, q, barrettconst
    barrett_red poly5, tmp, q, barrettconst
    barrett_red poly6, tmp, q, barrettconst
    barrett_red poly7, tmp, q, barrettconst
    barrett_red poly8, tmp, q, barrettconst

    strh.w poly1, [poly, #2]
    strh.w poly2, [poly, #4]
    strh.w poly3, [poly, #6]
    strh.w poly4, [poly, #8]
    strh.w poly5, [poly, #10]
    strh.w poly6, [poly, #12]
    strh.w poly7, [poly, #14]
    strh.w poly8, [poly, #16]
    strh.w poly0, [poly], #18
    subs.w loop, #1
  bne.w 1b

  ldrsh.w poly0, [poly, #0]
  ldrsh.w poly1, [poly, #2]
  ldrsh.w poly2, [poly, #4]
  ldrsh.w poly3, [poly, #6]
  barrett_red poly0, tmp, q, barrettconst
  barrett_red poly1, tmp, q, barrettconst
  barrett_red poly2, tmp, q, barrettconst
  barrett_red poly3, tmp, q, barrettconst
  strh.w poly0, [poly, #0]
  strh.w poly1, [poly, #2]
  strh.w poly2, [poly, #4]
  strh.w poly3, [poly, #6]
  pop.w     {r4-r11, pc}



.global asm_fromplant
.type asm_fromplant,%function
.align 2
asm_fromplant:
  push.w    {r4-r11, r14}

  poly        .req r0
  poly0       .req r1
  poly1       .req r2
  poly2       .req r3
  poly3       .req r4
  poly4       .req r5
  poly5       .req r6
  poly6       .req r7
  poly7       .req r8
  loop        .req r9
  plantconst  .req r10
  alpha2      .req r14
  q           .req r11
  tmp         .req r12

  movw alpha2, #8
  movw q, #3329

  ### plant_constant=(Plant_const^2%M)*(p^-1) % 2^32
  movw plantconst, #20396
  movt plantconst, #38900

movw loop, #32
  1:
    ldrsh.w poly0, [poly, #0]
    ldrsh.w poly1, [poly, #2]
    ldrsh.w poly2, [poly, #4]
    ldrsh.w poly3, [poly, #6]
    ldrsh.w poly4, [poly, #8]
    ldrsh.w poly5, [poly, #10]
    ldrsh.w poly6, [poly, #12]
    ldrsh.w poly7, [poly, #14]

    plant_mul_const_inplace q, alpha2, plantconst, poly0
    plant_mul_const_inplace q, alpha2, plantconst, poly1
    plant_mul_const_inplace q, alpha2, plantconst, poly2
    plant_mul_const_inplace q, alpha2, plantconst, poly3
    plant_mul_const_inplace q, alpha2, plantconst, poly4
    plant_mul_const_inplace q, alpha2, plantconst, poly5
    plant_mul_const_inplace q, alpha2, plantconst, poly6
    plant_mul_const_inplace q, alpha2, plantconst, poly7

    strh.w poly1, [poly, #2]
    strh.w poly2, [poly, #4]
    strh.w poly3, [poly, #6]
    strh.w poly4, [poly, #8]
    strh.w poly5, [poly, #10]
    strh.w poly6, [poly, #12]
    strh.w poly7, [poly, #14]
    strh.w poly0, [poly], #16
    

    subs.w loop, #1
  bne.w 1b

  pop.w     {r4-r11, pc}