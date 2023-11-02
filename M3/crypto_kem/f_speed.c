#include "api.h"
#include "hal.h"
#include "sendfn.h"

#include <stdint.h>
#include <string.h>

#include "poly.h"
#include "implvariant.h"
// https://stackoverflow.com/a/1489985/1711232
#define PASTER(x, y) x##y
#define EVALUATOR(x, y) PASTER(x, y)
#define NAMESPACE(fun) EVALUATOR(MUPQ_NAMESPACE, fun)

// use different names so we can have empty namespaces
#define MUPQ_CRYPTO_BYTES NAMESPACE(CRYPTO_BYTES)
#define MUPQ_CRYPTO_PUBLICKEYBYTES NAMESPACE(CRYPTO_PUBLICKEYBYTES)
#define MUPQ_CRYPTO_SECRETKEYBYTES NAMESPACE(CRYPTO_SECRETKEYBYTES)
#define MUPQ_CRYPTO_CIPHERTEXTBYTES NAMESPACE(CRYPTO_CIPHERTEXTBYTES)
#define MUPQ_CRYPTO_ALGNAME NAMESPACE(CRYPTO_ALGNAME)

#define MUPQ_crypto_kem_keypair NAMESPACE(crypto_kem_keypair)
#define MUPQ_crypto_kem_enc NAMESPACE(crypto_kem_enc)
#define MUPQ_crypto_kem_dec NAMESPACE(crypto_kem_dec)

#define printcycles(S, U) send_unsignedll((S), (U))

void speedNTT()
{
	poly a, b;
	unsigned long long t0, t1;

	for (int i = 0; i < 256; i++)
	{
		a.coeffs[i] = i;
	}

	t0 = hal_get_time();
	poly_ntt(&a);
	t1 = hal_get_time();
	printcycles("ntt cycles:", (t1 - t0));

#if defined(optstack) || defined(mont)
	t0 = hal_get_time();
	poly_basemul(&b, &a, &a);
	t1 = hal_get_time();
	printcycles("basemul cycles:", (t1 - t0));
#elif defined(optspeed)
	int32_t r_tmp[KYBER_N];
	poly_half a_prime;

	t0 = hal_get_time();
	poly_basemul_opt_16_32(r_tmp, &a, &b, &a_prime);
	t1 = hal_get_time();
	printcycles("poly_basemul_opt_16_32 cycles:", (t1 - t0));

	t0 = hal_get_time();
	poly_basemul_acc_opt_32_32(r_tmp, &a, &b, &a_prime);
	t1 = hal_get_time();
	printcycles("poly_basemul_acc_opt_32_32 cycles:", t1 - t0);

	t0 = hal_get_time();
	poly_basemul_acc_opt_32_16(&a, &a, &b, &a_prime, r_tmp);
	t1 = hal_get_time();
	printcycles("poly_basemul_acc_opt_32_16 cycles:", t1 - t0);
#endif

	t0 = hal_get_time();
	poly_invntt(&a);
	t1 = hal_get_time();
	printcycles("invntt cycles:", t1 - t0);
}

int main(void)
{
	hal_setup(CLOCK_BENCHMARK);

	// Uncomment it to benchmark NTT operations using new_poly_benchmarks.py
	hal_send_str("==========================");
	for (int i = 0; i < MUPQ_ITERATIONS; i++){
		speedNTT();
		hal_send_str("+");
	}
	hal_send_str("#");

	return 0;
}
