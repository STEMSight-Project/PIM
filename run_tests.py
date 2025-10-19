"""
Test Runner Script for AI Training Pipeline
Runs all unit tests and generates coverage report
"""

import subprocess
import sys
from pathlib import Path


def run_tests():
    """Run all tests with pytest"""
    print("=" * 80)
    print("Running AI Training Pipeline Unit Tests")
    print("=" * 80)
    print()

    # Test directories
    backend_tests = Path("Back-End/tests/services/ai")
    training_tests = Path("AI_Training/tests")

    # Run backend tests
    print("📋 Running Backend AI Service Tests...")
    print("-" * 80)
    result_backend = subprocess.run(
        [
            sys.executable,
            "-m",
            "pytest",
            str(backend_tests),
            "-v",
            "--tb=short",
            "-m",
            "unit",
        ],
        cwd=Path.cwd(),
    )

    print()
    print("📋 Running AI Training Pipeline Tests...")
    print("-" * 80)
    result_training = subprocess.run(
        [
            sys.executable,
            "-m",
            "pytest",
            str(training_tests),
            "-v",
            "--tb=short",
            "-m",
            "unit",
        ],
        cwd=Path.cwd(),
    )

    print()
    print("=" * 80)
    if result_backend.returncode == 0 and result_training.returncode == 0:
        print("✅ All tests passed!")
    else:
        print("❌ Some tests failed. See output above.")
    print("=" * 80)

    return result_backend.returncode + result_training.returncode


def run_tests_with_coverage():
    """Run tests with coverage report"""
    print("=" * 80)
    print("Running Tests with Coverage")
    print("=" * 80)
    print()

    result = subprocess.run(
        [
            sys.executable,
            "-m",
            "pytest",
            "Back-End/tests/services/ai",
            "AI_Training/tests",
            "-v",
            "--cov=Back-End/services/ai",
            "--cov=AI_Training",
            "--cov-report=html",
            "--cov-report=term",
            "-m",
            "unit",
        ],
        cwd=Path.cwd(),
    )

    print()
    print("=" * 80)
    print("📊 Coverage report generated in htmlcov/index.html")
    print("=" * 80)

    return result.returncode


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Run AI Training tests")
    parser.add_argument(
        "--coverage", action="store_true", help="Run tests with coverage report"
    )
    parser.add_argument(
        "--markers",
        type=str,
        default="unit",
        help="Pytest markers to run (unit, integration, gpu, slow)",
    )

    args = parser.parse_args()

    if args.coverage:
        sys.exit(run_tests_with_coverage())
    else:
        sys.exit(run_tests())
