#!/usr/bin/env python3
"""
Utility to load and display saved BSD computation results.
Usage: python3 src/view_results.py [curve_label]
"""

import json
import numpy as np
import os
import sys
from glob import glob
from datetime import datetime

def load_latest_json(pattern):
    """Load the most recent JSON file matching pattern."""
    files = glob(pattern)
    if not files:
        return None
    # Sort by timestamp in filename
    files.sort(key=lambda x: x.split('_')[-1].replace('.json', ''))
    with open(files[-1], 'r') as f:
        return json.load(f), files[-1]

def load_latest_npz(pattern):
    """Load the most recent NPZ file matching pattern."""
    files = glob(pattern)
    if not files:
        return None
    files.sort(key=lambda x: x.split('_')[-1].replace('.npz', ''))
    return np.load(files[-1]), files[-1]

def print_section(title):
    """Print a section header."""
    print(f"\n{'='*60}")
    print(f"{title}")
    print(f"{'='*60}")

def get_value(val):
    """Extract numeric value from either float or dict format."""
    if isinstance(val, dict) and 'real' in val:
        return val['real']
    return val

def main(curve='37a1'):
    print(f"BSD Results Viewer - Curve: {curve}")
    
    # 1. Principal Part Results
    result = load_latest_json(f'data/principal_part_{curve}_*.json')
    if result:
        data, fname = result
        print_section(f"Principal Part Results ({fname})")
        print(f"Parameters:")
        print(f"  X = {data['parameters']['X']}")
        print(f"  eps = {data['parameters']['eps']}")
        print(f"  B = {data['parameters']['B']}")
        print(f"  eta = {data['parameters']['eta']}")
        print(f"\nResults:")
        t_X = data['results']['t_X_value']
        print(f"  t_X(1+eps) = {t_X['real']:.6f} + {t_X['imag']:.6f}i")
        log_L = data['results']['log_L']
        print(f"  log L(E,1+eps) = {log_L['real']:.6f}")
        log_det = data['results']['log_det_fin']
        print(f"  log det_fin = {log_det['real']:.6f}")
        print(f"\nSlope checks:")
        for check in data['slope_checks']:
            print(f"  h={check['h']:.4f}: slope = {check['slope']:.4f}")
    
    # 2. Gap Polynomial Results
    result = load_latest_json(f'data/gap_poly_{curve}_*.json')
    if result:
        data, fname = result
        print_section(f"Gap Polynomial Results ({fname})")
        print(f"Parameters:")
        print(f"  Lmax = {data['parameters']['Lmax']}")
        print(f"  Mmax = {data['parameters']['Mmax']}")
        print(f"  Number of features = {len(data['features'])}")
        print(f"  Number of newforms = {data['curve_data']['num_newforms']}")
        print(f"\nSpectral gap: δ = {get_value(data['spectral_gap']):.6f}")
        print(f"P(f) = {get_value(data['P_values']['f']):.6f}")
        for key, val in data['P_values'].items():
            if key != 'f':
                print(f"|P({key})| = {get_value(val):.6f}")
    
    # 3. BSD Components
    result = load_latest_json(f'data/bsd_components_{curve}_*.json')
    if result:
        data, fname = result
        print_section(f"BSD Components ({fname})")
        comp = data['bsd_components']
        print(f"Curve data:")
        print(f"  Rank = {comp['rank']}")
        print(f"  Torsion = Z/{comp['torsion_order']}Z")
        print(f"\nBSD components:")
        if comp['regulator'] is not None:
            print(f"  Regulator = {comp['regulator']:.6f}")
        else:
            print(f"  Regulator = (not computed)")
        print(f"  Real period = {comp['real_period']:.6f}")
        print(f"  Product of Tamagawa numbers = {comp['tamagawa_product']}")
        if comp['generators']:
            print(f"\nGenerators:")
            for g in comp['generators']:
                print(f"  {g['point']} (height = {g['height']:.6f})")
        if data['L_series']['L_r_over_r_factorial'] is not None:
            print(f"\nL-series value:")
            print(f"  L^({comp['rank']})(E,1)/{comp['rank']}! = {data['L_series']['L_r_over_r_factorial']:.6f}")
        if data['bsd_block']['value'] is not None:
            print(f"\nBSD block (sans |Sha|, sans κ) = {data['bsd_block']['value']:.6f}")
    
    # 4. Renormalization Matrix
    result = load_latest_npz('data/renorm_matrix_*.npz')
    if result:
        npz_data, fname = result
        metadata = json.loads(str(npz_data['metadata'][0]))
        print_section(f"Renormalization Matrix ({fname})")
        print(f"N = {metadata['N']}")
        print(f"Dimension R = {metadata['R']}")
        print(f"Multiplicative primes: {metadata['multiplicative_primes']}")
        print(f"Determinant = {metadata['determinant']:.6e}")
        print(f"Condition number = {metadata['condition_number']:.3e}")
        print(f"\nEigenvalues:")
        for i, ev in enumerate(npz_data['eigenvalues']):
            print(f"  λ_{i+1} = {ev:.6f}")

if __name__ == "__main__":
    curve = sys.argv[1] if len(sys.argv) > 1 else '37a1'
    main(curve)
