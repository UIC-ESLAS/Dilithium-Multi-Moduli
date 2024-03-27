#!/usr/bin/env python3

import datetime
import subprocess
import sys

import serial
import numpy as np
from config import Settings
import os.path


def run_test(scheme_path, scheme_name, keccak):
    subprocess.check_call(f"make clean", shell=True)
    subprocess.check_call(f"make -j 12 KECCAK={keccak} IMPLEMENTATION_PATH={scheme_path} bin/{scheme_name}_test.bin", shell=True)
    binary = f"bin/{scheme_name}_test.bin"
    print(binary)
    if os.path.isfile(binary) is False:
        print("Binary does not exist")
        exit()

    try:
        subprocess.check_call(f"st-flash --reset write {binary} 0x8000000", shell=True)
    except:
        print("st-flash failed --> retry")
        subprocess.check_call(
            f"st-flash erase && st-flash reset", shell=True)
        return run_test(scheme_path, scheme_name, keccak)

    # get serial output and wait for '#'
    with serial.Serial(Settings.SERIAL_DEVICE, 38400, timeout=10) as dev:
        logs = b""
        log = b""
        device_output = b''
        while device_output != b'#':
            device_output = dev.read()
            if device_output == b'':
                print("timeout --> retry")
                return run_test(scheme_path, scheme_name, keccak)
            log += device_output
            if device_output == b'#':
                logs += (log)
                log = b""
    return logs


def test(scheme_path, scheme_name, keccak, ignoreErrors=False):
    logs = run_test(scheme_path, scheme_name, keccak)
    print(logs)
    if (logs.decode("utf-8")).count("OK") == 30:
        print("Success!")
    else:
        print("Failure! Did not receive 30 OKs")


now = datetime.datetime.now(datetime.timezone.utc)
print(f"% Testing implementation(s) {now}\n")
subprocess.check_call(f"make clean", shell=True)
# uncomment the scheme variants that should be build and evaluated
for scheme_path in [
        "crypto_sign/dilithium2/old",
        "crypto_sign/dilithium3/old",
        "crypto_sign/dilithium5/old"
    ]:
    scheme_name = scheme_path.replace("/", "_")
    test(scheme_path, scheme_name, 0)

subprocess.check_call(f"make clean", shell=True)
for scheme_path in [
        "crypto_sign/dilithium2/old",
        "crypto_sign/dilithium3/m4plant",
        "crypto_sign/dilithium5/old"
    ]:
    scheme_name = scheme_path.replace("/", "_")
    test(scheme_path, scheme_name, 1)
