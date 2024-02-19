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
FILE_CIPHER_0 = "cipher_0.out"
FILE_CIPHER_1 = "cipher_1.out"
FILE_ERROR = "error.out"
FILE_K_RESULT = "K.out"
#-------DEFINE DATA LENGTH-----------#
DATA_LENGTH_TIME = 48
DATA_LENGTH_CIPHER0 = 96
DATA_LENGTH_CIPHER1 = 32
DATA_LENGTH_K = 32
RAW_DATA_LENGTH = DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0 + DATA_LENGTH_CIPHER1 + DATA_LENGTH_K

#------Define these folder-----------#
kat_generate_folder = os.getcwd() + "/kat/kat_generate/"
kat_folder = os.getcwd() + "/kat/"
root_folder = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
result_folder = root_folder +"/build/simulation/results/"

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
    0x01: {TLV.Config.Type: int, TLV.Config.Name: 'SET_PK'},
    0x02: {TLV.Config.Type: bytes, TLV.Config.Name: 'SET_SEED'},
    0x03:   {TLV.Config.Type: bytes, TLV.Config.Name: 'START_ENCAP'},
}
    tlv_array = TLV()
    TLV.set_global_tag_map(config)

    if len(sys.argv) < 2:
        print("Usage: {0} [DEVICE]".format(sys.argv[0]))
        sys.exit(-1)
    
    if((sys.argv[1] == "check_data")):                      
        print("-------------------Checking encapsulation data-------------------\r\n")
        command = [
            'sage',
            kat_folder + '/kat.sage',
            '--check-encaps',
            '--kat-path',
            kat_generate_folder,
            '--pars',
            'mceliece348864',
            '--sessionkey',
            result_folder + FILE_K_RESULT,
            '--cipher',
            result_folder + FILE_CIPHER_0,
            result_folder + FILE_CIPHER_1
        ]
        try:
            subprocess.run(command, check=True)
            print("[mceliece348864-32-encapsulation] Test Passed!")
        except subprocess.CalledProcessError as e:
            print(f"Error: {e}")

    else:
        dev = serial.Serial(sys.argv[1], sys.argv[2])  #Open serial port

        file_exists = os.path.isfile(kat_generate_folder+"/"+FILE_SEED) | os.path.isfile(kat_generate_folder+"/"+FILE_PUBKEY)
        if(file_exists == False):
            exit("Doesn't exists")
        else:
            if((sys.argv[3] == "set_pk")):
                file = open(kat_generate_folder + FILE_PUBKEY)
                lines = file.read().replace('\n','')
                file.close()
                data = [lines[i:i + 8] for i in range(0,len(lines),8)]
                set_pk  = []
                count = 0
                for row in data:
                    set_pk_data = convert_binary_list_to_binary(row)
                    set_pk.append(set_pk_data)
                tlv_array['SET_PK'] = bytes(set_pk) #[0x0A,0x0B,0x0C,0x0D,0x2E,0x34,0x11,0x34]
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
                    print("Send Public data completed.\r\n")
                    print(dataRaw)
                else:
                    print("Read fail.\r\n",(time_buffer[0]) >> 8)
                    print(dataRaw)
            elif((sys.argv[3] == "set_seed")):
                file = open(kat_generate_folder + FILE_SEED)
                lines = file.read().replace('\n','')
                file.close()
                data = [lines[i:i + 8] for i in range(0,len(lines),8)]
                set_seed  = []
                count = 0
                for row in data:
                    set_seed_data = convert_binary_list_to_binary(row)
                    set_seed.append(set_seed_data)
                tlv_array['SET_SEED'] = bytes(set_seed)
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
                    print("Send Seed data completed.\r\n",time_buffer[0])
                    print(dataRaw)
                else:
                    print("Read fail.\r\n",(time_buffer[0]))
                    print("Read fail.\r\n",dataRaw)
            elif((sys.argv[3] == "start_encap")):
                set_checkdata  = [0x01]
                tlv_array['START_ENCAP'] = bytes(set_checkdata)
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
                time_encap_start = time_buffer[0]
                time_encapsulation = time_buffer[1]
                time_fixedweight_start = time_buffer[2]
                time_fixedweight = time_buffer[3]
                time_encrypt_start = time_buffer[4]
                time_encrypt = time_buffer[5]
                print("-------------------Read Data-------------------\r\n")
                print("Start Encapsulation: ",time_encap_start,"cycles")
                print("Stop Encapsulation: ",time_encapsulation," cycles")
                print("Start FixedWeight: ",time_fixedweight_start,"cycles")
                print("Stop FixedWeight: ",time_fixedweight,"cycles")
                print("Start Encode: ",time_encrypt_start,"cycles")
                print("Stop Encode: ",time_encrypt,"cycles")
                print("-------------------Writting to file-------------------\r\n")
                # Create the build/result directory if it doesn't exist
                os.makedirs(result_folder, exist_ok=True)
                with open(result_folder + FILE_CIPHER_0,'w') as file:
                    for i in range(int(DATA_LENGTH_TIME/8),int(DATA_LENGTH_TIME/8) + int(DATA_LENGTH_CIPHER0/4)):
                        file.write(format(time_buffer[i],'032b')+ '\n')
                print(FILE_CIPHER_0 + ":Done\r\n")
                with open(result_folder + FILE_CIPHER_1,'w') as file:
                    for i in range(int(DATA_LENGTH_TIME/8) + int(DATA_LENGTH_CIPHER0/4),int(DATA_LENGTH_TIME/8) + int(DATA_LENGTH_CIPHER0/4) + int(DATA_LENGTH_CIPHER1/4)):
                        file.write(format(time_buffer[i],'032b')+ '\n')
                print(FILE_CIPHER_1 + ":Done\r\n")
                with open(result_folder + FILE_K_RESULT,'w') as file:
                    for i in range(int(DATA_LENGTH_TIME/8) + int(DATA_LENGTH_CIPHER0/4) + int(DATA_LENGTH_CIPHER1/4),int(DATA_LENGTH_TIME/8) + int(DATA_LENGTH_CIPHER0/4) + int(DATA_LENGTH_CIPHER1/4) + int(DATA_LENGTH_K/4)):
                        file.write(format(time_buffer[i],'032b')+ '\n')
                print(FILE_K_RESULT + ":Done\r\n")
            else:
                print("Error: Please input set_pk or set_seed")
                exit()
