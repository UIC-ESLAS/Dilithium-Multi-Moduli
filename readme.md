# Revisiting Keccak and Dilithium Implementations on ARMv7-M
This repository provides code for our implementations of Keccak and Dilithium using the improved Plantard arithmetic on two ARMv7-M microprocessors: ARM Cortex-M3 and Cortex-M4.

Authors: 
 - [Junhao Huang](https://github.com/JunhaoHuang) `<huangjunhao@uic.edu.cn>`
 - [Alexandre Adomnicăi](https://github.com/aadomn) `<alexandre@adomnicai.me>`
 - [Jipeng Zhang](https://github.com/Ji-Peng) `<jp-zhang@outlook.com>`
 - Wangchen Dai `<w.dai@my.cityu.edu.hk>` 
 - Yao Liu `<liuyao25@mail.sysu.edu.cn>`
 - Ray C. C. Cheung `<r.cheung@cityu.edu.hk>`
 - Çetin Kaya Koç `<cetinkoc@ucsb.edu>`
 - Donglong Chen `<donglongchen@uic.edu.cn>` (Corresponding Author)


The setups for testing and evaluating of our code are based on the framework provided in the [pqm3](https://github.com/mupq/pqm3) and [pqm4](https://github.com/mupq/pqm4) projects.
## Prerequisites

- `arm-none-eabi-gcc`: version 10.2.1
- `libopencm3`: commit `1f3abd43763fa39d23e737602b6d0011a45c70b2` from [GitHub](https://github.com/libopencm3/libopencm3/tree/1f3abd43763fa39d23e737602b6d0011a45c70b2)
- `st-link` for flashing the binaries
- `python3` with the packages `pyserial` and `numpy` (only required for the evaluation scripts)
- Hardware: `STM32F407G-DISC1` and `Arduino Due` development board with `sam3x8e`

## Files in this archive
- `keccak`: contains code for Keccak on ARMv7-M by Alexandre Adomnicăi
- `M3`: contains code for Dilithium on ARM Cortex-M3
  - `common`: contains code that is shared between different schemes
    - `keccak1600.S`: the proposed keccak implementation
    - `keccak1600_XKCP.S`: the XKCP keccak implementation
  - `config.py`: Saves platform configuration
  - `crypto_sign`: contains the implementations for dilithium2, dilithium3, and dilithium5
      - `dilithium2`
          - `m3plant`: Our code with the improved Plantard arithmetic based on the implementation in [GKS20].
          - `m3`: Code in [GKS20]
      - `dilithium3`
          - `m3plant`: Our code with the improved Plantard arithmetic based on the implementation in [GKS20].
          - `m3`: Code in [GKS20]
      - `dilithium5`
          - `m3plant`: Our code with the improved Plantard arithmetic based on the implementation in [GKS20].
          - `m3`: Code in [GKS20]
      - `f_speed.c`: Firmware used for benchmarking parts of the scheme. Can be used by using `f_benchmarks.py`.
      - `speed.c`: From pqm3; Firmware for benchmarking the schemes' cycle counts. Can be used by using `benchmarks.py`.
      - `stack.c`: From pqm3; Firmware for benchmarking the schemes' stack usage. Can be used by using `stack_benchmarks.py`.
      - `test.c`: From pqm3; Firmware for self-testing the schemes. Can be used by using `test.py`.
      - `testvectors.c`: From pqm3; Firmware for computing testvectors for Dilithium only.
  - `ldscripts`: Linker script for sam3x8e.
  - `benchmarks.py`: This script is used for building, flashing, and evaluating the outputs produced by `speed.c`. The desired algorithms as well as the number of iterations can be set in the code.
  - `f_benchmarks.py`: This script is used for building, flashing, and evaluating the outputs produced by `f_speed.c`. The desired algorithms as well as the number of iterations can be set in the code.
  - `stack_benchmarks.py`: This script is used for building, flashing, and evaluating the outputs produced by `stack.c`. The desired algorithms as well as the number of iterations can be set in the code.
- `M4`: contains code for Dilithium on ARM Cortex-M4
  - `common`: contains code that is shared between different schemes
    - `keccak1600.S`: the proposed keccak implementation
    - `keccak1600_XKCP.S`: the XKCP keccak implementation
  - `config.py`: Saves platform configuration
  - `crypto_sign`: contains the implementations for dilithium2, dilithium3, and dilithium5
      - `dilithium2`
          - `old`: Code in [AHKS22]
      - `dilithium3`
          - `m4plant`: Our code with the improved Plantard arithmetic based on the implementation in [AHKS22].
          - `old`: Code in [AHKS22]
      - `dilithium5`
          - `old`: Code in [AHKS22]
      - `f_speed.c`: Firmware used for benchmarking parts of the scheme. Can be used by using `f_benchmarks.py`.
      - `speed.c`: From pqm4; Firmware for benchmarking the schemes' cycle counts. Can be used by using `benchmarks.py`.
      - `stack.c`: From pqm4; Firmware for benchmarking the schemes' stack usage. Can be used by using `stack_benchmarks.py`.
      - `test.c`: From pqm4; Firmware for self-testing the schemes. Can be used by using `test.py`.
      - `testvectors.c`: From pqm4; Firmware for computing testvectors for Dilithium only.
  - `gen_table`: contains code to generate the twiddle factors in Plantard domain for our implementations.
  - `Makefile`: Makefile to build the code
  - `benchmarks.py`: This script is used for building, flashing, and evaluating the outputs produced by `speed.c`. The desired algorithms as well as the number of iterations can be set in the code.
  - `f_benchmarks.py`: This script is used for building, flashing, and evaluating the outputs produced by `f_speed.c`. The desired algorithms as well as the number of iterations can be set in the code.
  - `stack_benchmarks.py`: This script is used for building, flashing, and evaluating the outputs produced by `stack.c`. The desired algorithms as well as the number of iterations can be set in the code.
  - `stm32f405x6_full.ld`: Linker script using 128kB of memory (SRAM1 and SRAM2)
  - `stm32f405x6.ld`: Linker script using 112kB of memory (SRAM1 only)
  - `stm32f4discovery.cfg`: Configuration for openocd in case debugging is desired
  - `test.py`: This script is used for building, flashing, and evaluating the outputs produced by `test.c`.

## ARM Cortex-M3
Detailed instructions on interacting with the hardware and on installing required software can be found in [pqm3](https://github.com/mupq/pqm3)'s readme.

The scripts `benchmarks.py`, `f_benchmarks.py`, `stack.py` and `test.py` cover most of the frequent use cases.
In case separate, manual testing is required, the binaries for a scheme can be build using
```
make IMPLEMENTATION_PATH=crypto_{kem,sign}/{scheme}/{variant} bin/crypto_{kem,sign}_{scheme}_{variant}_{firmware}.bin
```
, where `firmware` is one of `{test, testvectors, speed, f_speed, stack}` and `variant` is the specific implementation.

It can then be flashed using: 
```
bossac -a --erase --write --verify --boot=1 --port=/dev/ttyACM0 bin/crypto_{kem,sign}_{scheme}_{variant}_{firmware}.bin
```
### Example on M3
For building the `test` firmware for our m3plant version of `dilithium2` the following command can be used:
```
# build
make IMPLEMENTATION_PATH=crypto_sign/dilithium2/m3plant bin/crypto_sign_dilithium2_m3plant_test.bin

# It can the be flashed using:

bossac -a --erase --write --verify --boot=1 --port=/dev/ttyACM0 bin/crypto_sign_dilithium2_m3plant_test.bin

# Get output:
pyserial-miniterm /dev/ttyACM0

# Output like this:
--- Miniterm on /dev/ttyACM0  9600,8,N,1 ---
--- Quit: Ctrl+] | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---
```


## ARM Cortex-M4
Detailed instructions on interacting with the hardware and on installing required software can be found in [pqm4](https://github.com/mupq/pqm4)'s readme.

The scripts `benchmarks.py`, `f_benchmarks.py`, `stack.py` and `test.py` cover most of the frequent use cases.
In case separate, manual testing is required, the binaries for a scheme can be build using
```
make IMPLEMENTATION_PATH=crypto_{kem,sign}/{scheme}/{variant} bin/crypto_{kem,sign}_{scheme}_{variant}_{firmware}.bin
```
, where `firmware` is one of `{test, testvectors, speed, f_speed, stack}` and `variant` is the specific implementation.

It can then be flashed using: 
```
st-flash --reset write bin/crypto_{kem,sign}_{scheme}_{variant}_{firmware}.bin 0x8000000
```
### Example on M4

For building the `test` firmware for our new version of `dilithium3` the following command can be used:
```
make IMPLEMENTATION_PATH=crypto_sign/dilithium3/new bin/crypto_sign_dilithium3_new_test.bin

# It can the be flashed using:
st-flash --reset write bin/crypto_sign_dilithium3_new_test.bin 0x8000000

# Get output:
python3 read_guest.py
```

<!-- TODO -->
## Code size
The code size of the implementation is evaluated with the `arm-none-eabi-size`.

```
arm-none-eabi-size -t {binary_file}
```
Use `code_size.py` to evaluate the code size of the specific implementation.


### References
[AHKS22] Amin Abdulrahman, Vincent Hwang, Matthias J. Kannwischer, and Amber Sprenkels. Faster Kyber and Dilithium on the Cortex-M4. In Giuseppe Ateniese and Daniele Venturi, editors, Applied Cryptography and Network Security - 20th International Conference, ACNS 2022: 853-871.  
[GKS20] Denisa O. C. Greconici, Matthias J. Kannwischer, and Amber Sprenkels. Compact Dilithium Implementations on Cortex-M3 and Cortex-M4. IACR Transactions on Cryptographic Hardware and Embedded Systems, 2021(1):1–24, Dec. 2020. 


### License

Each subdirectory containing implementations contains a LICENSE or COPYING file stating under what license that specific implementation is released. The files in common contain licensing information at the top of the file (and are currently either public domain or MIT). All other code in this repository is licensed under the Creative Commons Attribution 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/.

### Citation

Please cite our paper if you want to use this repository.

@article{Huang2023Revisit,  
author = {Junhao Huang, Alexandre Adomnic\u{a}i, Jipeng Zhang, Wangchen Dai, Yao Liu, Ray C. C. Cheung, \c{C}etin Kaya Ko\c{c}, and Donglong Chen},  
title = {Revisiting Keccak and Dilithium Implementations on ARMv7-M},  
}