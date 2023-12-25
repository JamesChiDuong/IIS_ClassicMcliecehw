import os

baudrate = 3000000
hz = 100000000/baudrate
bit = baudrate * 10
counter = 100000000/bit
print(hz,counter)
folder = os.getcwd() + "/host" + "/kat" + "/kat.sage.py"

import sys
print(folder )
