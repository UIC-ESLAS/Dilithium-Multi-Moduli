#ifndef MACROS_I
#define MACROS_I

// a*b*qinv*plantconst; result in the bottom half of a
.macro plant_mul_const_inplace q, alpha2, bq, a
  mul.w \a, \a, \bq
  add.w \a, \alpha2, \a, asr#16
  mul.w \a, \a, \q
  asr.w \a, \a, #16
.endm

// a*b*qinv*plantconst; result in the bottom half of res
.macro plant_mul_const q, alpha2, bq, a, res
  mul.w \res, \a, \bq
  add.w \res, \alpha2, \res, asr#16
  mul.w \res, \res, \q
  asr.w \res, \res, #16
.endm

// each layer increases coefficients by 0.5q
.macro ct_butterfly a0, a1, twiddle, q, alpha2, tmp
  mul.w \a1, \a1, \twiddle
  add.w \a1, \alpha2, \a1, asr#16
  mul.w \tmp, \a1, \q
  sub.w \a1, \a0, \tmp, asr#16
  add.w \a0, \a0, \tmp, asr#16
.endm

.macro gs_butterfly a0, a1, twiddle, q, alpha2, tmp
  sub.w \tmp, \a0, \a1
  add.w \a0, \a0, \a1
  mul.w \a1, \tmp, \twiddle
  add.w \a1, \alpha2, \a1, asr#16
  mul.w \a1, \a1, \q
  asr.w \a1, \a1, #16
.endm

// output (-0.5q, 0.5q)
.macro plant_red q, alpha2, qinv, a 
  mul.w \a, \a, \qinv
  add.w \a, \alpha2, \a, asr#16
  mul.w \a, \a, \q
  asr.w \a, \a, #16
.endm

// output (0, q)
.macro barrett_red a, tmp, q, barrettconst
  mul.w \tmp, \a, \barrettconst
  asr.w \tmp, \tmp, #26
  mul.w \tmp, \tmp, \q
  sub.w \a, \a, \tmp
.endm

// output (-0.5q,0.5q)
.macro signed_barrettm3 a, tmp, q, barrettconst
  mul.w \tmp, \a, \barrettconst
  // 2^26
  add.w \tmp, \tmp, #67108864
  asr.w \tmp, \tmp, #27
  mla.w \a, \tmp, \q, \a
.endm

#endif /* MACROS_I */