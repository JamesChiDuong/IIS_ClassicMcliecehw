from uttlv import TLV
import serial
import sys
import time
import curses
import os
import os.path
import random
import numpy as np
import sys
import subprocess
#kat_sage.McElieceIO()

#--------DEFINE_FILE--------------#
FILE_IRRED_RAND = "irred_rand.kat"
FILE_FIELDORDER_RAND = "field_order_rand.kat"
FILE_ERROR = "error.kat"
FILE_CIPHER_0 = "cipher_0.kat"
FILE_CIPHER_1 = "cipher_1.kat"
FILE_DELTA = "delta.kat"
FILE_DELTA_PRIME = "delta_prime.kat"
FILE_PUBKEY = "pubkey_32.kat"
FILE_POLY_G = "poly_g.kat"
FILE_P = "P.kat"
FILE_S = "s.kat"
FILE_K = "K.kat"
FILE_C = "c.kat"
FILE_SEED = "mem_512.kat"
FILE_CIPHER_0_OUT = "cipher_0.out"
FILE_CIPHER_1_OUT = "cipher_1.out"
FILE_ERROR = "error.out"
FILE_K_RESULT = "K.out"
#-------DEFINE DATA LENGTH-----------#
DATA_LENGTH_TIME = 24
DATA_LENGTH_CIPHER0 = 96
DATA_LENGTH_CIPHER1 = 32
DATA_LENGTH_K = 32
RAW_DATA_LENGTH = DATA_LENGTH_TIME + DATA_LENGTH_K

#------Define these folder-----------#

kat_folder = os.getcwd() + "/kat/"
root_folder = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..','..'))
result_folder = root_folder +"/build/simulation/results/"
kat_generate_folder = root_folder + "/host/kat/kat_generate/"
def convert_binary_list_to_binary(binary_list):

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

def write_binary_to_file(binary_string, filename):
    with open(filename, 'w') as file:
        file.write(binary_string)
#-----------------Define Variable---------------#
time_buffer = list(range(320))
leng = 0
#-----------------Main program------------------#
if __name__ == "__main__":
    config = {
    0x01: {TLV.Config.Type: int, TLV.Config.Name: 'SET_S'},
    0x02: {TLV.Config.Type: bytes, TLV.Config.Name: 'SET_C1'},
    0x03: {TLV.Config.Type: bytes, TLV.Config.Name: 'SET_C0'},
    0x04: {TLV.Config.Type: bytes, TLV.Config.Name: 'SET_POLY'},
    0x05: {TLV.Config.Type: bytes, TLV.Config.Name: 'START_DECAP'},
}
    tlv_array = TLV()
    TLV.set_global_tag_map(config)

    if len(sys.argv) < 2:
        print("Usage: {0} [DEVICE]".format(sys.argv[0]))
        sys.exit(-1)
    
    if((sys.argv[1] == "check_data")):                      
        print("-------------------Checking Decapsulation data-------------------\r\n")
        sed_command = [
            'sed', '-i', '-e', ':a', '-e', 'N;s/\\n//;ba', result_folder+ FILE_K_RESULT
        ]
        diff_command = [
        'diff', result_folder+ FILE_K_RESULT, kat_generate_folder + FILE_K
        ]
        try:
            subprocess.run(sed_command, check=True)
            subprocess.run(diff_command, check=True)
            print("[mceliece348864-32-decapsulation] Test Passed!")
        except subprocess.CalledProcessError as e:
            print(f"Error: {e}")

    else:
        dev = serial.Serial(sys.argv[1], sys.argv[2])  #Open serial port

        file_exists = os.path.isfile(kat_generate_folder+"/"+(FILE_DELTA_PRIME))  | os.path.isfile(kat_generate_folder+"/"+(FILE_CIPHER_1)) | os.path.isfile(kat_generate_folder+"/"+(FILE_CIPHER_0)) | os.path.isfile(kat_generate_folder+"/"+(FILE_POLY_G))
        if(file_exists == False):
            exit("Doesn't exists")
        else:
            if((sys.argv[3] == "set_s")):
                file = open(kat_generate_folder + FILE_DELTA_PRIME)
                lines = file.read().replace('\n','')
                file.close()
                data = [lines[i:i + 8] for i in range(0,len(lines),8)]
                set_delta  = []
                count = 0
                for row in data:
                    set_delta_data = convert_binary_list_to_binary(row)
                    set_delta.append(set_delta_data)
                tlv_array['SET_S'] = bytes(set_delta) #[0x0A,0x0B,0x0C,0x0D,0x2E,0x34,0x11,0x34]
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)
                dataRaw = dev.read(16)
                for i in range(0, len(dataRaw),8):
                    chunk = dataRaw[i:i+8]
                    time_buffer[leng] = int.from_bytes(chunk, 'little')
                    # print("Read Data:",hex(time_buffer[leng]))
                    leng += 1
                if((time_buffer[0]) >> 8 == 1):
                    print("-------------------Read Data-------------------\r\n")
                    print("Send Delta data completed.\r\n")
                else:
                    print("Read fail.\r\n",(time_buffer[0]) >> 8)
                    print(dataRaw)
            elif((sys.argv[3] == "set_C1")):
                file = open(kat_generate_folder + FILE_CIPHER_1)
                lines = file.read().replace('\n','')
                file.close()
                data = [lines[i:i + 8] for i in range(0,len(lines),8)]
                set_C1  = []
                count = 0
                for row in data:
                    set_C1_data = convert_binary_list_to_binary(row)
                    set_C1.append(set_C1_data)
                tlv_array['SET_C1'] = bytes(set_C1)
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)
                dataRaw = dev.read(16)
                for i in range(0, len(dataRaw),8):
                    chunk = dataRaw[i:i+8]
                    time_buffer[leng] = int.from_bytes(chunk, 'little')
                    # print("Read Data:",hex(time_buffer[leng]))
                    leng += 1
                if((time_buffer[0] >> 8) == 1):
                    print("-------------------Read Data-------------------\r\n")
                    print("Send C1 data completed.\r\n")
                else:
                    print("Read fail.\r\n",(time_buffer[0]))
            elif((sys.argv[3] == "set_C0")):
                file = open(kat_generate_folder + FILE_CIPHER_0)
                lines = file.read().replace('\n','')
                file.close()
                data = [lines[i:i + 8] for i in range(0,len(lines),8)]
                set_C0  = []
                count = 0
                for row in data:
                    set_C0_data = convert_binary_list_to_binary(row)
                    set_C0.append(set_C0_data)
                tlv_array['SET_C0'] = bytes(set_C0)
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)
                dataRaw = dev.read(16)
                for i in range(0, len(dataRaw),8):
                    chunk = dataRaw[i:i+8]
                    time_buffer[leng] = int.from_bytes(chunk, 'little')
                    # print("Read Data:",hex(time_buffer[leng]))
                    leng += 1
                if((time_buffer[0] >> 8) == 1):
                    print("-------------------Read Data-------------------\r\n")
                    print("Send C0 data completed.\r\n")
                else:
                    print("Read fail.\r\n",(time_buffer[0]))
            elif((sys.argv[3] == "set_POLY")):
                file = open(kat_generate_folder + FILE_POLY_G)
                lines = file.read().replace('\n','')
                file.close()
                data = [lines[i:i + 8] for i in range(0,len(lines),8)]
                set_poly  = []
                count = 0
                for row in data:
                    set_poly_data = convert_binary_list_to_binary(row)
                    set_poly.append(set_poly_data)
                tlv_array['SET_POLY'] = bytes(set_poly)
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)
                dataRaw = dev.read(16)
                for i in range(0, len(dataRaw),8):
                    chunk = dataRaw[i:i+8]
                    time_buffer[leng] = int.from_bytes(chunk, 'little')
                    # print("Read Data:",hex(time_buffer[leng]))
                    leng += 1
                if((time_buffer[0] >> 8) == 1):
                    print("-------------------Read Data-------------------\r\n")
                    print("Send POLY data completed.\r\n")
                else:
                    print("Read fail.\r\n",(time_buffer[0]))
            elif((sys.argv[3] == "start_decap")):
                set_checkdata  = [0x01]
                tlv_array['START_DECAP'] = bytes(set_checkdata)
                arr = tlv_array.to_byte_array()
                data = int.from_bytes(arr,'big')
                print("Send Data: ",hex(data))
                dev.write(arr)
                dataRaw = dev.read(RAW_DATA_LENGTH+1)
                #dataRaw = dev.read(1)
                test = 0
                #dataRaw = dev.readline() 
                for i in range(1, DATA_LENGTH_TIME,8):
                    chunk = dataRaw[i:i+8]
                    time_buffer[leng] = int.from_bytes(chunk, 'little')
                    print("Read Data:",hex(time_buffer[leng]),leng)
                    leng += 1
                for i in range((DATA_LENGTH_TIME + 1),(RAW_DATA_LENGTH + 1),4):
                    chunk = dataRaw[i:i+4]
                    time_buffer[leng] = int.from_bytes(chunk, 'little')
                    print("Read Data:",hex(time_buffer[leng]),test,leng )
                    leng += 1
                    test +=1
                time_fieldOrdering_finish = time_buffer[0]
                time_decap_finish = time_buffer[1]
                time_require = time_buffer[2]
                print("-------------------Read Data-------------------\r\n")
                print("FieldOrdering module started.")
                print("FieldOrdering finished.",time_fieldOrdering_finish," cycles")
                print("Decapsulation module started.")
                print("Decapsulation module finished.",time_decap_finish,"cycles")
                print("FieldOrdering and Decapsulation require",time_require,"cycles")
                print("-------------------Writting to file-------------------\r\n")
                # Create the build/result directory if it doesn't exist
                os.makedirs(result_folder, exist_ok=True)
                with open(result_folder + FILE_K_RESULT,'w') as file:
                    for i in range(int(DATA_LENGTH_TIME/8),int(DATA_LENGTH_TIME/8) + int(DATA_LENGTH_K/4)):
                        file.write(format(time_buffer[i],'032b')+ '\n')
                print(FILE_K_RESULT + ":Done\r\n")
            else:
                print("Error: Please input set_pk or set_seed")
                exit()
