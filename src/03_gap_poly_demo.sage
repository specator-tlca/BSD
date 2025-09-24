#!/usr/bin/env sage
# Purpose: finite Hecke separator P(T) with P(f)=1 and max_{g!=f}|P(g)|<1 (gap on S^⊥).
# Usage:   sage src/03_gap_poly_demo.sage <curve> [Lmax=29] [Mmax=2]
# Prints:  number of features, max|P(g)| for g!=f, and delta = 1 - max|P(g)|.
# Output:  data/gap_poly_*.json with polynomial coefficients and feature vectors
# Note:    features = {(ell,m): ell<=Lmax, m<=Mmax, ell∤N}; no cherry-picking.

import sys
from sage.all import *

# Import save utils
sys.path.append('src')
from save_utils import save_json_results

curve = sys.argv[1] if len(sys.argv) > 1 else '37a1'
Lmax = Integer(sys.argv[2]) if len(sys.argv) > 2 else 29
Mmax = Integer(sys.argv[3]) if len(sys.argv) > 3 else 2

E = EllipticCurve(curve)
N = E.conductor()
C = ComplexField(100)

# Newforms at level N (weight 2)
S = CuspForms(N, 2)
NFs = S.newforms('a')

# Identify the form f attached to E by matching first few a_l
def match_form_to_E(NFs, E, B=200):
    target = {p: E.ap(p) for p in prime_range(B) if N % p != 0}
    for f in NFs:
        ok = True
        for p,a in target.items():
            try:
                f_val = Integer(f[p])
                if f_val != a:
                    ok = False; break
            except Exception:
                ok = False; break
        if ok:
            return f
    return None

f = match_form_to_E(NFs, E)
if f is None:
    print("[03] Could not identify the newform for E; aborting.")
    sys.exit(0)

primes = [p for p in prime_range(Lmax) if N % p != 0]
features = []  # columns indexed by (l,m)
for l in primes:
    for m in range(1, Mmax+1):
        features.append((l,m))

# feature vector for a form g: phi_{l,m}(g) = alpha^m + beta^m
C = ComplexField(100)

def frob_eigs(a, l):
    D = C(a*a - 4*l)
    sD = D.sqrt()
    return ( (a + sD)/2, (a - sD)/2 )

def feat_vec(g):
    vals = []
    for (l,m) in features:
        a = g[l]
        alpha, beta = frob_eigs(a, l)
        vals.append((alpha**m + beta**m).real())  # use real part
    return vector(RDF, [RR(v) for v in vals])

vf = feat_vec(f)
Gs = [g for g in NFs if g != f]
print(f"Found {len(Gs)} other forms")

# Store feature vectors for all forms
all_feature_vecs = {}
all_feature_vecs['f'] = [float(x) for x in vf]
for i, g in enumerate(Gs):
    all_feature_vecs[f'g_{i}'] = [float(x) for x in feat_vec(g)]

# Store P(g) values
P_values = {}

if len(Gs) == 0:
    print("[03] Only one newform at this level; trivial separator P(T)=1")
    # Save results
    results = {
        'curve': curve,
        'parameters': {
            'Lmax': int(Lmax),
            'Mmax': int(Mmax)
        },
        'curve_data': {
            'conductor': int(N),
            'num_newforms': 1
        },
        'features': [(int(l), int(m)) for l, m in features],
        'polynomial_coefficients': [float(1/sum(vf**2)) for _ in vf],  # trivial case
        'feature_vectors': all_feature_vecs,
        'P_values': {'f': 1.0},
        'spectral_gap': 1.0
    }
    filename = save_json_results('gap_poly', results, curve)
    print(f"[03] Saved results to {filename}")
    sys.exit(0)

M = matrix(RDF, [feat_vec(g) for g in Gs])  # rows = other forms

# If only one other form, use simpler approach
if len(Gs) == 1:
    g = Gs[0]
    vg = feat_vec(g)
    # Find c such that vf*c = 1 and minimize |vg*c|
    c = vf / (vf * vf)
    val_f = 1.0
    val_g = abs(vg * c)
    delta = 1 - val_g
    
    P_values['f'] = val_f
    P_values['g_0'] = float(val_g)
    poly_coeffs = [float(x) for x in c]
    
    print(f"[03] Hecke separator with {len(features)} features, normalized P(f)=1")
    print(f"     |P(g)| = {val_g:.6f}  =>  spectral gap delta ≈ {delta:.6f}")

else:
    # Constrained least squares: minimize ||M c||^2 s.t. vf * c = 1
    A = M
    B = matrix(RDF, 1, M.ncols(), vf)
    Z = block_matrix([[A.T*A, B.T],[B, matrix(RDF,1,1,[0])]])
    rhs = vector(RDF, [0]*M.ncols() + [1])
    sol = Z.solve_right(rhs)
    c = sol[:M.ncols()]
    
    vals_all = [ (feat_vec(g) * c) for g in NFs ]
    val_f = (vf * c)
    vals_others = [abs(v) for g,v in zip(NFs, vals_all) if g != f]
    
    P_values['f'] = float(val_f)
    for i, (g, v) in enumerate([(g, v) for g, v in zip(NFs, vals_all) if g != f]):
        P_values[f'g_{i}'] = float(abs(v))
    
    poly_coeffs = [float(x) for x in c]
    
    delta = 1 - max(vals_others) if len(vals_others)>0 else 1
    print(f"[03] Hecke separator with {len(features)} features, normalized P(f)=1")
    print(f"     max_{g!=f} |P(g)| = {1-delta:.6f}  =>  spectral gap delta ≈ {delta:.6f}")

# Save all results
results = {
    'curve': curve,
    'parameters': {
        'Lmax': int(Lmax),
        'Mmax': int(Mmax)
    },
    'curve_data': {
        'conductor': int(N),
        'num_newforms': len(NFs)
    },
    'features': [(int(l), int(m)) for l, m in features],
    'polynomial_coefficients': poly_coeffs,
    'feature_vectors': all_feature_vecs,
    'P_values': P_values,
    'spectral_gap': float(delta)
}

filename = save_json_results('gap_poly', results, curve)
print(f"[03] Saved results to {filename}")
