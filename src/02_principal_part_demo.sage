#!/usr/bin/env sage
# Purpose: principal-part match on S via t_X(s); compare with log L(E,s) at s=1+eps.
# Usage:   sage src/02_principal_part_demo.sage <curve> [eps=1e-3] [B=30000] [eta=1.2]
# Prints:  t_X(1+eps), r*log(1 - t_X), log L(E,1+eps), slope checks vs rank.
# Output:  data/principal_part_*.json with all computed values
# Tip:     increase B or X inside the code to reduce variance; eta controls C^1 window tail.

import sys
from sage.all import *

# Import save utils
sys.path.append('src')
from save_utils import save_json_results

curve = sys.argv[1] if len(sys.argv) > 1 else '37a1'
eps = RealNumber(sys.argv[2]) if len(sys.argv) > 2 else RealNumber('1e-3')
B = Integer(sys.argv[3]) if len(sys.argv) > 3 else 30000
eta = RealNumber(sys.argv[4]) if len(sys.argv) > 4 else RealNumber('1.2')

E = EllipticCurve(curve)
N = E.conductor()
C = ComplexField(100)

def frob_eigs(a, l):
    D = C(a*a - 4*l)
    sD = D.sqrt()
    return ( (a + sD)/2, (a - sD)/2 )

def window(t, eta=1.2):
    if t <= 1: return 1
    if t >= 1+eta: return 0
    r = (t-1)/eta
    return 1 - (3*r**2 - 2*r**3)

def t_X(E, X, s, B=30000, eta=1.2):
    N = E.conductor()
    S = C(0)
    # Store individual terms for analysis
    terms = []
    for l in prime_range(min(B, ceil((1+eta)*X))):
        if N % l == 0:
            continue
        a = E.ap(l)
        alpha, beta = frob_eigs(a, l)
        m = 1
        while l**m <= (1+eta)*X:
            wt = window(l**m / X, eta)
            if wt != 0:
                term_val = C(wt) * (alpha**m + beta**m) / (m * (l**(m*s)))
                S += term_val
                terms.append({
                    'l': int(l),
                    'm': int(m),
                    'window_weight': float(wt),
                    'term_value': {'real': float(term_val.real()), 'imag': float(term_val.imag())}
                })
            m += 1
    return S, terms

X = RealNumber(1e4)
s1 = RealNumber(1) + eps
r = E.rank()

# log det_fin(I - A_X(s)) on S where A_X(s) = t_X(s) * I_S
val_t, t_X_terms = t_X(E, X, s1, B=B, eta=eta)
logdet_fin = r * log(1 - val_t)

# Compare with log L(E,s) via Sage's L-series (numeric)
L = E.lseries().dokchitser()
Lval = C(L(s1))
logL = log(Lval)

print(f"[02] Curve {curve}, r={r}, X={X}, eps={eps}")
print(f"     t_X(1+eps) = {val_t}")
print(f"     log det_fin(I - A_X(1+eps)) = {logdet_fin}")
print(f"     log L(E,1+eps) = {logL}")

# Slope checks for rank verification
slope_checks = []
for h in [eps, eps/2, eps/4]:
    s = 1 + h
    Lh = C(L(s))
    slope = (log(abs(Lh))/log(h)).real()
    print(f"     slope check h={h} : log|L(1+h)|/log(h) ≈ {slope}")
    slope_checks.append({
        'h': float(h),
        'L_value': {'real': float(Lh.real()), 'imag': float(Lh.imag())},
        'slope': float(slope)
    })

# Save all results to JSON
results = {
    'curve': curve,
    'parameters': {
        'X': float(X),
        'eps': float(eps),
        'B': int(B),
        'eta': float(eta)
    },
    'curve_data': {
        'conductor': int(N),
        'rank': int(r)
    },
    'results': {
        't_X_value': {'real': float(val_t.real()), 'imag': float(val_t.imag())},
        'log_det_fin': {'real': float(logdet_fin.real()), 'imag': float(logdet_fin.imag())},
        'log_L': {'real': float(logL.real()), 'imag': float(logL.imag())},
        'L_value': {'real': float(Lval.real()), 'imag': float(Lval.imag())}
    },
    'slope_checks': slope_checks,
    't_X_terms': t_X_terms[:100]  # Save first 100 terms to avoid huge files
}

filename = save_json_results('principal_part', results, curve)
print(f"[02] Saved results to {filename}")
