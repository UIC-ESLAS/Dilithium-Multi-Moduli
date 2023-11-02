#include "macros_smallntt.i"

.syntax unified
.thumb

// |input|<0.5q; |output|<3.5q
.global small_ntt_asm_769
.type small_ntt_asm_769, %function
.align 2
small_ntt_asm_769:
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

  movw alpha2, #32
  movw q, #769

  ### LAYER 7+6+5
  movw tmp, #32
  1:

    ldrsh.w poly0, [poly]
    ldrsh.w poly1, [poly, #64]
    ldrsh.w poly2, [poly, #128]
    ldrsh.w poly3, [poly, #192]
    ldrsh.w poly4, [poly, #256]
    ldrsh.w poly5, [poly, #320]
    ldrsh.w poly6, [poly, #384]
    ldrsh.w poly7, [poly, #448]

    ldr.w twiddle, [twiddle_ptr]
    push.w {tmp}
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

    pop.w {tmp}
    strh.w poly1, [poly, #64]
    strh.w poly2, [poly, #128]
    strh.w poly3, [poly, #192]
    strh.w poly4, [poly, #256]
    strh.w poly5, [poly, #320]
    strh.w poly6, [poly, #384]
    strh.w poly7, [poly, #448]
    strh.w poly0, [poly], #2

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

    ldrsh.w poly0, [poly]
    ldrsh.w poly1, [poly,#2]
    ldrsh.w poly2, [poly,#4]
    ldrsh.w poly3, [poly,#6]
    ldrsh.w poly4, [poly,#8]
    ldrsh.w poly5, [poly,#10]
    ldrsh.w poly6, [poly,#12]
    ldrsh.w poly7, [poly,#14]

    ldr.w twiddle, [twiddle_ptr], #4
    push.w {tmp}
    ct_butterfly poly0, poly2, twiddle, q, alpha2, tmp
    ct_butterfly poly1, poly3, twiddle, q, alpha2, tmp
    ldr.w twiddle, [twiddle_ptr], #4
    ct_butterfly poly4, poly6, twiddle, q, alpha2, tmp
    ct_butterfly poly5, poly7, twiddle, q, alpha2, tmp

    pop.w {tmp}
    strh.w poly1, [poly,#2]
    strh.w poly2, [poly,#4]
    strh.w poly3, [poly,#6]
    strh.w poly4, [poly,#8]
    strh.w poly5, [poly,#10]
    strh.w poly6, [poly,#12]
    strh.w poly7, [poly,#14]
    strh.w poly0, [poly], #16

    subs.w tmp, #1
  bne.w 4b
  pop.w {r4-r11, pc}



.macro _3_layer_inv_CT_light c0, c1, c2, c3, c4, c5, c6, c7, twiddle, twiddle_ptr, addr1, addr2, addr3, addr4, q, alpha2, tmp, tmp2
  // layer 1
  add.w \tmp, \c0, \c1
  sub.w \c1, \c0, \c1 
  add.w \tmp2, \c2, \c3 
  sub.w \c3, \c2, \c3 

  add.w \c0, \c4, \c5
  sub.w \c5, \c4, \c5 
  add.w \c2, \c6, \c7
  sub.w \c7, \c6, \c7 
  // c4, c6 are free at this point

  // layer 2
  add.w \c6, \tmp, \tmp2
  sub.w \tmp2, \tmp, \tmp2
  add.w \c4, \c0, \c2 
  sub.w \c2, \c0, \c2 
  // movw \tmp, #44984
  // movt \tmp, #19
  // plant_mul_const_inplace \q, \alpha2, \tmp, \c6

  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr1)]
  ct_butterfly \c1, \c3, \twiddle, \q, \alpha2, \tmp
  ct_butterfly \c5, \c7, \twiddle, \q, \alpha2, \tmp

  // layer 3
  add.w \c0, \c6, \c4
  sub.w \c4, \c6, \c4

  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr2)]
  ct_butterfly \c1, \c5, \twiddle, \q, \alpha2, \tmp

  // this block is one butterfly
  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr3)]
  plant_mul_const \q, \alpha2, \twiddle, \c2, \tmp
  sub.w \c6, \tmp2, \tmp
  add.w \c2, \tmp2, \tmp
  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr4)]
  ct_butterfly \c3, \c7, \twiddle, \q, \alpha2, \tmp
.endm

.macro _3_layer_inv_CT c0, c1, c2, c3, c4, c5, c6, c7, twiddle1, twiddle2, twiddle_ptr, q, alpha2, tmp
  // layer 3
  ldr.w \twiddle1, [\twiddle_ptr]
  ct_butterfly \c0, \c1, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c2, \c3, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c4, \c5, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c6, \c7, \twiddle1, \q, \alpha2, \tmp

  // layer 2
  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #4]
  ct_butterfly \c0, \c2, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c1, \c3, \twiddle2, \q, \alpha2, \tmp
  ct_butterfly \c4, \c6, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c5, \c7, \twiddle2, \q, \alpha2, \tmp

  // layer 1
  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #4*3]
  ct_butterfly \c0, \c4, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c1, \c5, \twiddle2, \q, \alpha2, \tmp

  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #4*5]
  ct_butterfly \c2, \c6, \twiddle1, \q, \alpha2, \tmp
  ct_butterfly \c3, \c7, \twiddle2, \q, \alpha2, \tmp
.endm


.macro _3_layer_inv_twist c0, c1, c2, c3, c4, c5, c6, c7, twiddle1, twiddle2, twiddle_ptr, q, alpha2, tmp, addr
  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #(\addr)]
  plant_mul_const_inplace \q, \alpha2, \twiddle1, \c0
  plant_mul_const_inplace \q, \alpha2, \twiddle2, \c1
  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #(\addr+8)]
  plant_mul_const_inplace \q, \alpha2, \twiddle1, \c2
  plant_mul_const_inplace \q, \alpha2, \twiddle2, \c3
  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #(\addr+16)]
  plant_mul_const_inplace \q, \alpha2, \twiddle1, \c4
  plant_mul_const_inplace \q, \alpha2, \twiddle2, \c5
  ldrd \twiddle1, \twiddle2, [\twiddle_ptr, #(\addr+24)]
  plant_mul_const_inplace \q, \alpha2, \twiddle1, \c6
  plant_mul_const_inplace \q, \alpha2, \twiddle2, \c7
.endm


// |input|<kq; output:
.global small_invntt_asm_769
.type small_invntt_asm_769, %function
.align 2
small_invntt_asm_769:
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

  movw alpha2, #32
  movw q, #769

  ### LAYER 7+6+5
  movw tmp, #16
  1:
    push.w {tmp}

    ldrsh.w poly0, [poly]
    ldrsh.w poly1, [poly, #4]
    ldrsh.w poly2, [poly, #4*2]
    ldrsh.w poly3, [poly, #4*3]
    ldrsh.w poly4, [poly, #4*4]
    ldrsh.w poly5, [poly, #4*5]
    ldrsh.w poly6, [poly, #4*6]
    ldrsh.w poly7, [poly, #4*7]
    push.w {poly}

    _3_layer_inv_CT_light poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, twiddle, twiddle_ptr, 2, 4, 5, 6, q, alpha2, tmp, poly
    
    pop.w {poly}
    strh.w poly1, [poly, #4]
    strh.w poly2, [poly, #4*2]
    strh.w poly3, [poly, #4*3]
    strh.w poly4, [poly, #4*4]
    strh.w poly5, [poly, #4*5]
    strh.w poly6, [poly, #4*6]
    strh.w poly7, [poly, #4*7]
    strh.w poly0, [poly], #2


    ldrsh.w poly0, [poly]
    ldrsh.w poly1, [poly, #4]
    ldrsh.w poly2, [poly, #4*2]
    ldrsh.w poly3, [poly, #4*3]
    ldrsh.w poly4, [poly, #4*4]
    ldrsh.w poly5, [poly, #4*5]
    ldrsh.w poly6, [poly, #4*6]
    ldrsh.w poly7, [poly, #4*7]
    push.w {poly}

    _3_layer_inv_CT_light poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, twiddle, twiddle_ptr, 2, 4, 5, 6, q, alpha2, tmp, poly
    
    pop.w {poly}
    pop.w {tmp}
    strh.w poly1, [poly, #4]
    strh.w poly2, [poly, #4*2]
    strh.w poly3, [poly, #4*3]
    strh.w poly4, [poly, #4*4]
    strh.w poly5, [poly, #4*5]
    strh.w poly6, [poly, #4*6]
    strh.w poly7, [poly, #4*7]
    strh.w poly0, [poly], #30

    subs.w tmp, #1
  bne.w 1b
  sub.w poly, #512
  add.w twiddle_ptr, #4*7

  ### LAYER 4
  movw tmp, #8
  2:
    push.w {tmp}
    ldr.w twiddle, [twiddle_ptr], #4
    .set k, 1
    .rept 2
      ldrsh.w poly0, [poly]
      ldrsh.w poly1, [poly, #32*1]
      ldrsh.w poly2, [poly, #32*2]
      ldrsh.w poly3, [poly, #32*3]
      ldrsh.w poly4, [poly, #32*4]
      ldrsh.w poly5, [poly, #32*5]
      ldrsh.w poly6, [poly, #32*6]
      ldrsh.w poly7, [poly, #32*7]

      ct_butterfly poly0, poly1, twiddle, q, alpha2, tmp
      ct_butterfly poly2, poly3, twiddle, q, alpha2, tmp
      ct_butterfly poly4, poly5, twiddle, q, alpha2, tmp
      ct_butterfly poly6, poly7, twiddle, q, alpha2, tmp

      strh.w poly1, [poly, #32*1]
      strh.w poly2, [poly, #32*2]
      strh.w poly3, [poly, #32*3]
      strh.w poly4, [poly, #32*4]
      strh.w poly5, [poly, #32*5]
      strh.w poly6, [poly, #32*6]
      strh.w poly7, [poly, #32*7]
      strh.w poly0, [poly], #2
    .set k, k+1
    .endr
    pop.w {tmp}
    subs.w tmp, #1
  bne.w 2b
  add.w poly, #224
  sub.w twiddle_ptr, #4*8

  movw tmp, #8
  3:
    push.w {tmp}
    ldr.w twiddle, [twiddle_ptr], #4
    .set k, 1
    .rept 2
      ldrsh.w poly0, [poly]
      ldrsh.w poly1, [poly, #32*1]
      ldrsh.w poly2, [poly, #32*2]
      ldrsh.w poly3, [poly, #32*3]
      ldrsh.w poly4, [poly, #32*4]
      ldrsh.w poly5, [poly, #32*5]
      ldrsh.w poly6, [poly, #32*6]
      ldrsh.w poly7, [poly, #32*7]

      ct_butterfly poly0, poly1, twiddle, q, alpha2, tmp
      ct_butterfly poly2, poly3, twiddle, q, alpha2, tmp
      ct_butterfly poly4, poly5, twiddle, q, alpha2, tmp
      ct_butterfly poly6, poly7, twiddle, q, alpha2, tmp

      strh.w poly1, [poly, #32*1]
      strh.w poly2, [poly, #32*2]
      strh.w poly3, [poly, #32*3]
      strh.w poly4, [poly, #32*4]
      strh.w poly5, [poly, #32*5]
      strh.w poly6, [poly, #32*6]
      strh.w poly7, [poly, #32*7]
      strh.w poly0, [poly], #2
    .set k, k+1
    .endr
    pop.w {tmp}
    subs.w tmp, #1
  bne.w 3b
  sub.w poly, #256+32


  ### LAYER 3+2+1
  // ITER 0
  .set k, 1
  .rept 2
    ldrsh.w poly0, [poly, #0]
    ldrsh.w poly1, [poly, #64]
    ldrsh.w poly2, [poly, #128]
    ldrsh.w poly3, [poly, #192]
    ldrsh.w poly4, [poly, #256]
    ldrsh.w poly5, [poly, #320]
    ldrsh.w poly6, [poly, #384]
    ldrsh.w poly7, [poly, #448]
    push.w {poly}

    _3_layer_inv_CT_light poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, twiddle, twiddle_ptr, 1, 3, 4, 5, q, alpha2, tmp, poly
    _3_layer_inv_twist poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, twiddle, poly, twiddle_ptr, q, alpha2, tmp, 24

    pop.w {poly}
    strh.w poly1, [poly, #64]
    strh.w poly2, [poly, #128]
    strh.w poly3, [poly, #192]
    strh.w poly4, [poly, #256]
    strh.w poly5, [poly, #320]
    strh.w poly6, [poly, #384]
    strh.w poly7, [poly, #448]
    strh.w poly0, [poly], #2
  .set k, k+1
  .endr
  add.w twiddle_ptr, #4*14

  ### LAYER 3+2+1
  // ITER 1-15
  movw tmp, #15
  4:
    push.w {tmp}
    .set k, 1
    .rept 2
      ldrsh.w poly0, [poly, #0]
      ldrsh.w poly1, [poly, #64]
      ldrsh.w poly2, [poly, #128]
      ldrsh.w poly3, [poly, #192]
      ldrsh.w poly4, [poly, #256]
      ldrsh.w poly5, [poly, #320]
      ldrsh.w poly6, [poly, #384]
      ldrsh.w poly7, [poly, #448]
      push.w {poly}

      _3_layer_inv_CT poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7 twiddle, poly, twiddle_ptr, q, alpha2, tmp
      _3_layer_inv_twist poly0, poly1, poly2, poly3, poly4, poly5, poly6, poly7, twiddle, poly, twiddle_ptr, q, alpha2, tmp, 28

      pop.w {poly}
      strh.w poly1, [poly, #64]
      strh.w poly2, [poly, #128]
      strh.w poly3, [poly, #192]
      strh.w poly4, [poly, #256]
      strh.w poly5, [poly, #320]
      strh.w poly6, [poly, #384]
      strh.w poly7, [poly, #448]
      strh.w poly0, [poly], #2
    .set k, k+1
    .endr
    add.w twiddle_ptr, #4*15
    pop.w {tmp}
    subs.w tmp, #1
  bne.w 4b

  pop.w {r4-r11, pc}


###################################
#### small point-multiplication####
#### r0: out; r1: in; r2: zetas####
###################################

.global small_pointmul_asm_769
.type small_pointmul_asm_769, %function
.align 2
small_pointmul_asm_769:
    push.w {r4-r11, lr}

    movw r14, #32 // alpha2
    movw r12, #769  // q
    .equ width, 4

    add.w r3, r2, #64*4
    add.w r1, r1, #2 // start from position 1
    _point_mul_16_loop:

    ldrsh.w r7, [r1, #2*width]
    ldrsh.w r8, [r1, #3*width]
    ldrsh.w r5, [r1, #1*width]
    ldrsh.w r4, [r1], #4*width
    ldr.w r9, [r2, #1*width]
    ldr.w r6, [r2], #2*width

    plant_mul_const_inplace r12, r14, r6, r4

    neg.w r6, r6

    plant_mul_const_inplace r12, r14, r6, r5

    plant_mul_const_inplace r12, r14, r9, r7

    neg.w r9, r9

    plant_mul_const_inplace r12, r14, r9, r8

    strh.w r5, [r0, #1*2]
    strh.w r7, [r0, #2*2]
    strh.w r8, [r0, #3*2]
    strh.w r4, [r0], #4*2

    cmp.w r2, r3
    bne.w _point_mul_16_loop

    pop.w {r4-r11, pc}

#### r0: out; r1: a; r2: b; r3: bprime

.global small_asymmetric_mul_asm_769
.type small_asymmetric_mul_asm_769, %function
.align 2
small_asymmetric_mul_asm_769:
    push.w {r4-r11, lr}

    movw r14, #32 // alpha2
    movw r12, #769  // q
    movw r11, #64769
    movt r11, #58632 // qinv
    .equ width, 2
    add.w r10, r0, #256*2
    _asymmetric_mul_16_loop:
      ldrsh.w r7, [r1, #width]
      ldrsh.w r4, [r1], #2*width
      ldrsh.w r8, [r2, #width]
      ldrsh.w r5, [r2], #2*width
      ldrsh.w r9, [r3, #width]
      ldrsh.w r6, [r3], #2*width

      mul.w r6, r6, r7
      mla.w r6, r4, r5, r6
      plant_red r12, r14, r11, r6

      mul.w r5, r5, r7
      mla.w r5, r4, r8, r5
      plant_red r12, r14, r11, r5

      strh.w r5, [r0, #width]
      strh.w r6, [r0], #2*width

      ldrsh.w r7, [r1, #width]
      ldrsh.w r4, [r1], #2*width
      ldrsh.w r8, [r2, #width]
      ldrsh.w r5, [r2], #2*width

      mul.w r9, r9, r7
      mla.w r9, r4, r5, r9
      plant_red r12, r14, r11, r9

      mul.w r5, r5, r7
      mla.w r5, r4, r8, r5
      plant_red r12, r14, r11, r5

      strh.w r5, [r0, #width]
      strh.w r9, [r0], #2*width

    cmp.w r0, r10
    bne.w _asymmetric_mul_16_loop

    pop.w {r4-r11, pc}