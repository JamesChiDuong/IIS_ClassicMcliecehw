def interpolator(n,k,a,r):
  r'''
  Return phi in the polynomial ring k[x]
  with deg phi < n
  and (phi(a[0]),...,phi(a[n-1])) = (r[0],...,r[n-1]).

  INPUT:

  "n" - a nonnegative integer

  "k" - a field

  "a" - a list of n distinct elements of k

  "r" - a list of n elements of k
  '''
  kpoly.<x> = k[]
  return kpoly.lagrange_polynomial(zip(a,r))

# ---- miscellaneous tests
# copied from https://eprint.iacr.org/2022/473 Figure A.1

def test_smallrandom():
  for q in range(100):
    q = ZZ(q)
    if not q.is_prime_power(): continue
    print('interp %d' % q)
    sys.stdout.flush()
    k = GF(q)
    for loop in range(100):
      n = randrange(q+1)
      a = list(k)
      shuffle(a)
      a = a[:n]
      r = [k.random_element() for j in range(n)]
      phi = interpolator(n,k,a,r)
      assert phi.degree() < n
      assert all(phi(aj) == rj for aj,rj in zip(a,r))
      kpoly = phi.parent()
      assert phi == kpoly.lagrange_polynomial(zip(a,r))

if __name__ == '__main__':
  test_smallrandom()
