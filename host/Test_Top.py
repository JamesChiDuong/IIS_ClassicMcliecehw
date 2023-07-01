#!/usr/bin/env python3
import serial
import sys
import time
import curses
#Inform you port example:/dev/pts/2
if len(sys.argv) < 2:
  print("Usage: {0} [DEVICE]".format(sys.argv[0]))
  sys.exit(-1)


dev = serial.Serial(sys.argv[1], 115200)  #Open serial port
message = "110\n101\n\n"                  #Format message
print("Send Data: ",message)
dev.write(message.encode())                #Waiting to read data
dataRaw = dev.readline()
data = dataRaw.decode('utf8')             #Decode to string
print("Received Data: ",data)             #print
