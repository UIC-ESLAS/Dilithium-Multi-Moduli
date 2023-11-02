#ifndef SMALLPOLY_H
#define SMALLPOLY_H
#include "params.h"
#include "poly.h"
#include "polyvec.h"

typedef struct {
    int16_t coeffs[N];
} smallpoly;

void poly_small_ntt_precomp(smallpoly *out, smallpoly *out2, poly *in);
void polyvecl_small_ntt(smallpoly v[L]);
void polyveck_small_ntt(smallpoly v[K]);
void polyvecl_small_basemul_invntt(polyvecl *r, const smallpoly *a, const smallpoly *aprime, const smallpoly b[L]);
void polyveck_small_basemul_invntt(polyveck *r, const smallpoly *a, const smallpoly *aprime, const smallpoly b[K]);
void poly_small_basemul_invntt(poly *r, const smallpoly *a, const smallpoly *aprime, const smallpoly *b);

void poly_double_ntt_precomp(poly *out, poly *in);
void poly_double_ntt(poly *v);
void polyvecl_double_ntt(polyvecl *v);
void polyveck_double_ntt(polyveck *v);
void poly_double_basemul_invntt(poly *r, const poly *a, const poly *aprime, const poly *b);
void polyvecl_double_basemul_invntt(polyvecl *r, const poly *a, const poly *aprime, const poly b[L]);
void polyveck_double_basemul_invntt(polyveck* r,
                                    const poly* a,
                                    const poly* aprime,
                                    const polyveck *b);

void small_polyeta_unpack(smallpoly *r, const uint8_t *a);

#endif