#!/usr/bin/env python3

import sys
import time

import serial

class IogearGHSW8141:
    def __init__(self, device_path: str):
        self.serial = serial.Serial(
            port=device_path,
            baudrate=19200,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
        )

    def close(self):
        self.serial.close()

    def send_command(self, command: str):
        self.serial.write(b"\r\n")
        time.sleep(0.25)
        command = command.encode("ascii")
        self.serial.write(command + b"\r\n")

    def set_power_on_detection(self, state: bool):
        state_str = {
            True: "on",
            False: "off"
        }
        self.send_command(f"pod {state_str}")

    def set_input(self, input: int):
        self.send_command(f"sw i{input:02d}")

    def next_input(self):
        self.send_command("sw +")

    def previous_input(self):
        self.send_command("sw -")

iog = IogearGHSW8141("/dev/ttyUSB0")

if __name__ == "__main__":
    iog.set_input(int(sys.argv[1]))
    iog.close()
