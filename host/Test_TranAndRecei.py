#!/usr/bin/env python3
import serial
import sys
import time
import curses
#Inform you port example:/dev/pts/2

def get_hex(value):
    convert_hex = hex(int(value))
    return convert_hex


if len(sys.argv) < 2:
  print("Usage: {0} [DEVICE]".format(sys.argv[0]))
  sys.exit(-1)


dev = serial.Serial(sys.argv[1], 115200)  #Open serial port

# hex_message1 = get_hex(sys.argv[2])
# hex_message2 = get_hex(sys.argv[3])
# hex_message3 =""
# hex_message3 = get_hex(sys.argv[4])
# if(sys.argv[4] == "add"):
#    hex_message3 = get_hex(00)
# elif(sys.argv[4] == "sub"):
#    hex_message3 = get_hex(1)
# elif(sys.argv[4] == "mul"):
#    hex_message3 = get_hex(2)
# elif(sys.argv[4] == "div"):
#    hex_message3 = get_hex(3)
# else:
#    hex_message3 = get_hex(0)

# message = str(hex_message1) + "-" +  str(hex_message2) + "-" + str(hex_message3) +"\n"
#message = "110\n\n101\n"                  #Format message
message = str(sys.argv[2]) + "-" +  str(sys.argv[3]) + "-" + str(sys.argv[4]) +"\n"
print("Send Data: ",message)
dev.write(message.encode())                #Waiting to read data
dataRaw = dev.read()
data = dataRaw.decode('utf8')             #Decode to string
print("Received Data: ",data)             #print