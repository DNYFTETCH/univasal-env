#!/usr/bin/env bash
#
# Test script for Universal Linux Environment
# Verifies all components are present and functional
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

passed=0
failed=0

test_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((passed++))
}

test_fail() {
  echo -e "${RED}✗${NC} $1"
  ((failed++))
}

test_warn() {
  echo -e "${YELLOW}!${NC} $1"
}

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║   Universal Linux Environment - Test Suite       ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Test 1: Check files exist
echo -e "${BLUE}[1/6]${NC} Checking required files..."
for file in README.md UNIVERSAL_LINUX_SETUP.md Makefile setup.sh upm; do
  if [ -f "$file" ]; then
    test_pass "$file exists"
  else
    test_fail "$file missing"
  fi
done
echo ""

# Test 2: Check scripts are executable
echo -e "${BLUE}[2/6]${NC} Checking script permissions..."
for script in setup.sh upm; do
  if [ -x "$script" ]; then
    test_pass "$script is executable"
  else
    test_fail "$script is not executable"
  fi
done
echo ""

# Test 3: Test UPM script syntax
echo -e "${BLUE}[3/6]${NC} Testing UPM syntax..."
if bash -n upm; then
  test_pass "UPM script syntax valid"
else
  test_fail "UPM script has syntax errors"
fi

if ./upm help >/dev/null 2>&1; then
  test_pass "UPM help command works"
else
  test_fail "UPM help command failed"
fi
echo ""

# Test 4: Test setup script syntax
echo -e "${BLUE}[4/6]${NC} Testing setup script syntax..."
if bash -n setup.sh; then
  test_pass "Setup script syntax valid"
else
  test_fail "Setup script has syntax errors"
fi
echo ""

# Test 5: Test Makefile
echo -e "${BLUE}[5/6]${NC} Testing Makefile..."
if make -n help >/dev/null 2>&1; then
  test_pass "Makefile syntax valid"
else
  test_fail "Makefile has syntax errors"
fi

if make help | grep -q "Available targets"; then
  test_pass "Makefile help target works"
else
  test_fail "Makefile help target failed"
fi
echo ""

# Test 6: Check documentation
echo -e "${BLUE}[6/6]${NC} Checking documentation..."
if grep -q "Universal Linux Environment" README.md; then
  test_pass "README.md contains correct content"
else
  test_fail "README.md missing content"
fi

if grep -q "Universal Linux Environment Setup Guide" UNIVERSAL_LINUX_SETUP.md; then
  test_pass "Setup guide contains correct content"
else
  test_fail "Setup guide missing content"
fi
echo ""

# Summary
echo "╔═══════════════════════════════════════════════════╗"
echo "║   Test Results                                    ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Passed:${NC} $passed"
echo -e "${RED}Failed:${NC} $failed"
echo ""

if [ $failed -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo ""
  echo "Ready to install:"
  echo "  make setup     # Run full setup"
  echo "  make install   # Install UPM"
  echo "  make test      # Test installation"
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  exit 1
fi
