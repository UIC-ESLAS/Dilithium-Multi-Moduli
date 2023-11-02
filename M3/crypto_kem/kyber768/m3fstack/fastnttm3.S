#include "macros.i"

.syntax unified
.thumb

// |input|<0.5q; |output|<3.5q
.global ntt_fast
.type ntt_fast, %function
.align 2
ntt_fast:
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
  alpha2      .req r11
  q           .req r12
  tmp         .req r14

  movw alpha2, #8
  movw q, #3329

  ### LAYER 7+6+5
  movw tmp, #32
  1:
    push.w {tmp}

    ldrsh.w poly0, [poly]
    ldrsh.w poly1, [poly, #64]
    ldrsh.w poly2, [poly, #128]
    ldrsh.w poly3, [poly, #192]
    ldrsh.w poly4, [poly, #256]
    ldrsh.w poly5, [poly, #320]
    ldrsh.w poly6, [poly, #384]
    ldrsh.w poly7, [poly, #448]

    ldr.w twiddle, [twiddle_ptr]
    ct_butterfly poly0, poly4, twiddle, q, alpha2, tmp
    ct_butterfly poly1, poly5, twiddle, q, alpha2, tmp
    ct_butterfly poly2, poly6, twiddle, q, alpha2, tmp
    ct_butterfly poly3, poly7, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #4]
    ct_butterfly poly0, poly2, twiddle, q, alpha2, tmp
    ct_butterfly poly1, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #8]
    ct_butterfly poly4, poly6, twiddle, q, alpha2, tmp
    ct_butterfly poly5, poly7, twiddle, q, alpha2, tmp

    ldr.w twiddle, [twiddle_ptr, #12]
    ct_butterfly poly0, poly1, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #16]
    ct_butterfly poly2, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #20]
    ct_butterfly poly4, poly5, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr, #24]
    ct_butterfly poly6, poly7, twiddle, q, alpha2, tmp

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
  bne.w 1b

  sub.w poly, #64
  add.w twiddle_ptr, #14*2

  ### LAYER 4+3+2
  movw tmp, #8
  2:
    push.w {tmp}

    .set k, 1
    .rept 4
      ldrsh.w poly0, [poly]
      ldrsh.w poly1, [poly, #8]
      ldrsh.w poly2, [poly, #16]
      ldrsh.w poly3, [poly, #24]
      ldrsh.w poly4, [poly, #32]
      ldrsh.w poly5, [poly, #40]
      ldrsh.w poly6, [poly, #48]
      ldrsh.w poly7, [poly, #56]

      ldr.w twiddle, [twiddle_ptr]
      ct_butterfly poly0, poly4, twiddle, q, alpha2, tmp
      ct_butterfly poly1, poly5, twiddle, q, alpha2, tmp
      ct_butterfly poly2, poly6, twiddle, q, alpha2, tmp
      ct_butterfly poly3, poly7, twiddle, q, alpha2, tmp

      ldr.w twiddle, [twiddle_ptr, #4]
      ct_butterfly poly0, poly2, twiddle, q, alpha2, tmp
      ct_butterfly poly1, poly3, twiddle, q, alpha2, tmp
      ldr.w twiddle, [twiddle_ptr, #8]
      ct_butterfly poly4, poly6, twiddle, q, alpha2, tmp
      ct_butterfly poly5, poly7, twiddle, q, alpha2, tmp


      ldr.w twiddle, [twiddle_ptr, #12]
      ct_butterfly poly0, poly1, twiddle, q, alpha2, tmp
      ldr.w twiddle, [twiddle_ptr, #16]
      ct_butterfly poly2, poly3, twiddle, q, alpha2, tmp
      ldr.w twiddle, [twiddle_ptr, #20]
      ct_butterfly poly4, poly5, twiddle, q, alpha2, tmp
      ldr.w twiddle, [twiddle_ptr, #24]
      ct_butterfly poly6, poly7, twiddle, q, alpha2, tmp

      strh.w poly1, [poly, #8]
      strh.w poly2, [poly, #16]
      strh.w poly3, [poly, #24]
      strh.w poly4, [poly, #32]
      strh.w poly5, [poly, #40]
      strh.w poly6, [poly, #48]
      strh.w poly7, [poly, #56]
      .if k != 4
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

  sub.w poly, #512


  ### LAYER 1 (skip layer 0)
  movw tmp, #32
  4:
    push.w {tmp}

    ldrsh.w poly0, [poly]
    ldrsh.w poly1, [poly,#2]
    ldrsh.w poly2, [poly,#4]
    ldrsh.w poly3, [poly,#6]
    ldrsh.w poly4, [poly,#8]
    ldrsh.w poly5, [poly,#10]
    ldrsh.w poly6, [poly,#12]
    ldrsh.w poly7, [poly,#14]

    ldr.w twiddle, [twiddle_ptr], #4
    ct_butterfly poly0, poly2, twiddle, q, alpha2, tmp
    ct_butterfly poly1, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr], #4
    ct_butterfly poly4, poly6, twiddle, q, alpha2, tmp
    ct_butterfly poly5, poly7, twiddle, q, alpha2, tmp

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
  bne.w 4b
  pop.w {r4-r11, pc}
