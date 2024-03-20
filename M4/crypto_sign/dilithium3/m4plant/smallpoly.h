/**
 * Copyright (c) 2023 Junhao Huang (jhhuang_nuaa@126.com)
 *
 * Licensed under the Apache License, Version 2.0(the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
void poly_small_basemul_invntt(poly *r, const smallpoly *a, const smallpoly *aprime, const smallpoly *b);

void small_polyeta_unpack(smallpoly *r, const uint8_t *a);

#endif