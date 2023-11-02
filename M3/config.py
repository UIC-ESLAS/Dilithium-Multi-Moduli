
import platform

class Settings:
    if platform.system() == "Linux":
        SERIAL_DEVICE = "/dev/ttyACM0"
    else:
        raise Exception("OS not supported")
