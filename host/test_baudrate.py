import os

baudrate = 115200
hz = 100000000/baudrate
bit = baudrate * 16
counter = 100000000/bit
print(hz,counter)
folder = os.getcwd() + "/host" + "/kat" + "/kat.sage.py"

import sys
print(folder )
