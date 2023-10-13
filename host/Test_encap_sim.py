from uttlv import TLV
import serial
import sys
import time
import curses
from mceliece import keygen, encap, decap, parameters
import os
import random
from sage.all_cmdline import *   # import sage library
import numpy as np
_sage_const_2 = Integer(2); _sage_const_0 = Integer(0); _sage_const_1 = Integer(1); _sage_const_32 = Integer(32); _sage_const_16 = Integer(16); _sage_const_15 = Integer(15); _sage_const_7 = Integer(7)# *
def randombits(r):
    return [random.randrange(_sage_const_2 ) for j in range(r)]


def randombytes(r):
    return os.urandom(r)


class McElieceIO:

    # Definition of default filenames
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

    def __init__(self, folder, params):
        """
        Returns an IO object to write and read KAT files. The format of the
        KAT files is compatible with the memory layout of the Classic McEliece
        FPGA designs.
        """
        try:
            os.mkdir(folder)
        except:
            pass

        self.folder = folder + '/'
        self.params = params
        self.fmt = "{0:0" + str(self.params.m) + "b}"

    def write_e(self, error, f_error=None, slicewidth=None):
        if f_error is None: f_error = self.folder+self.FILE_ERROR
        with open(f_error, 'w') as f:
            if slicewidth is None:
                for i in range(self.params.n):
                    f.write(str(error[i]))
                f.write('\n')
            else:
                error_ = error
                if self.params.n % slicewidth != _sage_const_0 :
                    remainder = self.params.n % slicewidth
                    error_ += [_sage_const_0  for i in range(slicewidth-remainder)]
                for i in range(_sage_const_0 , self.params.n, slicewidth):
                    f.write("".join(str(v) for v in error_[i:i+slicewidth]) + '\n')

    def read_e(self, f_error=None):
        if f_error is None: f_error = self.folder+self.FILE_ERROR
        with open(f_error, 'r') as f:
            e = []
            lines = f.read().splitlines()
            for i in range(len(lines)):
                for ei in lines[i]:
                    e.append(parameters.F2(int(ei)))
        return e[:self.params.n]

    def write_C(self, C,
                f_cipher_0=None,
                f_cipher_1=None,
                slicewidth=None):
        if f_cipher_0 is None: f_cipher_0 = self.folder+self.FILE_CIPHER_0
        if f_cipher_1 is None: f_cipher_1 = self.folder+self.FILE_CIPHER_1
        c0, c1 = C
        c0 = c0.list()
        with open(f_cipher_0, 'w') as f:
            if slicewidth is None:
                for c in c0:
                    f.write(str(c))
                f.write('\n')
            else:
                c0_ = c0
                if len(c0_) % slicewidth != _sage_const_0 :
                    remainder = len(c0_) % slicewidth
                    c0_ += [_sage_const_0  for i in range(slicewidth-remainder)]
                for i in range(_sage_const_0 , len(c0_), slicewidth):
                    f.write("".join(str(v) for v in c0_[i:i+slicewidth]) + '\n')
        with open(f_cipher_1, 'w') as f:
            if slicewidth is None:
                for c in c1:
                    f.write(str(c))
                f.write('\n')
            else:
                c1_ = c1
                if len(c1_) % slicewidth != _sage_const_0 :
                    remainder = len(c1_) % slicewidth
                    c1_ += [_sage_const_0  for i in range(slicewidth-remainder)]
                for i in range(_sage_const_0 , len(c1_), slicewidth):
                    f.write("".join(str(v) for v in c1_[i:i+slicewidth]) + '\n')

    def read_C(self,
               f_cipher_0=None,
               f_cipher_1=None):
        if f_cipher_0 is None: f_cipher_0 = self.folder+self.FILE_CIPHER_0
        if f_cipher_1 is None: f_cipher_1 = self.folder+self.FILE_CIPHER_1
        with open(f_cipher_0, 'r') as f:
            c0 = []
            lines = f.read().splitlines()
            for i in range(len(lines)):
                for ci in lines[i]:
                    c0.append(parameters.F2(int(ci)))
        with open(f_cipher_1, 'r') as f:
            c1 = []
            lines = f.read().splitlines()
            for i in range(len(lines)):
                for ci in lines[i]:
                    c1.append(parameters.F2(int(ci)))
        return c0[:self.params.n-self.params.k], c1

    def write_delta(self, delta, f_delta=None):
        if f_delta is None: f_delta = self.folder+self.FILE_DELTA
        with open(f_delta, 'w') as f:
            for d in delta:
                f.write(str(d))
            f.write('\n')

    def read_delta(self, f_delta=None):
        pass

    def write_delta_prime(self, delta_prime,
                          f_delta_prime=None,
                          width=None):
        if f_delta_prime is None:
            f_delta_prime = self.folder+self.FILE_DELTA_PRIME
        with open(f_delta_prime, 'w') as f:
            temp = "".join([str(b) for b in delta_prime])
            if width is None:
                f.write(temp)
                f.write('\n')
            else:
                rem = len(temp) % width
                if rem != _sage_const_0 :
                    temp += '0'*(width - rem)
                for i in range(_sage_const_0 , len(temp), width):
                    f.write(temp[i:i+width]+'\n')

    def read_delta_prime(self, f_delta_prime=None):
        if f_delta_prime is None:
            f_delta_prime = self.folder+self.FILE_DELTA_PRIME
        with open(f_delta_prime, 'r') as f:
            d = []
            lines = f.read().splitlines()
            for line in lines:
                for di in line:
                    d.append(parameters.F2(int(di)))
        return d

    def write_pubkey(self, T, f_pubkey=None, slicewidth=None):
        if f_pubkey is None: f_pubkey = self.folder+self.FILE_PUBKEY
        if slicewidth is not None:
            pos = f_pubkey.rfind('.')
            f_pubkey = f_pubkey[:pos] + f"_{slicewidth}" + f_pubkey[pos:]
        with open(f_pubkey, 'w') as f:
            if slicewidth is None:
                f.write("\n".join(["".join([str(v) for v in r]) for r in T]) + "\n")
            else:
                for slicestart in range(_sage_const_0 , T.ncols(), slicewidth):
                    sliced_T = T[:, slicestart:slicestart+slicewidth]
                    sliced_T = sliced_T[:,::-_sage_const_1 ]
                    if sliced_T.ncols() < slicewidth:
                        diff = slicewidth - sliced_T.ncols()
                        sliced_T = matrix(T.nrows(),diff).augment(sliced_T)
                    f.write("\n".join(["".join([str(v) for v in r]) for r in sliced_T]) + "\n")

    def read_pubkey(self, f_pubkey=None, slicewidth=None):
        if f_pubkey is None: f_pubkey = self.folder+self.FILE_PUBKEY
        with open(f_pubkey, 'r') as f:
            lines = f.read().splitlines()
            T = matrix(GF(_sage_const_2 ), self.params.m*self.params.t, self.params.n-self.params.m*self.params.t)
            line_idx = _sage_const_0 
            column_width = slicewidth
            if slicewidth is None:
                for i in range(len(lines)):
                    T[i] = matrix(GF(_sage_const_2 ), [list(lines[i])])
            else:
                for column_offset in range(_sage_const_0 , self.params.n-self.params.m*self.params.t, column_width):
                    for row_idx in range(T.nrows()):
                        row = matrix(GF(_sage_const_2 ), [list(lines[line_idx])])
                        row = row[:, :slicewidth:-_sage_const_1 ]
                        if column_offset + slicewidth > T.ncols():
                            column_width = T.ncols() - column_offset
                        T[row_idx, column_offset:column_offset+column_width] = row[:,:column_width]
                        line_idx += _sage_const_1 
            return T

    def write_c(self, c, f_c=None):
        pass

    def read_c(self, f_c=None):
        pass

    def write_g(self, g, f_g=None, slicewidth=None):
        if f_g is None: f_g = self.folder+self.FILE_POLY_G
        with open(f_g, 'w') as f:
            if slicewidth is None:
                for i in reversed(range(self.params.t+_sage_const_1 )):
                    f.write(self.fmt.format(g[i].integer_representation()))
                    f.write('\n')
            else:
                temp = [self.fmt.format(g[i].integer_representation())
                       for i in reversed(range(self.params.t+_sage_const_1 ))]
                temp = "".join(temp)
                rem = len(temp) % slicewidth
                if rem != _sage_const_0 :
                    temp += '0'*(slicewidth - rem)
                for i in range(_sage_const_0 , len(temp), slicewidth):
                    f.write(temp[i:i+slicewidth]+'\n')

    def read_g(self, f_g=None, slicewidth=None):
        if f_g is None: f_g = self.folder+self.FILE_POLY_G
        Fqx = self.params.Fq['x']; (x,) = Fqx._first_ngens(1)
        with open(f_g, 'r') as f:
            beta = []
            if slicewidth is None:
                line = f.read()[:-_sage_const_1 ]
            else:
                line = f.read()
                line = "".join(line.splitlines())
                line = line[:(self.params.t+_sage_const_1 )*self.params.m]
            for offset in range(_sage_const_0 , len(line), self.params.m):
                bin = line[offset:offset+self.params.m]
                c = self.params.Fq.fetch_int(int(bin, _sage_const_2 ))
                beta.append(c)
            beta = beta[::-_sage_const_1 ]
            g = sum(beta[j]*x**j for j in range(self.params.t+_sage_const_1 ))
        return g

    def write_alphas(self, alphas, f_p=None):
        if f_p is None: f_p = self.folder+self.FILE_P
        with open(f_p, 'w') as f:
            for a in alphas:
                bin = a.integer_representation()
                bin = self.fmt.format(bin)
                f.write(bin[::-_sage_const_1 ])
                f.write("\n")

    def read_alphas(self, f_p=None):
        if f_p is None: f_p = self.folder+self.FILE_P
        with open(f_p, 'r') as f:
            alphas = []
            lines = f.read().splitlines()
            for bin in lines:
                bin = bin[::-_sage_const_1 ]
                alpha = self.params.Fq.fetch_int(int(bin, _sage_const_2 ))
                alphas.append(alpha)
        return alphas

    def write_s(self, s, f_s=None):
        if f_s is None: f_s = self.folder+self.FILE_S
        with open(f_s, 'w') as f:
            for b in s:
                f.write(str(b))
            f.write('\n')

    def read_s(self, f_s=None):
        if f_s is None: f_s = self.folder+self.FILE_S
        with open(f_s, 'r') as f:
            s = []
            line = f.read().splitlines()[_sage_const_0 ]
            for si in line:
                s.append(parameters.F2(int(si)))
        return s

    def write_K(self, K, f_K=None):
        if f_K is None: f_K = self.folder+self.FILE_K
        with open(f_K, 'w') as f:
            for b in K:
                f.write(str(b))
            f.write('\n')

    def read_K(self, f_K=None):
        if f_K is None: f_K = self.folder+self.FILE_K
        with open(f_K, 'r') as f:
            K = []
            lines = f.read().splitlines()
            for i in range(len(lines)):
                for Ki in lines[i]:
                    K.append(parameters.F2(int(Ki)))
        return K

    def write_seed(self, seed=None, f_seed=None):
        assert type(seed) == list or seed is None
        if f_seed is None: f_seed = self.folder+self.FILE_SEED
        if seed is None:
            seed = [[_sage_const_0  for i in range(_sage_const_32 )] for j in range(_sage_const_16 )]
            seed[_sage_const_15 ][_sage_const_7 ]=_sage_const_1 
        with open(f_seed, 'w') as f:
            for row in seed:
                for s in row:
                    f.write(str(s))
                f.write('\n')
        return seed

class McElieceKAT:
    def __init__(self, system, allowtestparams=True):
        """
        Returns a KAT object to generate or check KAT files.
        """
        self.params = parameters.parameters(system,
                                            allowtestparams=allowtestparams)
        self.params.pc = True
        prefix = f"[{system}-KAT]"
        self.msg = prefix + " {}"

    def gen(self, delta=None):
        """
        Generate the KAT files.
        """
        if delta is not None:
          delta = [int(i) for i in reversed(bin(delta)[_sage_const_2 :])]
          delta = [_sage_const_0 ] * (self.params.l - len(delta)) + delta
        else:
          delta = randombits(self.params.l)

        print(self.msg.format("Start KAT generation."))
        print(self.msg.format("Run SeededKeyGen."))
        T, privatekey = keygen.seededkeygen(delta, self.params)
        delta_prime, c, g, alpha, s = privatekey
        print(self.msg.format("Run Encap."))
        C, K, e = encap.encap_abstract(T, randombits, self.params)
        print(self.msg.format("Run Decap."))
        assert K == decap.decap_abstract(C, privatekey, self.params)
        print(self.msg.format("KAT generation done."))

        return delta, delta_prime, T, c, g, alpha, s, C, K, e

    def check_encaps(self, C, K, g, alphas, delta_prime=None):
        """
        Checks the ciphertext C and session key K which was computed
        by an external encapuslation operation. It uses the decapsulation
        operation and the private KAT files for the verification.
        """
        print(self.msg.format("Checking encapsulation data."))
        if delta_prime is None:
            privatekey = None, None, g, alphas, None
        else:
            _, privatekey = keygen.seededkeygen(delta=delta_prime,
                                                params=self.params)

        assert K == decap.decap_abstract(C, privatekey, self.params), f"K must be {K}"
        print(self.msg.format("Checking encapsulation data done."))

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
    data = ""
    for row in seed:
        binary_number = convert_binary_list_to_binary(row)
        print(binary_number)
    return binary_number


#Main program#
if __name__ == "__main__":
    config = {
    0x01: {TLV.Config.Type: int, TLV.Config.Name: 'SET_PK'},
    0x02: {TLV.Config.Type: int, TLV.Config.Name: 'SET_SEED'},
}
    tlv_array = TLV()
    TLV.set_global_tag_map(config)
    if len(sys.argv) < 2:
        print("Usage: {0} [DEVICE]".format(sys.argv[0]))
        sys.exit(-1)


    dev = serial.Serial(sys.argv[1], 115200)  #Open serial port
    params = parameters.parameters("mceliece348864", allowtestparams=True)
    folder = os.getcwd()
    katio = McElieceIO(folder,params)
    ##Write set_seed
#   #  tlv_array['SET_SEED'] = set_seed
#     arr = tlv_array.to_byte_array()
#     data = int.from_bytes(arr,'big')
    ###Write PK
    # matrix_pk = np.array(katio.write_pubkey())
    # set_pk = matrix_to_bytes(matrix_pk)
    if((sys.argv[2] == "set_pk")):
        tlv_array['SET_PK'] = 1
    elif((sys.argv[2] == "set_seed")):
        list_arr =  katio.write_seed()
        for row in list_arr:
            set_seed = convert_binary_list_to_binary(row)
            tlv_array['SET_SEED'] = set_seed
            arr = tlv_array.to_byte_array()
            data = int.from_bytes(arr,'big')
            print("Send Data: ",hex(data))
            dev.write(arr)
       # katio.write_seed()
    else:
        print("Error: Please input set_pk or set_seed")
        exit()

    
    #
    # print("Send Data: ",hex(data))
    # dev.write(arr)                #Waiting to r.toead data

    dataRaw = dev.read(8)
    print("Read Data:",dataRaw)
