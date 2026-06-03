#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$DIR/tests"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
FAILED_TESTS=()
TMP_OUTPUT_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_OUTPUT_DIR"' EXIT

echo "Running tests in $TEST_DIR..."
echo "-----------------------------------"

# Find all .sh files in the tests directory, sort them naturally
for test_file in $(ls "$TEST_DIR"/test_slice*.sh | sort -V); do
    test_name=$(basename "$test_file")
    output_file="$TMP_OUTPUT_DIR/$test_name.log"
    start_time=$SECONDS
    printf "Running %-40s " "$test_name..."

    if bash "$test_file" >"$output_file" 2>&1; then
        elapsed=$((SECONDS - start_time))
        echo -e "${GREEN}PASS${NC} (${elapsed}s)"
        PASSED=$((PASSED + 1))
    else
        elapsed=$((SECONDS - start_time))
        echo -e "${RED}FAIL${NC} (${elapsed}s)"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$test_name")
        echo "---- $test_name output ----"
        cat "$output_file"
        echo "---------------------------"
    fi
done

echo "-----------------------------------"
echo "Summary:"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
    for ft in "${FAILED_TESTS[@]}"; do
        echo "  - $ft"
    done
    exit 1
else
    echo "All tests passed!"
    exit 0
fi
