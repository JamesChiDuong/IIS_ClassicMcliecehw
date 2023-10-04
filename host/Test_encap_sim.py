from uttlv import TLV
import serial
import sys
import time
import curses

config = {
    0x01: {TLV.Config.Type: int, TLV.Config.Name: 'SET_PK'},
    0x02: {TLV.Config.Type: int, TLV.Config.Name: 'SET_SEED'},
    0x03: {TLV.Config.Type: str, TLV.Config.Name: 'NAME'},
    0x04: {TLV.Config.Type: str, TLV.Config.Name: 'CITY'},
    0x05: {TLV.Config.Type: bytes, TLV.Config.Name: 'VERSION'},
    0x06: {TLV.Config.Type: bytes, TLV.Config.Name: 'DATA'},
}
tlv_array = TLV()
TLV.set_global_tag_map(config)

if len(sys.argv) < 2:
  print("Usage: {0} [DEVICE]".format(sys.argv[0]))
  sys.exit(-1)


dev = serial.Serial(sys.argv[1], 115200)  #Open serial port

if((sys.argv[2] == "set_pk")):
    tlv_array['SET_PK'] = 1
elif((sys.argv[2] == "set_seed")):
    tlv_array['SET_SEED'] = 3
else:
    print("Error: Please input set_pk or set_seed")
    exit()

arr = tlv_array.to_byte_array()
data = int.from_bytes(arr,'big')
print("Send Data: ",hex(data),bytes(arr))
dev.write(arr)                #Waiting to read data

dataRaw = dev.read(8)
print("Read Data:",dataRaw)
