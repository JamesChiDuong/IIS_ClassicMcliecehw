#!/usr/bin/env python3
import serial
import sys
import time
import curses
#Inform you port example:/dev/pts/2

operand_str = ""
operand = 0
output_number1 = 0
output_number2 = 0
output_result = 0

BITWISE_12BIT = 0xffffff

def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val

def get_hex(value):
  convert_string = int(value)
  convert_hex = hex(convert_string)
  return convert_hex

def get_byte(value,lengOfByte):
  return value.to_bytes(int(lengOfByte),'big')

if len(sys.argv) < 2:
  print("Usage: {0} [DEVICE]".format(sys.argv[0]))
  sys.exit(-1)


dev = serial.Serial(sys.argv[1], 115200)  #Open serial port
if((sys.argv[2].isdigit()== False or (int(sys.argv[2]) > 255))):
  print("Error: Please input number or input the data from 0-255")
  exit()


input_data = (((int(sys.argv[2]) << 16)) | (0x0C<<8) | 0x0A)

#input_data = (int(sys.argv[2]) << 32) | ((int(sys.argv[3]) << 24) | ((int(input_operand) << 16) | 0x0A))
message = get_byte(input_data,((input_data.bit_length()+1))/8)

print("Send Data: ",hex(input_data))
dev.write(message)                #Waiting to read data


dataRaw = dev.readline()

integer_big_endian = int.from_bytes(dataRaw, 'big')
hex_data = hex(integer_big_endian)

data_filter = integer_big_endian & BITWISE_12BIT

numberOfbyte = ((integer_big_endian.bit_length()+2)/8)

if(numberOfbyte == 5):
  output_number1 = data_filter >> 16########& (BITWISE_8BIT)


  output_number2 = (data_filter >>8) & 0xFF


print("Number of Bytes:", numberOfbyte)

print("Received Data: ",hex_data)             #print

print("Number: ", hex(output_number1), output_number1)
print("Address: ", hex(output_number2), output_number2)
