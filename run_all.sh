#!/bin/bash
# run_all.sh - Run all BSD demos for a given curve
# Usage: ./run_all.sh [curve] [log_dir]
# Default: curve=37a1, log_dir=logs

CURVE=${1:-"37a1"}
OUTPUT_DIR=${2:-"logs"}

echo "================================================================"
echo "Running BSD Operator-Fredholm demos for curve: $CURVE"
echo "Output will be saved to: data/ (computed results) and $OUTPUT_DIR/ (console logs)"
echo "================================================================"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clean up .sage.py files to avoid conflicts
echo "Cleaning up .sage.py files..."
rm -f src/*.sage.py

# Function to run command and save output
run_and_save() {
    local cmd=$1
    local output_file=$2
    echo ""
    echo "Running: $cmd"
    echo "Output: $output_file"
    echo "--------------------------------"
    $cmd 2>&1 | tee "$output_file"
}

# 01: Curve data
echo ""
echo "[01] Extracting curve data..."
run_and_save "sage src/01_curve_data.sage $CURVE 5000" "$OUTPUT_DIR/01_curve_data_${CURVE}.txt"

# 02: Principal part demo
echo ""
echo "[02] Computing principal part match..."
run_and_save "sage src/02_principal_part_demo.sage $CURVE 1e-3 30000 1.2" "$OUTPUT_DIR/02_principal_part_${CURVE}.txt"

# 03: Gap polynomial demo
echo ""
echo "[03] Computing Hecke separator polynomial..."
run_and_save "sage src/03_gap_poly_demo.sage $CURVE 29 2" "$OUTPUT_DIR/03_gap_poly_${CURVE}.txt"

# 04: Renormalization matrix (using conductor)
echo ""
echo "[04] Computing renormalization matrix..."
# Extract conductor for the curve
CONDUCTOR=$(sage -c "print(EllipticCurve('$CURVE').conductor())" 2>/dev/null)
run_and_save "python3 src/04_renorm_matrix_demo.py $CONDUCTOR" "$OUTPUT_DIR/04_renorm_matrix_N${CONDUCTOR}.txt"

# 05: BSD components and kappa
echo ""
echo "[05] Computing BSD components..."
run_and_save "sage src/05_kappa_leading_coeff.sage $CURVE" "$OUTPUT_DIR/05_bsd_components_${CURVE}.txt"

echo ""
echo "================================================================"
echo "All demos completed!"
echo "Console logs saved in: $OUTPUT_DIR/"
echo "Computation results saved in: data/"
echo ""
echo "To view saved data files:"
echo "  ls -la data/*.json"
echo "  ls -la data/*.npz"
echo ""
echo "Generating results summary..."
python3 src/view_results.py $CURVE > "data/results_summary_${CURVE}.txt"
echo "Summary saved to: data/results_summary_${CURVE}.txt"
echo "================================================================"
