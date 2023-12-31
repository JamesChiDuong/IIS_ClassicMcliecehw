

# This file was *autogenerated* from the file /home/james/Documents/IIS/FPGA/Cryto/ClassicMceliehw_FPGA/test/ClassicMceliehw_FPGA/host/kat//kat.sage
from sage.all_cmdline import *   # import sage library

_sage_const_2 = Integer(2); _sage_const_0 = Integer(0); _sage_const_1 = Integer(1); _sage_const_32 = Integer(32); _sage_const_16 = Integer(16); _sage_const_15 = Integer(15); _sage_const_7 = Integer(7)# *
# * Copyright (C) 2022
# * Authors: Norman Lahr <norman@lahr.email>
# *          Ruben Niederhagen <ruben@polycephaly.org>
# *
# * This program is free software; you can redistribute it and/or modify
# * it under the terms of the GNU General Public License as published by
# * the Free Software Foundation; either version 3 of the License, or
# * (at your option) any later version.
# *
# * This program is distributed in the hope that it will be useful,
# * but WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# * GNU General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License
# * along with this program; if not, write to the Free Software Foundation,
# * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
# *

import hashlib
import os
import random

from mceliece import keygen, encap, decap, parameters


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


if __name__ == "__main__":
    import re
    import argparse

    parser = argparse.ArgumentParser(
        description='Generate or check Known Answer Test (KAT) data for Classic McEliece.',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-p', '--pars',
                        type=str,
                        default="mceliece348864",
                        help='Name of the Classic McEliece parameter set.',
                        required=True)
    parser.add_argument('--kat-path',
                        type=str,
                        help='Path to the KAT data.')
    parser.add_argument('-g', '--generate',
                        action='store_true',
                        default=False,
                        help='Generate KAT data and write to folder \"<parameter set>/\".')
    parser.add_argument('--check-encaps',
                        action='store_true',
                        default=False,
                        help='Check encapsulation.')
    parser.add_argument('--cipher',
                        type=str,
                        nargs=_sage_const_2 ,
                        help='Filenames of the cipher texts C0 and C1.')
    parser.add_argument('--sessionkey',
                        type=str,
                        help='File name of the session key K.')
    parser.add_argument('--polyg',
                        type=str,
                        help='Filename of the Goppa polynomial g.')
    parser.add_argument('--alphas',
                        type=str,
                        help='Filename of the permuted alphas.')
    parser.add_argument('--deltaprime',
                        type=str,
                        help='Filename of delta_prime.')
    parser.add_argument('--delta',
                        type=lambda x: int(x,_sage_const_0 ),
                        default = None,
                        help='Delta for deterministic key generation.')
    parser.add_argument('--slicewidths',
                        nargs='*',
                        type=int,
                        help='Width(s) of slices for T. Generates additional public key files. Mutliple widths are supported.')

    args = parser.parse_args()

    system = args.pars
    kat = McElieceKAT(system, allowtestparams=True)
    params = parameters.parameters(system, allowtestparams=True)

    if args.kat_path is None:
        folder = system
    else:
        folder = args.kat_path

    katio = McElieceIO(folder, params)

    if args.generate:
        # Generate KATs
        delta, delta_prime, T, c, g, alphas, s, C, K, e = kat.gen(delta = args.delta)

        katio.write_delta(delta)

        # Write them to compatible files
        katio.write_delta_prime(delta_prime, width=_sage_const_32 )
        assert delta_prime == katio.read_delta_prime()

        katio.write_pubkey(T, slicewidth=None)
        if args.slicewidths is not None:
            for width in args.slicewidths:
                katio.write_pubkey(T, slicewidth=width)
        assert T == katio.read_pubkey(slicewidth=None)

        katio.write_g(g, slicewidth=_sage_const_32 )
        assert g == katio.read_g(slicewidth=_sage_const_32 )

        katio.write_alphas(alphas)
        assert alphas == katio.read_alphas()

        katio.write_s(s)
        assert s == katio.read_s()

        katio.write_C(C, slicewidth=_sage_const_32 )
        assert all(C) == all(katio.read_C())

        katio.write_K(K)
        assert K == katio.read_K()

        katio.write_e(e, slicewidth=None)
        assert e == katio.read_e()

        katio.write_seed()

        print(f"Wrote KAT files to folder \"{folder}/\".")

    elif args.check_encaps:
        # Read ciphertext and session key computed by encapsulation operation
        C_ = katio.read_C(args.cipher[_sage_const_0 ], args.cipher[_sage_const_1 ])
        K_ = katio.read_K(args.sessionkey)

        # Read private key KAT files
        g_ = katio.read_g(slicewidth=_sage_const_32 )
        alphas_ = katio.read_alphas()

        # Run the check
        kat.check_encaps(C_, K_, g_, alphas_)



