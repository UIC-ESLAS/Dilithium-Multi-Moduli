
#include "macros_smallntt.i"

.syntax unified
.thumb
// CRT(int32_t *out, int16_t *in1, int16_t *in2); output and input buffs cannot be the same
.global __asm_small_CRT_32
.type __asm_small_CRT_32, %function
.align 2
__asm_small_CRT_32:
    push.w {r4-r12, lr}
    des          .req r0
	src1         .req r1
	src2         .req r2
	poly0        .req r3
	poly1        .req r4
	poly2        .req r5
	poly3        .req r6
	tmp          .req r7
	res0         .req r8
	m1           .req r9  // (plant_const* mod0^-1 mod mod1)*(mod1^-1 mod 2^2n) mod 2^2n
	mod0         .req r10 
	mod1         .req r11 
	alpha2       .req r12 
	// qa=2^a q;a=3; at the bottom of r12
	loop         .req r14

    .equ ldrwidth, 2
    .equ strwidth, 4

    movw mod0, #769
    movw mod1, #3329
    movw alpha2, #8
    movw m1, #25711
    movt m1, #19686 // m1=(plant_const* mod0^-1 mod mod1)*(mod1^-1 mod 2^2n) mod 2^2n=1290167407

    add.w loop, des, #256*strwidth
    _CRT:
        ldrsh.w poly2, [src1, #1*ldrwidth]
        ldrsh.w poly0, [src1], #2*ldrwidth
        ldrsh.w poly3, [src2, #1*ldrwidth]
        ldrsh.w poly1, [src2], #2*ldrwidth
        
        sub.w res0, poly1, poly0
        plant_mul_const_inplace mod1, alpha2, m1, res0
        mla.w poly0, res0, mod0, poly0

        sub.w res0, poly3, poly2
        plant_mul_const_inplace mod1, alpha2, m1, res0
        mla.w poly2, res0, mod0, poly2
        str.w poly2, [des, #strwidth]
        str.w poly0, [des], #2*strwidth
        

        ldrsh.w poly2, [src1, #1*ldrwidth]
        ldrsh.w poly0, [src1], #2*ldrwidth
        ldrsh.w poly3, [src2, #1*ldrwidth]
        ldrsh.w poly1, [src2], #2*ldrwidth

        sub.w res0, poly1, poly0
        plant_mul_const_inplace mod1, alpha2, m1, res0
        mla.w poly0, res0, mod0, poly0

        sub.w res0, poly3, poly2
        plant_mul_const_inplace mod1, alpha2, m1, res0
        mla.w poly2, res0, mod0, poly2
        str.w poly2, [des, #strwidth]
        str.w poly0, [des], #2*strwidth
        
    cmp.w des, loop
    bne.w _CRT

    pop.w {r4-r12, pc}