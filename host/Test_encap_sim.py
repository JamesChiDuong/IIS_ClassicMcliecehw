from uttlv import TLV
import serial
import sys
import time
import curses
import os
import os.path
import random
import numpy as np
#--------DEFINE_FILE--------------#
FILE_IRRED_RAND = "irred_rand.kat"
FILE_FIELDORDER_RAND = "field_order_rand.kat"
FILE_ERROR = "error.kat"
FILE_CIPHER_0 = "cipher_0.kat"
FILE_CIPHER_1 = "cipher_1.kat"
FILE_DELTA = "delta.kat"
FILE_DELTA_PRIME = "delta_prime.kat"
FILE_PUBKEY = "pubkey.kat"
FILE_POLY_G = "poly_g.kat"
FILE_P = "P.kat"
FILE_S = "s.kat"
FILE_K = "K.kat"
FILE_C = "c.kat"
FILE_SEED = "mem_512.kat"

def convert_binary_list_to_binary(binary_list):
  """Converts a binary list to a binary number.

  Args:
    binary_list: A list of binary elements.

  Returns:
    A binary number.
  """

  # Convert each element of the row to a binary string.
  binary_strings = []
  for element in binary_list:
    binary_string = str(element)
    binary_strings.append(binary_string)

  # Join the binary strings together.
  joined_binary_string = ''.join(binary_strings)

  # Convert the joined binary string to a binary number.
  binary_number = int(joined_binary_string, 2)

  return binary_number

def convert_seed_to_interger(seed):
    for row in seed:
        binary_number = convert_binary_list_to_binary(row)
        print(binary_number)
    return binary_number

#-----------------Define Variable---------------#
time_buffer = list(range(8))
leng = 0
#-----------------Main program------------------#
if __name__ == "__main__":
    config = {
    0x01: {TLV.Config.Type: int, TLV.Config.Name: 'SET_PK'},
    0x02: {TLV.Config.Type: int, TLV.Config.Name: 'SET_SEED'},
}
    tlv_array = TLV()
    TLV.set_global_tag_map(config)
    folder = os.getcwd() + "/kat/kat_generate"
    
    if len(sys.argv) < 2:
        print("Usage: {0} [DEVICE]".format(sys.argv[0]))
        sys.exit(-1)
    
    dev = serial.Serial(sys.argv[1], 115200)  #Open serial port

    file_exists = os.path.isfile(folder+"/"+FILE_SEED) | os.path.isfile(folder+"/"+FILE_PUBKEY)
    if(file_exists == False):
        exit("Doesn't exists")
    
    else:
        if((sys.argv[2] == "set_pk")):
            file = open(folder + "/" + FILE_PUBKEY)
            lines = file.readlines()
            file.close()
            for row in lines:
                set_pk = convert_binary_list_to_binary(row)
                tlv_array['SET_PK'] = set_pk
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)

        elif((sys.argv[2] == "set_seed")):
            file = open(folder + "/" + FILE_SEED)
            lines = file.readlines()
            file.close()
            for row in lines:
                set_seed = convert_binary_list_to_binary(row)
                tlv_array['SET_SEED'] = set_seed
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)
                time.sleep(0)
        else:
            print("Error: Please input set_pk or set_seed")
            exit()
    dataRaw = dev.read(48)
    #dataRaw = dev.readline() 
    for i in range(0, len(dataRaw),8):
        chunk = dataRaw[i:i+8]
        time_buffer[leng] = int.from_bytes(chunk, 'little')
        # print("Read Data:",hex(time_buffer[leng]))
        leng += 1

time_encap_start = time_buffer[0] >> 8
time_encapsulation = time_buffer[1] >> 8
time_fixedweight_start = time_buffer[2] >> 8 
time_fixedweight = time_buffer[3] >> 8
time_encrypt_start = time_buffer[4] >> 8
time_encrypt = time_buffer[5] >> 8
print("-------------------Read Data-------------------\r\n")
print("Start Encapsulation: ",time_encap_start,"cycles")
print("Stop Encapsulation: ",time_encapsulation," cycles")
print("Start FixedWeight: ",time_fixedweight_start,"cycles")
print("Stop FixedWeight: ",time_fixedweight,"cycles")
print("Start Encode: ",time_encrypt_start,"cycles")
print("Stop Encode: ",time_encrypt,"cycles")