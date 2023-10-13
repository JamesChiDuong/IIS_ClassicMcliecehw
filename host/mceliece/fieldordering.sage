from . import parameters

def fieldordering(b,params):
  r'''
  Return the output of the Classic McEliece FieldOrdering function
  on input b for the specified parameters.

  INPUT:

  "b" - a list of sigma2*t bits

  "params" - a Classic McEliece parameter set
  '''

  assert isinstance(params,parameters.parameters)
  m = params.m
  q = params.q
  Fq = params.Fq
  z = Fq.gen()
  sigma2 = params.sigma2

  # "takes a string of sigma_2 input bits"
  b = list(b)
  assert len(b) == sigma2*q

  # "Take the first sigma_2 input bits b_0,b_1,...,b_{sigma_2-1}
  #  as a sigma_2-bit integer a_0 = b_0 + 2b_1 + ... + 2^{sigma_2-1} b_{sigma_2-1},
  #  take the next sigma_2 bits as a sigma_2-bit integer a_1,
  #  and so on through a_{q-1}."
  a = [sum(b[j*sigma2+i]<<i for i in range(sigma2)) for j in range(q)]

  # "If a_0,a_1,...a_{q-1} are not distinct, return False."
  if len(set(a)) < q: return False

  # "Sort the pairs (a_i,i) in lexicographic order
  #  to obtain pairs (a_{pi(i)},pi(i))
  #  where pi is a permutation of {0,1,...,q-1}."
  api = sorted((a[i],i) for i in range(q))
  # now api[i] is (a[pi[i]],pi[i])

  # "Define alpha_i = sum_{j=0}^{m-1} pi(i)_j*z^{m-1-j}
  #  where pi(i)_j denotes the jth least significant bit of pi(i)."
  alpha = [sum((1&(api[i][1]>>j))*z^(m-1-j) for j in range(m))
           for i in range(q)]

  # "Output (alpha_0,alpha_1,...,alpha_{q-1})."
  return alpha

# ----- miscellaneous tests

def test1():
  for system in parameters.alltests:
    P = parameters.parameters(system,allowtestparams=True)
    m = P.m
    q = P.q
    Fq = P.Fq
    sigma2 = P.sigma2

    numsuccess = 0
    for loop in range(10):
      b = [randrange(2) for j in range(sigma2*q)]
      alpha = fieldordering(b,P)
      if alpha != False:
        numsuccess += 1
        assert len(alpha) == q
        assert len(set(alpha)) == q
        assert sorted(alpha) == sorted(Fq)

    print('fieldordering %s numsuccess %d' % (system,numsuccess))
    sys.stdout.flush()

if __name__ == '__main__':
  test1()
