"""
Quick test runner script for STEMSight backend
Run specific test suites with easy commands
"""
import sys
import subprocess
from pathlib import Path

def run_command(cmd):
    """Run command and return exit code"""
    print(f"\n🧪 Running: {' '.join(cmd)}\n")
    result = subprocess.run(cmd, cwd=Path(__file__).parent)
    return result.returncode

def main():
    if len(sys.argv) < 2:
        print("""
STEMSight Test Runner
=====================

Usage: python run_tests.py <suite>

Available test suites:
  all          - Run all tests
  streaming    - Run streaming service tests
  ai           - Run AI model tests
  api          - Run API route tests
  coverage     - Run all tests with coverage report
  quick        - Run quick unit tests only (skip slow tests)
  
Examples:
  python run_tests.py streaming
  python run_tests.py coverage
  python run_tests.py all -v
""")
        return 1
    
    suite = sys.argv[1].lower()
    extra_args = sys.argv[2:] if len(sys.argv) > 2 else []
    
    # Base pytest command
    pytest_cmd = ["pytest"]
    
    # Suite-specific configurations
    if suite == "all":
        pytest_cmd.extend(["tests/", *extra_args])
    
    elif suite == "streaming":
        pytest_cmd.extend(["tests/services/streaming/", "-m", "streaming or not streaming", *extra_args])
    
    elif suite == "ai":
        pytest_cmd.extend(["tests/services/ai/", *extra_args])
    
    elif suite == "api":
        pytest_cmd.extend(["tests/api_router/", *extra_args])
    
    elif suite == "coverage":
        pytest_cmd.extend([
            "tests/",
            "--cov=services",
            "--cov=api_router",
            "--cov-report=html",
            "--cov-report=term-missing",
            *extra_args
        ])
        print("📊 Coverage report will be generated in htmlcov/")
    
    elif suite == "quick":
        pytest_cmd.extend(["tests/", "-m", "not slow", *extra_args])
    
    else:
        print(f"❌ Unknown test suite: {suite}")
        print("Run 'python run_tests.py' for usage help")
        return 1
    
    # Run tests
    exit_code = run_command(pytest_cmd)
    
    if exit_code == 0:
        print("\n✅ All tests passed!")
    else:
        print(f"\n❌ Tests failed with exit code {exit_code}")
    
    return exit_code

if __name__ == "__main__":
    sys.exit(main())
