#!/usr/bin/env python3
import serial
import sys
import time
import curses
#Inform you port example:/dev/pts/2


if len(sys.argv) < 2:
  print("Usage: {0} [DEVICE]".format(sys.argv[0]))
  sys.exit(-1)

operand_str = ""
operand = 0
number1 = 0
number2 = 0
result = 0
BITWISE_12BIT = 0xffffffffffff

dev = serial.Serial(sys.argv[1], 115200)  #Open serial port

message = str(sys.argv[2]) + "-" +  str(sys.argv[3]) + "-" + str(sys.argv[4]) +"\n"
print("Send Data: ",message)
dev.write(message.encode())                #Waiting to read data

dataRaw = dev.readline()
#data = dataRaw.decode("utf8")
#hex = hex(data)
#hex_int = int(data,16)
#new_int = data + 0x200
#data = dataRaw.decode('utf8').strip()            #Decode to string
integer_big_endian = int.from_bytes(dataRaw, 'big')
hex_data = hex(integer_big_endian)

data_filter = integer_big_endian & BITWISE_12BIT

numberOfbyte = ((integer_big_endian.bit_length()+2)/8)


if(numberOfbyte == 8):
  number1 = data_filter >> 40########& (BITWISE_8BIT)


  number2 = (data_filter >>32) & 0xFF


  operand = (data_filter >> 24) & 0xFF

  result = (data_filter >> 8) & 0xFFFF

elif(numberOfbyte == 7):
  number1 = (data_filter >> 32) & 0xFF########& (BITWISE_8BIT)


  number2 = (data_filter >>24) & 0xFF


  operand = (data_filter >> 16) & 0xFF

  result = (data_filter >> 8)  & 0xFF

elif(numberOfbyte == 6):
  number1 = (data_filter >> 24) & 0xFF########& (BITWISE_8BIT)


  number2 = (data_filter >>16) & 0xFF


  operand = (data_filter >> 8) & 0xFF

  result = (data_filter)  & 0xFF

if(operand == 0x1):
   operand_str = "add"
elif(operand == 0x2):
   operand_str = "sub"
elif(operand == 0x3):
   operand_str = "mul" 
elif(operand == 0x4):
   operand_str = "div"

print("Number of Bytes:", numberOfbyte)

print("Received Data: ",hex_data)             #print

print("Number1: ", hex(number1), number1)
print("Number2: ", hex(number2), number2)
print("Operand: ", hex(operand), operand_str)
print("Result: ", hex(result), result)
