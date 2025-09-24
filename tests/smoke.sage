#!/usr/bin/env sage
from sage.all import *

for curve in ['11a1','37a1']:
    E = EllipticCurve(curve)
    print(f"[test] {curve} : rank={E.rank()}, conductor={E.conductor()}, torsion={E.torsion_subgroup().order()}")