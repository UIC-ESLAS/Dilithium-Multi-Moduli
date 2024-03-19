#!/usr/bin/env python3

import datetime
import subprocess
import sys

import serial
import numpy as np
from config import Settings
import os.path


def run_test(scheme_path, scheme_name):
    subprocess.check_call(f"make clean", shell=True)
    subprocess.check_call(f"make PLATFORM=sam3x8e KECCAK=1 IMPLEMENTATION_PATH={scheme_path} ./bin/{scheme_name}_test.bin", shell=True)
    binary = f"./bin/{scheme_name}_test.bin"
    if os.path.isfile(binary) is False:
        print("Binary does not exist")
        exit()

    try:
        subprocess.check_call(f"bossac -a --erase --write --verify --boot=1 --port=/dev/ttyACM0 ./bin/{scheme_name}_test.bin", shell=True)
    except:
        print("bossac write failed --> retry")
        return run_test(scheme_path, scheme_name)

    # get serial output and wait for '#'
    with serial.Serial(Settings.SERIAL_DEVICE, 9600, timeout=1000) as dev:
        logs = b""
        log = b""
        device_output = b'0'
        while device_output != b'#':
            device_output = dev.read()
            if device_output == b'':
                print("timeout --> retry")
                return run_test(scheme_path, scheme_name)
            log += device_output
            if device_output == b'#':
                logs += (log)
                log = b""
    return logs


def test(scheme_path, scheme_name, ignoreErrors=False):
    logs = run_test(scheme_path, scheme_name)
    print(logs)
    if (logs.decode("utf-8")).count("OK") == 30:
        print("Success!")
    else:
        print("Failure! Did not receive 30 OKs")


now = datetime.datetime.now(datetime.timezone.utc)
print(f"% Testing implementation(s) {now}\n")

# uncomment the scheme variants that should be build and evaluated
for scheme_path in [
        "crypto_sign/dilithium2/m3",
        "crypto_sign/dilithium2/m3plant",
        "crypto_sign/dilithium3/m3",
        "crypto_sign/dilithium3/m3plant"
        "crypto_sign/dilithium5/m3plant"
    ]:
    scheme_name = scheme_path.replace("/", "_")
    test(scheme_path, scheme_name)
