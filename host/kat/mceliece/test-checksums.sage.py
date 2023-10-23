

# This file was *autogenerated* from the file test-checksums.sage
from sage.all_cmdline import *   # import sage library

_sage_const_0xffffffff = Integer(0xffffffff); _sage_const_16 = Integer(16); _sage_const_12 = Integer(12); _sage_const_20 = Integer(20); _sage_const_8 = Integer(8); _sage_const_24 = Integer(24); _sage_const_7 = Integer(7); _sage_const_25 = Integer(25); _sage_const_1634760805 = Integer(1634760805); _sage_const_857760878 = Integer(857760878); _sage_const_2036477234 = Integer(2036477234); _sage_const_1797285236 = Integer(1797285236); _sage_const_0 = Integer(0); _sage_const_32 = Integer(32); _sage_const_4 = Integer(4); _sage_const_1 = Integer(1); _sage_const_2 = Integer(2); _sage_const_3 = Integer(3); _sage_const_10 = Integer(10); _sage_const_5 = Integer(5); _sage_const_9 = Integer(9); _sage_const_13 = Integer(13); _sage_const_6 = Integer(6); _sage_const_14 = Integer(14); _sage_const_11 = Integer(11); _sage_const_15 = Integer(15); _sage_const_255 = Integer(255); _sage_const_18 = Integer(18); _sage_const_64 = Integer(64); _sage_const_736 = Integer(736); _sage_const_63 = Integer(63)
from . import parameters
from . import encap
from . import decap
from . import keygen

def randomuint8():
  global randombytes_key
  global randombytes_buf
  global randombytes_pos
  if randombytes_pos == len(randombytes_buf):
    h = []

    def quarterround(a,b,c,d):
      a += b
      a &= _sage_const_0xffffffff 
      d = ZZ(d).__xor__(a)
      d = (d<<_sage_const_16 )|(d>>_sage_const_16 )
      d &= _sage_const_0xffffffff 
      c += d
      c &= _sage_const_0xffffffff 
      b = ZZ(b).__xor__(c)
      b = (b<<_sage_const_12 )|(b>>_sage_const_20 )
      b &= _sage_const_0xffffffff 
      a += b
      a &= _sage_const_0xffffffff 
      d = ZZ(d).__xor__(a)
      d = (d<<_sage_const_8 )|(d>>_sage_const_24 )
      d &= _sage_const_0xffffffff 
      c += d
      c &= _sage_const_0xffffffff 
      b = ZZ(b).__xor__(c)
      b = (b<<_sage_const_7 )|(b>>_sage_const_25 )
      b &= _sage_const_0xffffffff 
      return a,b,c,d

    for pos in range(_sage_const_12 ):
      x = [_sage_const_1634760805 ,_sage_const_857760878 ,_sage_const_2036477234 ,_sage_const_1797285236 ]
      k = randombytes_key
      for i in range(_sage_const_0 ,_sage_const_32 ,_sage_const_4 ):
        x += [k[i]+(k[i+_sage_const_1 ]<<_sage_const_8 )+(k[i+_sage_const_2 ]<<_sage_const_16 )+(k[i+_sage_const_3 ]<<_sage_const_24 )]
      x += [pos,_sage_const_0 ,_sage_const_0 ,_sage_const_0 ]
      y = copy(x)
      for i in range(_sage_const_10 ):
        x[_sage_const_0 ],x[_sage_const_4 ],x[_sage_const_8 ],x[_sage_const_12 ] = quarterround(x[_sage_const_0 ],x[_sage_const_4 ],x[_sage_const_8 ],x[_sage_const_12 ])
        x[_sage_const_1 ],x[_sage_const_5 ],x[_sage_const_9 ],x[_sage_const_13 ] = quarterround(x[_sage_const_1 ],x[_sage_const_5 ],x[_sage_const_9 ],x[_sage_const_13 ])
        x[_sage_const_2 ],x[_sage_const_6 ],x[_sage_const_10 ],x[_sage_const_14 ] = quarterround(x[_sage_const_2 ],x[_sage_const_6 ],x[_sage_const_10 ],x[_sage_const_14 ])
        x[_sage_const_3 ],x[_sage_const_7 ],x[_sage_const_11 ],x[_sage_const_15 ] = quarterround(x[_sage_const_3 ],x[_sage_const_7 ],x[_sage_const_11 ],x[_sage_const_15 ])
        x[_sage_const_0 ],x[_sage_const_5 ],x[_sage_const_10 ],x[_sage_const_15 ] = quarterround(x[_sage_const_0 ],x[_sage_const_5 ],x[_sage_const_10 ],x[_sage_const_15 ])
        x[_sage_const_1 ],x[_sage_const_6 ],x[_sage_const_11 ],x[_sage_const_12 ] = quarterround(x[_sage_const_1 ],x[_sage_const_6 ],x[_sage_const_11 ],x[_sage_const_12 ])
        x[_sage_const_2 ],x[_sage_const_7 ],x[_sage_const_8 ],x[_sage_const_13 ] = quarterround(x[_sage_const_2 ],x[_sage_const_7 ],x[_sage_const_8 ],x[_sage_const_13 ])
        x[_sage_const_3 ],x[_sage_const_4 ],x[_sage_const_9 ],x[_sage_const_14 ] = quarterround(x[_sage_const_3 ],x[_sage_const_4 ],x[_sage_const_9 ],x[_sage_const_14 ])
      for i in range(_sage_const_16 ):
        z = x[i]+y[i]
        z &= _sage_const_0xffffffff 
        h += [z&_sage_const_255 ]; z >>= _sage_const_8 
        h += [z&_sage_const_255 ]; z >>= _sage_const_8 
        h += [z&_sage_const_255 ]; z >>= _sage_const_8 
        h += [z&_sage_const_255 ]; z >>= _sage_const_8 

    randombytes_key = h[:_sage_const_32 ]
    randombytes_buf = h[_sage_const_32 :]
    randombytes_pos = _sage_const_0 
  c = randombytes_buf[randombytes_pos]
  randombytes_buf[randombytes_pos] = None
  randombytes_pos += _sage_const_1 
  return c

def randombytes(r):
  return bytes(bytearray([randomuint8() for j in range(r)]))

def L32(x,c):
  x &= _sage_const_0xffffffff 
  result = (x << c) | (x >> (_sage_const_32  - c))
  result &= _sage_const_0xffffffff 
  return result

def ld32(x):
  assert len(x) == _sage_const_4 
  u = x[_sage_const_3 ]
  u = (u<<_sage_const_8 )|x[_sage_const_2 ]
  u = (u<<_sage_const_8 )|x[_sage_const_1 ]
  return (u<<_sage_const_8 )|x[_sage_const_0 ]

def st32(x):
  result = []
  for i in range(_sage_const_4 ):
    result += [_sage_const_255 &x]
    x >>= _sage_const_8 
  return result

def core(block,k):
  assert len(block) == _sage_const_16 

  x = [None]*_sage_const_16 

  sigma = b'expand 32-byte k'
  sigma = list(bytearray(sigma))

  for i in range(_sage_const_4 ):
    x[_sage_const_5 *i] = ld32(sigma[_sage_const_4 *i:_sage_const_4 *i+_sage_const_4 ])
    x[_sage_const_1 +i] = ld32(k[_sage_const_4 *i:_sage_const_4 *i+_sage_const_4 ])
    x[_sage_const_6 +i] = ld32(block[_sage_const_4 *i:_sage_const_4 *i+_sage_const_4 ])
    x[_sage_const_11 +i] = ld32(k[_sage_const_4 *i+_sage_const_16 :_sage_const_4 *i+_sage_const_20 ])

  y = copy(x)

  for i in range(_sage_const_20 ):
    w = [None]*_sage_const_16 
    for j in range(_sage_const_4 ):
      t = [None]*_sage_const_4 
      for m in range(_sage_const_4 ):
        t[m] = ZZ(x[(_sage_const_5 *j+_sage_const_4 *m)%_sage_const_16 ])
      t[_sage_const_1 ] = t[_sage_const_1 ].__xor__(L32(t[_sage_const_0 ]+t[_sage_const_3 ], _sage_const_7 ));
      t[_sage_const_2 ] = t[_sage_const_2 ].__xor__(L32(t[_sage_const_1 ]+t[_sage_const_0 ], _sage_const_9 ));
      t[_sage_const_3 ] = t[_sage_const_3 ].__xor__(L32(t[_sage_const_2 ]+t[_sage_const_1 ],_sage_const_13 ));
      t[_sage_const_0 ] = t[_sage_const_0 ].__xor__(L32(t[_sage_const_3 ]+t[_sage_const_2 ],_sage_const_18 ));
      for m in range(_sage_const_4 ):
        w[_sage_const_4 *j+((j+m)%_sage_const_4 )] = t[m]
    for m in range(_sage_const_16 ):
      x[m] = w[m]

  result = []

  for i in range(_sage_const_16 ):
    z = _sage_const_0xffffffff  & (x[i]+y[i])
    result += st32(z)

  return result

def checksum(x):
  global checksum_state

  if type(x) == type(b'123'):
    x = list(bytearray(x))

  info = 'checksum %s' % ''.join('%02x'%xi for xi in x)

  while len(x) >= _sage_const_16 :
    checksum_state = core(x[:_sage_const_16 ],checksum_state)
    x = x[_sage_const_16 :]

  info += ' %s' % ''.join('%02x'%ci for ci in checksum_state)

  block = copy(x) + [_sage_const_1 ] + [_sage_const_0 ]*(_sage_const_15 -len(x))
  checksum_state[_sage_const_0 ] = checksum_state[_sage_const_0 ].__xor__(_sage_const_1 )
  checksum_state = core(block,checksum_state)

  info += ' %s' % ''.join('%02x'%ci for ci in checksum_state)
  # print(info)
  
def salsa20(outlen,n,k):
  assert outlen >= _sage_const_0 
  assert len(n) == _sage_const_8 
  assert len(k) == _sage_const_32 

  result = []

  if outlen == _sage_const_0 : return result

  z = n + [_sage_const_0 ]*_sage_const_8 

  while outlen >= _sage_const_64 :
    result += core(z,k)
    outlen -= _sage_const_64 

    for i in range(_sage_const_8 ,_sage_const_16 ):
      z[i] = _sage_const_255 &(z[i]+_sage_const_1 )
      if z[i]: break

  if outlen > _sage_const_0 :
    result += core(z,k)[:outlen]

  return result

def testvector(outlen):
  k = b'generate inputs for test vectors'
  k = list(bytearray(k))
  result = salsa20(outlen,testvector_n,k)
  for i in range(_sage_const_8 ):
    testvector_n[i] = _sage_const_255 &(testvector_n[i]+_sage_const_1 )
    if testvector_n[i]: break
  return result

def myrandom():
  x = testvector(_sage_const_8 )
  return sum(x[i]<<(_sage_const_8 *i) for i in range(_sage_const_8 ))

systems = parameters.alltests
if len(sys.argv) > _sage_const_1 :
  systems = sys.argv[_sage_const_1 :]

for system in systems:
  randombytes_key = [_sage_const_0 ]*_sage_const_32 
  randombytes_buf = [_sage_const_0 ]*_sage_const_736 
  randombytes_pos = len(randombytes_buf)

  checksum_state = [_sage_const_0 ]*_sage_const_64 

  testvector_n = [_sage_const_0 ]*_sage_const_8 

  params = parameters.parameters(system,allowtestparams=True)

  result = system
  print(result)
  sys.stdout.flush()

  for loop in range(_sage_const_64 ):
    print(loop)
    sys.stdout.flush()

    pk,sk = keygen.keygen(randombytes,params)
    checksum(pk)
    checksum(sk)

    C,k = encap.encap(pk,randombytes,params)
    checksum(C)
    checksum(k)

    assert decap.decap(C,sk,params) == k
    checksum(k)
    
    for loop2 in range(_sage_const_3 ):
      Clen = len(C)
      C = list(bytearray(C))

      offset = _sage_const_1  + (myrandom() % _sage_const_255 )
      pos = myrandom() % Clen
      C[pos] = _sage_const_255 &(C[pos]+offset)

      C = bytes(bytearray(C))

      k2 = decap.decap(C,sk,params)

      if k2 == False:
        checksum(C)
      else:
        checksum(k2)

    if loop in [_sage_const_7 ,_sage_const_63 ]:
      checksumhex = ''
      for i in range(_sage_const_32 ):
        checksumhex += '%x' % (_sage_const_15 &(checksum_state[i]>>_sage_const_4 ))
        checksumhex += '%x' % (_sage_const_15 &checksum_state[i])

      result += ' ' + checksumhex
      print(result)
      sys.stdout.flush()

  print(result)
  sys.stdout.flush()
