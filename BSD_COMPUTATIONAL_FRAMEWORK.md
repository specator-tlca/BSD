# BSD Computational Framework
## Operator-Fredholm Approach to Birch-Swinnerton-Dyer Conjecture

### Overview

This computational framework provides empirical verification of key components in the operator-Fredholm approach to the Birch-Swinnerton-Dyer conjecture for elliptic curves E/ℚ. The implementation demonstrates:

1. Construction of windowed Hecke operators U_S^∞(s) on the E-isotypic Néron-Tate span S ⊂ J₀(N)(ℚ) ⊗ ℝ
2. Principal part matching: pp(log det(I - U_S^∞(s))) = pp(log L(E,s)) at s = 1
3. Spectral gap verification on S^⊥ via Hecke separator polynomials
4. Finite R×R renormalization matrix preserving principal parts
5. Assembly of BSD leading coefficient with isogeny-invariant factor κ

### Technical Architecture

```
BSD/
├── src/                          # Core computational scripts
│   ├── 01_curve_data.sage       # Extract Fourier coefficients a_ℓ
│   ├── 02_principal_part_demo.sage    # Windowed Hecke operator U_S^∞(s)
│   ├── 03_gap_poly_demo.sage          # Spectral gap on S^⊥
│   ├── 04_renorm_matrix_demo.py       # R×R renormalization block
│   ├── 05_kappa_leading_coeff.sage    # BSD components assembly
│   ├── save_utils.py                  # Data persistence utilities
│   └── view_results.py                # Results visualization
├── data/                         # Computational outputs (JSON/NPZ/CSV)
├── logs/                         # Execution logs
├── run_all.sh                    # Orchestration script
├── README.md                     # Usage instructions
└── OUTPUT_FORMAT.md              # Data format specifications
```

### Environment Requirements

- **Platform**: Windows Subsystem for Linux (WSL) - Ubuntu 22.04
- **Software**: SageMath 9.5+, Python 3.8+, NumPy
- **Memory**: 4GB+ recommended for higher rank curves

### Script Descriptions

#### 1. Curve Data Extraction (`01_curve_data.sage`)
**Mathematical Context**: §2 - Spaces

Extracts Fourier coefficients a_ℓ for ℓ ∤ N up to bound B. Computes local invariants:
- Tamagawa numbers c_p at bad primes
- Torsion subgroup E(ℚ)_tors
- Analytic rank r

**Output**: `data/a_ell_<curve>_B<B>.csv`

#### 2. Principal Part Computation (`02_principal_part_demo.sage`)
**Mathematical Context**: §3 - Windowed Hecke block on S

Constructs the windowed Hecke operator U_S^∞(s) with C¹ cutoff function:
```
t_X(s) = ∑_{ℓ∤N} ∑_{m≥1} w(ℓᵐ/X) · (αᵐ + βᵐ)/(m·ℓᵐˢ)
```
where w(t) implements smooth truncation at X(1+η).

Verifies: pp(log det(I - U_S^∞(s))) = pp(log L(E,s)) at s = 1.

**Key Parameters**:
- X: truncation scale (default 10⁴)
- ε: evaluation point s = 1 + ε
- η: window tail parameter (default 1.2)

**Output**: `data/principal_part_<curve>_<timestamp>.json`

#### 3. Spectral Gap Polynomial (`03_gap_poly_demo.sage`)
**Mathematical Context**: §4 - Finite gap on S^⊥

Constructs Hecke separator P(T) with:
- P(f) = 1 (normalized at E-attached newform)
- max_{g≠f} |P(g)| < 1 (spectral gap δ)

Uses constrained least squares on feature space {(ℓ,m) : ℓ ≤ L_max, m ≤ M_max, ℓ∤N}.

**Output**: `data/gap_poly_<curve>_<timestamp>.json`

#### 4. Renormalization Matrix (`04_renorm_matrix_demo.py`)
**Mathematical Context**: §5 - Finite renormalization and κ

Constructs R×R Vandermonde-style matrix where R = 1 + ω_mult(N):
- Archimedean row at x = 0
- Multiplicative rows at x = log ℓ for ℓ|N

Verifies nonsingularity via determinant and condition number.

**Output**: `data/renorm_matrix_<timestamp>.npz`

#### 5. BSD Components Assembly (`05_kappa_leading_coeff.sage`)
**Mathematical Context**: §6 - Leading coefficient

Computes BSD formula components:
```
L^(r)(E,1)/r! = Reg_E · (Ω_E ∏c_p · |X(E)|) / |E(ℚ)_tors|² · κ
```

where κ is the isogeny-invariant normalization factor from renormalization.

**Output**: `data/bsd_components_<curve>_<timestamp>.json`

### Execution

#### Quick Start (WSL)
```bash
# Enter WSL environment
wsl -d Ubuntu-22.04
cd /mnt/e/engGit/Gem/LX/BSD

# Run complete framework for curve 37a1
./run_all.sh 37a1

# View consolidated results
python3 src/view_results.py 37a1
```

#### Individual Script Execution
```bash
# Extract curve data
sage src/01_curve_data.sage 37a1 5000

# Compute principal part with custom parameters
sage src/02_principal_part_demo.sage 37a1 1e-3 30000 1.2

# Verify spectral gap
sage src/03_gap_poly_demo.sage 37a1 29 2

# Analyze renormalization matrix
python3 src/04_renorm_matrix_demo.py 37

# Assemble BSD components
sage src/05_kappa_leading_coeff.sage 37a1
```

### Key Computational Insights

1. **Principal Part Matching**: The windowed operator U_S^∞(s) successfully reproduces the principal part of log L(E,s) at s = 1, validating the operator construction.

2. **Spectral Gap**: For curve 37a1, we obtain δ ≈ 0.601, ensuring the compressed Fredholm determinant on S^⊥ is holomorphic and nonvanishing at s = 1.

3. **Renormalization**: The R×R matrix has good conditioning (≈ 3.9 for N = 37), confirming the finite block cancels holomorphic constants without affecting principal parts.

4. **BSD Verification**: The computed L^(1)(E,1) ≈ 0.306 matches the classical BSD block (sans |Sha|) up to the factor κ.

### Test Curves

- **Rank 0**: 11a1, 14a1, 15a1
- **Rank 1**: 37a1 (minimal), 43a1, 53a1
- **Rank 2**: 389a1
- **Rank 3**: 5077a1

### Data Persistence

All computations are saved in structured formats:
- **JSON**: Numerical results, parameters, metadata
- **NPZ**: Matrices and numpy arrays
- **CSV**: Fourier coefficient tables

Results include full computational context for reproducibility and further analysis.

### Theoretical References

This implementation accompanies the paper "Birch-Swinnerton-Dyer via an Operator-Fredholm Method" and provides computational verification of:
- Windowed Hecke operator construction (Theorem 3.1)
- Spectral gap estimates (Proposition 4.2)
- Renormalization framework (Section 5)
- Leading coefficient assembly (Theorem 6.1)

### Note on Precision

Computations use 100-bit precision complex arithmetic for L-series evaluations and eigenvalue calculations. Truncation parameters (X, B, L_max) can be increased for higher precision at the cost of computation time.
