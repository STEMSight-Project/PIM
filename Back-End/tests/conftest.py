"""
Root conftest.py for Back-End tests.
Sets up Python path to allow imports from project modules.
"""

import sys
from pathlib import Path

# Add the Back-End directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

print(f"✅ Added to Python path: {backend_dir}")
