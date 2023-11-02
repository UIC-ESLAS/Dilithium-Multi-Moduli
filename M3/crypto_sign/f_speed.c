#include "api.h"
#include "hal.h"
#include "randombytes.h"
#include "sendfn.h"
#include <stdint.h>
#include <string.h>
#include "params.h"
#include "symmetric.h"
#include "sign.h"
#include "poly.h"
#include "polyvec.h"
#include "ntt.h"
#include "config.h"
#ifdef opt
#include "smallntt.h"
#include "smallpoly.h"
#endif
#include "keccakf1600.h"

#define MAX(a, b) (((a) > (b)) ? (a) : (b))

#define printcycles(S, U) send_unsignedll((S), (U))

int main(void)
{

    unsigned long long t0, t1;
    hal_setup(CLOCK_BENCHMARK);
    poly buf,a1,c1,c1_prime;
    polyvecl s1;
    polyveck s2;
#ifdef opt
    smallpoly sp1[L];
    smallpoly sp2[K];
    int16_t a[N];
    int16_t b[N];
    int16_t c[N];
    int16_t b_prime[N];
#endif
    shake256incctx state;
    uint8_t seedbuf[SEEDBYTES];

    shake256_inc_init(&state);
    
    
    for (int i = 0; i < 2; i++)
    {
        hal_send_str("==========================");
    }

    for (int crypto_i = 0; crypto_i < MUPQ_ITERATIONS; crypto_i++)
    {
        // ### NTT leaktime ###
        t0 = hal_get_time();
        poly_ntt_leaktime(&buf);
        t1 = hal_get_time();
        printcycles("ntt leaktime cycles:", t1 - t0);

        // ### iNTT leaktime ###
        t0 = hal_get_time();
        poly_invntt_tomont_leaktime(&buf);
        t1 = hal_get_time();
        printcycles("invntt leaktime cycles:", t1 - t0);

        t0 = hal_get_time();
        poly_pointwise_montgomery_leaktime(&buf, &buf, &buf);
        t1 = hal_get_time();
        printcycles("basemul leaktime cycles:", t1 - t0);

        // ### NTT ###
        t0 = hal_get_time();
        poly_ntt(&buf);
        t1 = hal_get_time();
        printcycles("ntt cycles:", t1 - t0);
        
        // ### iNTT ###
        t0 = hal_get_time();
        poly_invntt_tomont(&buf);
        t1 = hal_get_time();
        printcycles("invntt cycles:", t1 - t0);

        t0 = hal_get_time();
        poly_pointwise_montgomery(&buf, &buf, &buf);
        t1 = hal_get_time();
        printcycles("basemul cycles:", t1 - t0);

        // cs1
        poly_challenge(&c1, (uint8_t*)"sig");
        t0 = hal_get_time();
        polyvecl_ntt(&s1);
        poly_ntt(&c1);
        polyvecl_pointwise_poly_montgomery(&s1, &c1, &s1);
        polyvecl_invntt_tomont(&s1);
        t1 = hal_get_time();
        printcycles("cs1 with 32-bit NTT cycles:", t1 - t0);

        // cs2
        poly_challenge(&c1, (uint8_t*) "sig");
        t0 = hal_get_time();
        polyveck_ntt(&s2);
        poly_ntt(&c1);
        polyveck_pointwise_poly_montgomery(&s2, &c1, &s2);
        polyveck_invntt_tomont(&s2);
        t1 = hal_get_time();
        printcycles("cs2 with 32-bit NTT cycles:", t1 - t0);

        // ct0
        poly_challenge(&c1, (uint8_t*) "sig");
        t0 = hal_get_time();
        polyvecl_ntt(&s1);
        poly_ntt(&c1);
        for(int i=0;i<L;i++){
          poly_pointwise_montgomery_leaktime(&s1.vec[i],&c1,&s1.vec[i]);
          poly_invntt_tomont_leaktime(&s1.vec[i]);
        }
        // polyvecl_pointwise_poly_montgomery_leaktime(&s1, &c1, &s1);
        // polyvecl_invntt_tomont_leaktime(&s1);
        t1 = hal_get_time();
        printcycles("ct0 part-constant part-variable with 32-bit NTT cycles:", t1 - t0);

        // ct1 variable-time in verify
        poly_challenge(&c1, (uint8_t*) "sig");
        t0 = hal_get_time();
        polyveck_ntt_leaktime(&s2);
        poly_ntt_leaktime(&c1);
        polyveck_pointwise_poly_montgomery(&s2, &c1, &s2);
        polyveck_invntt_tomont_leaktime(&s2);
        t1 = hal_get_time();
        printcycles("ct1 variable time with 32-bit NTT cycles:", t1 - t0);

#ifdef MULTI_MODULI
        // ### multi-moduli NTT ###
        t0 = hal_get_time();
        poly_double_ntt(&a1);
        t1 = hal_get_time();
        printcycles("double ntt cycles:", t1 - t0);

        t0 = hal_get_time();
        poly_double_ntt_precomp(&c1, &buf);
        t1 = hal_get_time();
        printcycles("double ntt precomp cycles:", t1 - t0);

        // ### iNTT ###
        t0 = hal_get_time();
        double_asymmetric_mul(
          (int16_t*) a1.coeffs, (int16_t*) buf.coeffs, (int16_t*) c1.coeffs, (int16_t*) a1.coeffs);
        t1 = hal_get_time();
        printcycles("double_asymmetric_mul cycles:", t1 - t0);

        t0 = hal_get_time();
        double_invntt((int16_t*)a1.coeffs);
        t1 = hal_get_time();
        printcycles("double_invntt cycles:", t1 - t0);

        t0 = hal_get_time();
        poly_double_basemul_invntt(&a1, &buf, &c1, &a1);
        t1 = hal_get_time();
        printcycles("double basemul+intt+crt cycles:", t1 - t0);

        t0 = hal_get_time();
        double_CRT(a1.coeffs, (int16_t*) c1.coeffs, (int16_t*) (c1.coeffs+128));
        t1 = hal_get_time();
        printcycles("multi-moduli crt cycles:", t1 - t0);

        // cs1
        poly_challenge_new(&c1, (uint8_t*) "sig");
        t0 = hal_get_time();        
        poly_double_ntt_precomp(&c1_prime, &c1);
        polyvecl_small_ntt(sp1);
        polyvecl_small_basemul_invntt(&s1, (smallpoly*) &c1, (smallpoly*)&c1_prime, sp1);
        t1 = hal_get_time();
        printcycles("cs1 small NTT cycles:", t1 - t0);

        // cs2
        poly_challenge_new(&c1, (uint8_t*) "sig");
        t0 = hal_get_time();
        poly_double_ntt_precomp(&c1_prime, &c1);
        polyveck_small_ntt(sp2);
        polyveck_small_basemul_invntt(&s2, (smallpoly*)&c1, (smallpoly*)&c1_prime, sp2);
        t1 = hal_get_time();
        printcycles("cs2 small NTT cycles:", t1 - t0);

        //ct0 constant-time
        poly_challenge_new(&c1, (uint8_t*) "sig");
        t0 = hal_get_time();
        poly_double_ntt_precomp(&c1_prime, &c1);
        polyveck_double_ntt(&s2);
        polyveck_double_basemul_invntt(&s2, &c1, &c1_prime, &s2);
        t1 = hal_get_time();
        printcycles("ct0 double NTT cycles:", t1 - t0);

#endif
        // ### SHAKE256 ###
        t0 = hal_get_time();
        KeccakF1600_StatePermute(state.ctx);
        t1 = hal_get_time();
        printcycles("KeccakF1600_StatePermute cycles:", t1 - t0);
#ifdef opt
        // ### small NTT ###
        t0 = hal_get_time();
        small_ntt(a);
        t1 = hal_get_time();
        printcycles("small ntt cycles:", t1 - t0);

        t0 = hal_get_time();
        small_invntt_tomont(a);
        t1 = hal_get_time();
        printcycles("small invntt cycles:", t1 - t0);

        t0 = hal_get_time();
        small_point_mul(b_prime, b);
        t1 = hal_get_time();
        printcycles("small point_mul cycles:", t1 - t0);

        t0 = hal_get_time();
        small_asymmetric_mul(c, a, b, b_prime);
        t1 = hal_get_time();
        printcycles("small asymmetric_mul cycles:", t1 - t0);
#endif
        hal_send_str("OK KEYS\n");

        hal_send_str("#");
    }

    while (1)
        ;
    return 0;
}
