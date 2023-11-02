#include "macros.i"

.syntax unified
.thumb

.macro fullplant a0, a1, a2, a3, q, alpha2, plantconst
  ### plantconst=plantconst*(p^-1) % 2^32
  movw \plantconst, #44984
  movt \plantconst, #19
  plant_mul_const_inplace \q, \alpha2, \plantconst, \a0
  plant_mul_const_inplace \q, \alpha2, \plantconst, \a1
  plant_mul_const_inplace \q, \alpha2, \plantconst, \a2
  plant_mul_const_inplace \q, \alpha2, \plantconst, \a3
.endm


// |input|<kq; output:
.global invntt_fast_gs
.type invntt_fast_gs, %function
.align 2
invntt_fast_gs:
  push.w {r4-r11, r14}

  poly        .req r0
  twiddle_ptr .req r1
  poly0       .req r2
  poly1       .req r3
  poly2       .req r4
  poly3       .req r5
  poly4       .req r6
  poly5       .req r7
  poly6       .req r8
  poly7       .req r9
  twiddle     .req r10
  plantconst  .req r10
  alpha2      .req r11
  q           .req r12
  tmp         .req r14

  movw alpha2, #8
  movw q, #3329

  ### LAYER 1 (skip layer 0)
  movw tmp, #32
  1:
    push.w {tmp}

    ldrsh.w poly0, [poly,#0]
    ldrsh.w poly1, [poly,#2]
    ldrsh.w poly2, [poly,#4]
    ldrsh.w poly3, [poly,#6]
    ldrsh.w poly4, [poly,#8]
    ldrsh.w poly5, [poly,#10]
    ldrsh.w poly6, [poly,#12]
    ldrsh.w poly7, [poly,#14]

    ldr.w twiddle, [twiddle_ptr], #4
    gs_butterfly poly0, poly2, twiddle, q, alpha2, tmp
    gs_butterfly poly1, poly3, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr], #4
    gs_butterfly poly4, poly6, twiddle, q, alpha2, tmp
    gs_butterfly poly5, poly7, twiddle, q, alpha2, tmp

    strh.w poly1, [poly,#2]
    strh.w poly2, [poly,#4]
    strh.w poly3, [poly,#6]
    strh.w poly4, [poly,#8]
    strh.w poly5, [poly,#10]
    strh.w poly6, [poly,#12]
    strh.w poly7, [poly,#14]
    strh.w poly0, [poly], #16

    pop.w {tmp}
    subs.w tmp, #1
  bne.w 1b

  sub.w poly, #512

  ### LAYER 2+3+4
  movw tmp, #8
  2:
    push.w {tmp}

    .set k, 1
    .rept 4
    ldrsh.w poly0, [poly, #0]
    ldrsh.w poly1, [poly, #8]
    ldrsh.w poly2, [poly, #16]
    ldrsh.w poly3, [poly, #24]
    ldrsh.w poly4, [poly, #32]
    ldrsh.w poly5, [poly, #40]
    ldrsh.w poly6, [poly, #48]
    ldrsh.w poly7, [poly, #56]

    ldr.w twiddle, [twiddle_ptr, #0]
    gs_butterfly poly0, poly1, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #4]
    gs_butterfly poly2, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #8]
    gs_butterfly poly4, poly5, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #12]
    gs_butterfly poly6, poly7, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #16]
    gs_butterfly poly0, poly2, twiddle, q, alpha2, tmp
    gs_butterfly poly1, poly3, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #20]
    gs_butterfly poly4, poly6, twiddle, q, alpha2, tmp
    gs_butterfly poly5, poly7, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #24]
    gs_butterfly poly0, poly4, twiddle, q, alpha2, tmp
    gs_butterfly poly1, poly5, twiddle, q, alpha2, tmp
    gs_butterfly poly2, poly6, twiddle, q, alpha2, tmp
    gs_butterfly poly3, poly7, twiddle, q, alpha2, tmp

    // fullplant poly0, poly1, poly2, poly3, q, alpha2, plantconst
    strh.w poly1, [poly,#8]
    strh.w poly2, [poly,#16]
    strh.w poly3, [poly,#24]
    strh.w poly4, [poly,#32]
    strh.w poly5, [poly,#40]
    strh.w poly6, [poly,#48]
    strh.w poly7, [poly,#56]

    .if k != 4
      .if k<=2
        movw plantconst, #44984
        movt plantconst, #19
        plant_mul_const_inplace q, alpha2, plantconst, poly0
      .endif
    strh.w poly0, [poly], #2
    .else
    strh.w poly0, [poly], #58
    .endif
    .set k, k+1
    .endr
    add.w twiddle_ptr, #14*2
    pop.w {tmp}
    subs.w tmp, #1
  bne.w 2b
  sub poly, #512

  ### LAYER 5+6+7
  movw tmp, #32
  3:
    push.w {tmp}

    ldrsh.w poly0, [poly, #0]
    ldrsh.w poly1, [poly, #64]
    ldrsh.w poly2, [poly, #128]
    ldrsh.w poly3, [poly, #192]
    ldrsh.w poly4, [poly, #256]
    ldrsh.w poly5, [poly, #320]
    ldrsh.w poly6, [poly, #384]
    ldrsh.w poly7, [poly, #448]

    ldr.w twiddle, [twiddle_ptr]
    gs_butterfly poly0, poly1, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #4]
    gs_butterfly poly2, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #8]
    gs_butterfly poly4, poly5, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #12]
    gs_butterfly poly6, poly7, twiddle, q, alpha2, tmp


    ldr.w twiddle, [twiddle_ptr, #16]
    gs_butterfly poly0, poly2, twiddle, q, alpha2, tmp
    gs_butterfly poly1, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #20]
    gs_butterfly poly4, poly6, twiddle, q, alpha2, tmp
    gs_butterfly poly5, poly7, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #24]
    gs_butterfly poly0, poly4, twiddle, q, alpha2, tmp
    gs_butterfly poly1, poly5, twiddle, q, alpha2, tmp
    gs_butterfly poly2, poly6, twiddle, q, alpha2, tmp
    gs_butterfly poly3, poly7, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #28]
    plant_mul_const_inplace q, alpha2, twiddle, poly0
    plant_mul_const_inplace q, alpha2, twiddle, poly1
    plant_mul_const_inplace q, alpha2, twiddle, poly2
    plant_mul_const_inplace q, alpha2, twiddle, poly3

    strh.w poly1, [poly, #64]
    strh.w poly2, [poly, #128]
    strh.w poly3, [poly, #192]
    strh.w poly4, [poly, #256]
    strh.w poly5, [poly, #320]
    strh.w poly6, [poly, #384]
    strh.w poly7, [poly, #448]
    strh.w poly0, [poly], #2

    pop.w {tmp}
    subs.w tmp, #1
  bne.w 3b
  pop.w {r4-r11, pc}
