#!/usr/bin/env python3
"""
Utility functions for saving BSD computation results.
Compatible with both Python and Sage environments.
"""

import json
import os
from datetime import datetime
import numpy as np

def ensure_data_dir():
    """Ensure data directory exists."""
    os.makedirs('data', exist_ok=True)

def complex_to_dict(z):
    """Convert complex number to serializable dict."""
    if hasattr(z, 'real') and hasattr(z, 'imag'):
        # For numpy complex numbers, real and imag are attributes, not methods
        if callable(getattr(z, 'real')):
            return {'real': float(z.real()), 'imag': float(z.imag())}
        else:
            return {'real': float(z.real), 'imag': float(z.imag)}
    else:
        return {'real': float(z), 'imag': 0.0}

def serialize_value(v):
    """Convert Sage/Python values to JSON-serializable format."""
    # Handle None
    if v is None:
        return None
    # Check if it's a numpy complex type
    if isinstance(v, (np.complex64, np.complex128)):
        return complex_to_dict(v)
    # Check if it's Python's complex type
    elif isinstance(v, complex):
        return complex_to_dict(v)
    # Check if Sage complex number (has imag() method, not property)
    elif hasattr(v, 'imag') and callable(getattr(v, 'imag', None)):
        return complex_to_dict(v)
    elif hasattr(v, 'numerical_approx'):
        # Sage number - convert to float
        return float(v.numerical_approx())
    elif isinstance(v, (list, tuple)):
        return [serialize_value(x) for x in v]
    elif isinstance(v, dict):
        return {k: serialize_value(val) for k, val in v.items()}
    elif isinstance(v, np.ndarray):
        return v.tolist()
    elif isinstance(v, (int, np.integer)):
        return int(v)
    elif isinstance(v, (float, np.floating)):
        return float(v)
    elif hasattr(v, '__float__'):
        return float(v)
    elif hasattr(v, '__int__'):
        return int(v)
    else:
        return str(v)

def save_json_results(filename_base, data_dict, curve_label=None):
    """
    Save computation results to JSON file with timestamp.
    
    Args:
        filename_base: Base name for file (e.g., 'principal_part')
        data_dict: Dictionary with computation results
        curve_label: Optional curve label to include in filename
    
    Returns:
        Path to saved file
    """
    ensure_data_dir()
    
    # Add metadata
    data_dict['metadata'] = {
        'timestamp': datetime.now().isoformat(),
        'curve': curve_label if curve_label else 'unknown'
    }
    
    # Serialize all values
    serialized = serialize_value(data_dict)
    
    # Create filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    if curve_label:
        filename = f"data/{filename_base}_{curve_label}_{timestamp}.json"
    else:
        filename = f"data/{filename_base}_{timestamp}.json"
    
    # Save
    with open(filename, 'w') as f:
        json.dump(serialized, f, indent=2)
    
    return filename

def save_numpy_results(filename_base, arrays_dict, metadata=None):
    """
    Save numpy arrays to .npz file.
    
    Args:
        filename_base: Base name for file
        arrays_dict: Dictionary of numpy arrays
        metadata: Optional metadata dict
    
    Returns:
        Path to saved file
    """
    ensure_data_dir()
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"data/{filename_base}_{timestamp}.npz"
    
    # Add metadata as array if provided
    if metadata:
        arrays_dict['metadata'] = np.array([json.dumps(serialize_value(metadata))])
    
    np.savez(filename, **arrays_dict)
    return filename
