/******************************************************************************
 * Integrating the improved Plantard arithmetic into Kyber.
 *
 * Efficient Plantard arithmetic enables a faster Kyber implementation with the
 * same stack usage.
 *
 * See the paper at https://eprint.iacr.org/2022/956.pdf for more details.
 *
 * @author   Junhao Huang, BNU-HKBU United International College, Zhuhai, China
 *           jhhuang_nuaa@126.com
 *
 * @date     September 2022
 ******************************************************************************/
#ifndef MACROS_I
#define MACROS_I

.macro load a, a0, a1, a2, a3, mem0, mem1, mem2, mem3
	ldr.w \a0, [\a, \mem0]
	ldr.w \a1, [\a, \mem1]
	ldr.w \a2, [\a, \mem2]
	ldr.w \a3, [\a, \mem3]
.endm

.macro loadh a, a0, a1, a2, a3, mem0, mem1, mem2, mem3
	ldrh \a0, [\a, \mem0]
	ldrh \a1, [\a, \mem1]
	ldrh \a2, [\a, \mem2]
	ldrh \a3, [\a, \mem3]
.endm

.macro store a, a0, a1, a2, a3, mem0, mem1, mem2, mem3
	str.w \a0, [\a, \mem0]
	str.w \a1, [\a, \mem1]
	str.w \a2, [\a, \mem2]
	str.w \a3, [\a, \mem3]
.endm

.macro storeh a, a0, a1, a2, a3, mem0, mem1, mem2, mem3
	strh \a0, [\a, \mem0]
	strh \a1, [\a, \mem1]
	strh \a2, [\a, \mem2]
	strh \a3, [\a, \mem3]
.endm

.macro doublebarrett a, tmp, tmp2, q, barrettconst
	smulbb \tmp, \a, \barrettconst
	smultb \tmp2, \a, \barrettconst
	asr \tmp, \tmp, #26
	asr \tmp2, \tmp2, #26
	smulbb \tmp, \tmp, \q
	smulbb \tmp2, \tmp2, \q
	pkhbt \tmp, \tmp, \tmp2, lsl#16
	usub16 \a, \a, \tmp
.endm

.macro doubleplant a, tmp, q, qa, plantconst
	smulwb \tmp, \plantconst, \a
	smulwt \a, \plantconst, \a
	smlabt \tmp, \tmp, \q, \qa
	smlabt \a, \a, \q, \qa
	pkhtb \a, \a, \tmp, asr#16
.endm

#endif /* MACROS_I */
