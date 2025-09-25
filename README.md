# BSD via Operator-Fredholm Framework - Computational Tools

## Overview
Computational verification of key components in the operator-Fredholm approach to BSD conjecture.
This repo is demo pack for "Birch–Swinnerton–Dyer via an Operator–Fredholm Method" research by miruka 
Main document loccated at https://zenodo.org/records/17201882

## Installation

### Prerequisites
- Windows with WSL (Windows Subsystem for Linux)
- SageMath 9.5 or later installed in WSL
- Python 3.8+ in WSL
- NumPy

### Setup for WSL

```bash
# Open WSL (from PowerShell or CMD):
wsl -d Ubuntu-22.04  # or your WSL distribution name

# Navigate to project directory
cd /mnt/'your dir'  # adjust path as needed

# Make scripts executable
chmod +x run_all.sh

# Optional: Create Python virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt
```

## Usage

### Quick Start - Run All Demos

#### From WSL
```bash
# Open WSL and navigate to project
wsl -d Ubuntu-22.04
cd /mnt/'your dir'

# Run all demos for curve 37a1 (rank 1)
./run_all.sh 37a1

# Run for curve 11a1 (rank 0)
./run_all.sh 11a1

# Run with custom log directory
./run_all.sh 37a1 my_logs
```

#### From PowerShell (one-liner)
```powershell
# Run directly from Windows PowerShell
wsl -d Ubuntu-22.04 -e bash -c "cd /mnt/'your dir'
 && ./run_all.sh 37a1"
```

### Individual Script Usage (in WSL)

#### 1. Extract curve data and Fourier coefficients
```bash
sage src/01_curve_data.sage <curve_label> [B=5000]

# Examples:
sage src/01_curve_data.sage 37a1        # Default B=5000
sage src/01_curve_data.sage 11a1 10000  # Compute a_p for p < 10000
```
**Output:** `data/a_ell_<curve>_B<B>.csv`

#### 2. Principal part computation
```bash
sage src/02_principal_part_demo.sage <curve> [eps=1e-3] [B=30000] [eta=1.2]

# Examples:
sage src/02_principal_part_demo.sage 37a1                    # All defaults
sage src/02_principal_part_demo.sage 37a1 1e-4              # Smaller eps
sage src/02_principal_part_demo.sage 37a1 1e-3 50000 1.5    # Higher precision
```
**Output:** `data/principal_part_<curve>_<timestamp>.json`

#### 3. Gap polynomial computation
```bash
sage src/03_gap_poly_demo.sage <curve> [Lmax=29] [Mmax=2]

# Examples:
sage src/03_gap_poly_demo.sage 37a1          # Default parameters
sage src/03_gap_poly_demo.sage 37a1 37 3     # More features
```
**Output:** `data/gap_poly_<curve>_<timestamp>.json`

#### 4. Renormalization matrix
```bash
python3 src/04_renorm_matrix_demo.py <conductor>

# Examples:
python3 src/04_renorm_matrix_demo.py 37    # For curve 37a1
python3 src/04_renorm_matrix_demo.py 11    # For curve 11a1
```
**Output:** `data/renorm_matrix_<timestamp>.npz`

#### 5. BSD components and kappa
```bash
sage src/05_kappa_leading_coeff.sage <curve>

# Examples:
sage src/05_kappa_leading_coeff.sage 37a1
sage src/05_kappa_leading_coeff.sage 11a1
```
**Output:** `data/bsd_components_<curve>_<timestamp>.json`

### View Results
```bash
# In WSL
python3 src/view_results.py 37a1

# View results for default curve (37a1)
python3 src/view_results.py

# Save summary to file
python3 src/view_results.py 37a1 > results_summary.txt
```

The `view_results.py` script:
- Finds the latest saved data files for a curve
- Displays all computed values in a readable format
- Shows results from all 5 scripts in one place
- Does NOT save anything - only reads and displays

## Output Files

The project creates two types of output:

### 1. Data Files (in `data/` directory)
Structured data files with all numerical results:
- **JSON files**: Human-readable, contains all computed values, parameters, and results
- **NPZ files**: NumPy format for matrices and arrays
- **CSV files**: Simple tabular data (Fourier coefficients)

### 2. Console Logs (in `logs/` directory)
Text files capturing console output from each script run:
- Shows what each script prints during execution
- Useful for debugging and documentation
- Created by `run_all.sh` using `tee` command

Example:
- `data/principal_part_37a1_20250924_201201.json` - Actual computation results
- `logs/02_principal_part_37a1.txt` - Console output from running the script

See `OUTPUT_FORMAT.md` for detailed description of data file formats.

## Example Curves

### Rank 0 curves (good for testing)
- **11a1**: conductor 11, rank 0, L(E,1) ≠ 0
- **14a1**: conductor 14, rank 0
- **15a1**: conductor 15, rank 0

### Rank 1 curves
- **37a1**: conductor 37, rank 1, minimal example
- **43a1**: conductor 43, rank 1
- **53a1**: conductor 53, rank 1

### Higher rank curves (slower computation)
- **389a1**: conductor 389, rank 2
- **5077a1**: conductor 5077, rank 3

## Notes
- Demos are **illustrative**; they validate the *shape* of the method
- Computation time increases with conductor and rank
- For production use, increase parameters B, X, Lmax for better precision
- All timestamps are in local time

## What each script computes

### 01_curve_data.sage
- Fourier coefficients a_p for p < B not dividing N
- Tamagawa numbers at bad primes
- Torsion subgroup structure
- Rank (via Sage's built-in methods)

### 02_principal_part_demo.sage  
- Windowed Hecke operator t_X(s) with C^1 cutoff
- Principal part matching: log det_fin(I - A_X(s)) vs log L(E,s)
- Slope verification for rank
- Individual term contributions

### 03_gap_poly_demo.sage
- Hecke separator polynomial P(T) with P(f)=1
- Feature vectors for all newforms at level N
- Spectral gap δ = 1 - max|P(g)| for g≠f
- Polynomial coefficients via constrained least squares

### 04_renorm_matrix_demo.py
- R×R Vandermonde-style matrix (R = 1 + #multiplicative primes)
- Matrix conditioning and determinant
- Eigenvalue computation
- Handles archimedean and multiplicative normalization

### 05_kappa_leading_coeff.sage
- Complete BSD formula components
- L^(r)(E,1)/r! via Dokchitser's algorithm
- Regulator, periods, Tamagawa numbers
- Generator points and heights (when available)

## Troubleshooting

### WSL Issues

#### WSL not installed
Install WSL from PowerShell (as Administrator):
```powershell
wsl --install -d Ubuntu-22.04
```

#### SageMath not found in WSL
Install SageMath in WSL:
```bash
sudo apt update
sudo apt install sagemath
```

#### Permission denied when running scripts
Make scripts executable:
```bash
chmod +x run_all.sh
```

### Import errors in Python scripts
Activate the virtual environment in WSL:
```bash
source .venv/bin/activate
```

### Memory issues
For large conductors, reduce parameters:
- Lower B in script 02
- Lower Lmax in script 03
