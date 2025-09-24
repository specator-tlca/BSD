#!/usr/bin/env python3
# Purpose: toy Vandermonde R×R check for the renormalization block.
# Usage:   python3 src/04_renorm_matrix_demo.py <N>   # N used to list multiplicative primes
# Prints:  det(M), cond_2(M), list of multiplicative primes; arch row at x=0.
# Output:  data/renorm_matrix_*.npz with matrix and analysis

import sys, math
import numpy as np

# Import save utils
sys.path.append('src')
from save_utils import save_numpy_results

# Toy Vandermonde demo for R x R nonsingularity.
# Interpret the arch row as evaluation at x=0; multiplicative rows at x=log ell.

N = int(sys.argv[1]) if len(sys.argv) > 1 else 11
# list multiplicative primes dividing N
m_primes = []
q = N
p = 2
while p*p <= q:
    while q % p == 0:
        if p not in m_primes: m_primes.append(p)
        q //= p
    p += 1
if q > 1: m_primes.append(q)

R = 1 + len(m_primes)
xs = [0.0] + [math.log(float(l)) for l in m_primes]  # arch at x=0
M = np.zeros((R,R))
for i,x in enumerate(xs):
    for k in range(R):
        M[i,k] = (x**k)

cond = np.linalg.cond(M)
Det = np.linalg.det(M)
print(f"[04] R={R}, multiplicative primes={m_primes}")
print(f"     det(M)={Det:.6e},  cond_2(M)={cond:.3e}  (Vandermonde style)")

# Compute eigenvalues
eigenvals = np.linalg.eigvals(M)
print(f"     eigenvalues: {eigenvals}")

# Save results
metadata = {
    'N': N,
    'R': R,
    'multiplicative_primes': m_primes,
    'determinant': float(Det),
    'condition_number': float(cond),
    'description': 'Vandermonde-style renormalization matrix'
}

arrays = {
    'matrix': M,
    'eigenvalues': eigenvals,
    'x_values': np.array(xs)
}

filename = save_numpy_results('renorm_matrix', arrays, metadata)
print(f"[04] Saved results to {filename}")
