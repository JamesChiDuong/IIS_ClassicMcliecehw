from . import fieldordering
from . import irreducible
from . import matgen
from . import parameters

def seededkeygen(delta,params):
  r'''
  Return the output of the Classic McEliece SeededKeyGen function
  on input delta for the specified parameters.

  INPUT:

  "delta" - a list of l bits

  "params" - a Classic McEliece parameter set
  '''

  assert isinstance(params,parameters.parameters)
  l = params.l
  n = params.n
  q = params.q
  t = params.t
  mu = params.mu
  G = params.G
  sigma1 = params.sigma1
  sigma2 = params.sigma2

  delta = list(delta)
  assert len(delta) == l

  while True:
    # "Compute E = G(delta), a string of n + sigma_2 q + sigma_1 t + l bits."
    E = G(delta)
    assert len(E) == n+sigma2*q+sigma1*t+l

    # "Define delta' as the last l bits of E."
    deltaprime = E[-l:]

    # "Define s as the first n bits of E."
    s = E[:n]

    # "Compute alpha_0,...,alpha_{q-1} from the next sigma_2 q bits of E
    #  by the FieldOrdering algorithm.
    #  If this fails, set delta <- delta' and restart the algorithm."
    alpha = fieldordering.fieldordering(E[n:n+sigma2*q],params)
    if alpha == False:
      delta = deltaprime
      continue

    # "Compute g from the next sigma_1 t bits of E
    #  by the Irreducible algorithm.
    #  If this fails, set delta <- delta' and restart the algorithm."
    g = irreducible.irreducible(E[n+sigma2*q:n+sigma2*q+sigma1*t],params)
    if g == False:
      delta = deltaprime
      continue

    # "Define Gamma = (g,alpha_0,alpha_1,...,alpha_{n-1})."
    Gamma = tuple([g]+alpha[:n])

    # "Compute (T,c_{mt-mu},...,c_{mt-1},Gammaprime) <- MatGen(Gamma).
    #  If this fails, set delta <- delta' and restart the algorithm."
    result = matgen.matgen(Gamma,params)
    if result == False:
      delta = deltaprime
      continue
    T = result[0]
    Gammaprime = result[-1]
    c = result[1:-1]
    assert len(c) == mu

    # "Write Gamma' as (g,alpha'_0,alpha'_1,...,alpha'_{n-1})."
    assert Gammaprime[0] == g
    alphaprime = list(Gammaprime[1:])
    assert len(alphaprime) == n

    # "Output T as public key
    #  and (delta,c,g,alpha,s) as private key,
    #  where c = (c_{mt-mu,...,c_{mt-1})
    #  and alpha = (alpha'_0,...,alpha'_{n-1},alpha_n,...,alpha_{q-1})."
    alphaprime += alpha[n:q]
    assert len(alphaprime) == q
    return T,(delta,c,g,alphaprime,s)

def keygen_abstract(randombits,params):
  r'''
  Return the output of the abstract Classic McEliece KeyGen function
  using the specified source of random bits
  for the specified parameters.

  "Abstract" means that this function does not include encodings
  of the inputs and outputs as byte strings.
  See keygen() for the full function including encodings.

  INPUT:

  "randombits" - a function that, on input r, returns a list of r bits

  "params" - a Classic McEliece parameter set
  '''

  assert isinstance(params,parameters.parameters)
  l = params.l
  delta = randombits(l)
  return seededkeygen(delta,params)

  n = params.n
  t = params.t
  k = params.k

  e = vector(GF(2),list(e))
  assert len(e) == n
  assert sum(1 for ej in e if ej != 0) == t

  assert T.nrows() == m*t
  assert T.ncols() == k
  assert T.base_ring() == GF(2)

  # "Define H = (I_{mt} | T)."
  H = identity_matrix(GF(2),m*t).augment(T)

  # "Compute and return C = He in F_2^{mt}."
  C = H*e
  assert len(C) == m*t
  return C

from . import byterepr

def keygen(randombytes,params):
  r'''
  Return the output of the Classic McEliece KeyGen function
  using the specified source of random bytes
  for the specified parameters.

  This is the full function, including encodings
  of the inputs and outputs as byte strings.

  INPUT:

  "randombytes" - a function that, on input r, returns an r-byte string

  "params" - a Classic McEliece parameter set
  '''
  assert isinstance(params,parameters.parameters)
  randombits = byterepr.randombits_from_randombytes(randombytes)
  T,priv = keygen_abstract(randombits,params)
  return byterepr.from_publickey(T,params),byterepr.from_privatekey(priv,params)

# ----- miscellaneous tests

def test1():
  import os

  def randombits(r):
    return [randrange(2) for j in range(r)]

  def randombytes(r):
    return os.urandom(r)

  for system in parameters.alltests:
    P = parameters.parameters(system,allowtestparams=True)
    m = P.m
    q = P.q
    Fq = P.Fq
    t = P.t
    n = P.n
    k = P.k
    l = P.l
    mu = P.mu
    nu = P.nu

    print('keygen_abstract %s' % system)
    sys.stdout.flush()

    T,(delta,c,g,alphaprime,s) = keygen_abstract(randombits,P)

    assert T.nrows() == m*t
    assert T.ncols() == k
    assert len(delta) == l
    assert len(c) == mu
    assert list(c) == sorted(set(c))
    assert all(cj >= m*t-mu for cj in c)
    assert all(cj < m*t-mu+nu for cj in c)
    assert g.is_monic()
    assert g.is_irreducible()
    assert g.degree() == t
    assert g.base_ring() == Fq
    assert len(alphaprime) == q
    assert len(set(alphaprime)) == q
    assert all(alphaj in Fq for alphaj in alphaprime)
    assert len(s) == n

    print('keygen %s' % system)
    sys.stdout.flush()

    T,priv = keygen(randombytes,P)

    assert len(T) == m*t*ceil(k/8)
    assert len(priv) == ceil(l/8) + (8 if (mu,nu) == (0,0) else ceil(nu/8)) + t*ceil(m/8) + ceil((2*m-1)*2^(m-4)) + ceil(n/8)

if __name__ == '__main__':
  test1()