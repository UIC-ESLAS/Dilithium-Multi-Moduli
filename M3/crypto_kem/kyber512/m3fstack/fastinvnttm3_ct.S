#include "macros.i"

.syntax unified
.thumb
// kyber512:1q-2q-4q-6.5q; kyber1024:2q-4q-8q-8.5q
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
  // 2q

  // layer 2
  add.w \c6, \tmp, \tmp2
  sub.w \tmp2, \tmp, \tmp2
  add.w \c4, \c0, \c2 
  sub.w \c2, \c0, \c2 
  // 4q

  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr1)]
  ct_butterfly \c1, \c3, \twiddle, \q, \alpha2, \tmp
  ct_butterfly \c5, \c7, \twiddle, \q, \alpha2, \tmp
  // 2.5q

  // layer 3
  add.w \c0, \c6, \c4
  sub.w \c4, \c6, \c4
  // 8q

  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr2)]
  ct_butterfly \c1, \c5, \twiddle, \q, \alpha2, \tmp
  // 3q

  // this block is one butterfly
  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr3)]
  plant_mul_const \q, \alpha2, \twiddle, \c2, \tmp
  sub.w \c6, \tmp2, \tmp
  add.w \c2, \tmp2, \tmp
  // 4.5q
  ldr.w \twiddle, [\twiddle_ptr, #(4*\addr4)]
  ct_butterfly \c3, \c7, \twiddle, \q, \alpha2, \tmp
  // 1q
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
.global invntt_fast
.type invntt_fast, %function
.align 2
invntt_fast:
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
    strh.w poly1, [poly, #4]
    strh.w poly2, [poly, #4*2]
    strh.w poly3, [poly, #4*3]
    strh.w poly4, [poly, #4*4]
    strh.w poly5, [poly, #4*5]
    strh.w poly6, [poly, #4*6]
    strh.w poly7, [poly, #4*7]
    strh.w poly0, [poly], #30

    pop.w {tmp}
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