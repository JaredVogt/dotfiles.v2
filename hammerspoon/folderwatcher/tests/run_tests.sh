#!/bin/bash
# Folderwatcher Test Suite
# Run this to test the folderwatcher module

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_WORKSPACE="$SCRIPT_DIR/test_workspace"
TEST_RESULTS="$SCRIPT_DIR/test_results"

echo "🧪 Folderwatcher Test Suite"
echo "=========================="

# Clean up previous test results
echo -e "${YELLOW}Cleaning up previous test results...${NC}"
rm -rf "$TEST_RESULTS"
mkdir -p "$TEST_RESULTS"

# Create test workspace directories
echo -e "${YELLOW}Setting up test workspace...${NC}"
rm -rf "$TEST_WORKSPACE"
mkdir -p "$TEST_WORKSPACE/filtered"
mkdir -p "$TEST_WORKSPACE/errors"

# Function to wait for event processing
wait_for_events() {
    sleep 2  # Give folderwatcher time to process events
}

# Function to check if a marker file exists with retry
check_marker() {
    local pattern="$1"
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if ls "$TEST_RESULTS"/$pattern*.marker 2>/dev/null >/dev/null; then
            return 0
        fi
        
        # If not last attempt, wait a bit and retry
        if [ $attempt -lt $max_attempts ]; then
            sleep 0.5
            ((attempt++))
        else
            return 1
        fi
    done
}

# Load test configuration in Hammerspoon
echo -e "${YELLOW}Loading test configuration in Hammerspoon...${NC}"
echo -e "${YELLOW}Note: If this fails, enable AppleScript in Hammerspoon console with: hs.allowAppleScript(true)${NC}"

# Try to load test config via AppleScript, fall back to manual if it fails
if ! osascript -e 'tell application "Hammerspoon" to execute lua code "dofile(hs.configdir .. \"/folderwatcher/tests/test_helper.lua\"); startFolderwatcherTests()"' 2>/dev/null
then
    echo -e "${RED}AppleScript access failed. Please run in Hammerspoon console:${NC}"
    echo "  dofile(hs.configdir .. '/folderwatcher/tests/test_helper.lua'); startFolderwatcherTests()"
    echo ""
    echo "Press Enter when ready to continue..."
    read
fi

# Give Hammerspoon time to load and start watchers
echo -e "${YELLOW}Waiting for watchers to start...${NC}"
sleep 3

# Test 1: Basic file creation
echo -e "\n${YELLOW}Test 1: Basic file creation${NC}"
touch "$TEST_WORKSPACE/test1.txt"
wait_for_events

if check_marker "created_test1.txt"; then
    echo -e "${GREEN}✓ File creation event detected (marker found)${NC}"
elif grep -q "created.*test1.txt" "$TEST_RESULTS/events.log" 2>/dev/null; then
    echo -e "${YELLOW}⚠ File creation event logged but marker delayed${NC}"
else
    echo -e "${RED}✗ File creation event NOT detected${NC}"
fi

# Test 2: File modification
echo -e "\n${YELLOW}Test 2: File modification${NC}"
sleep 2  # Ensure modification timestamp is different from creation
touch -m "$TEST_WORKSPACE/test1.txt"  # Force modification time update
wait_for_events

if check_marker "modified_test1.txt"; then
    echo -e "${GREEN}✓ File modification event detected (marker found)${NC}"
elif grep -q "modified.*test1.txt" "$TEST_RESULTS/events.log" 2>/dev/null; then
    echo -e "${YELLOW}⚠ File modification event logged but marker delayed${NC}"
else
    echo -e "${RED}✗ File modification event NOT detected${NC}"
fi

# Test 3: File deletion
echo -e "\n${YELLOW}Test 3: File deletion${NC}"
rm "$TEST_WORKSPACE/test1.txt"
wait_for_events

if check_marker "deleted_test1.txt"; then
    echo -e "${GREEN}✓ File deletion event detected${NC}"
else
    echo -e "${RED}✗ File deletion event NOT detected${NC}"
fi

# Test 4: Filter inclusion
echo -e "\n${YELLOW}Test 4: Filter inclusion (should trigger)${NC}"
touch "$TEST_WORKSPACE/filtered/allowed.txt"
wait_for_events

if grep -q "PASS.*allowed.txt" "$TEST_RESULTS/verification.log" 2>/dev/null; then
    echo -e "${GREEN}✓ Filtered file correctly processed${NC}"
else
    echo -e "${RED}✗ Filtered file NOT processed${NC}"
fi

# Test 5: Filter exclusion
echo -e "\n${YELLOW}Test 5: Filter exclusion (should NOT trigger)${NC}"
touch "$TEST_WORKSPACE/filtered/test_excluded.txt"
touch "$TEST_WORKSPACE/filtered/file.tmp"
wait_for_events

if ! grep -q "test_excluded.txt\|file.tmp" "$TEST_RESULTS/verification.log" 2>/dev/null; then
    echo -e "${GREEN}✓ Excluded files correctly ignored${NC}"
else
    echo -e "${RED}✗ Excluded files were NOT ignored${NC}"
fi

# Test 6: Non-matching filter
echo -e "\n${YELLOW}Test 6: Non-matching filter (should NOT trigger)${NC}"
touch "$TEST_WORKSPACE/filtered/image.png"
wait_for_events

if ! grep -q "image.png" "$TEST_RESULTS/verification.log" 2>/dev/null; then
    echo -e "${GREEN}✓ Non-matching file correctly ignored${NC}"
else
    echo -e "${RED}✗ Non-matching file was NOT ignored${NC}"
fi

# Test 7: Error handling (missing script)
echo -e "\n${YELLOW}Test 7: Error handling (missing script)${NC}"
touch "$TEST_WORKSPACE/errors/trigger_error.txt"
wait_for_events
echo -e "${YELLOW}Check Hammerspoon console for error message about nonexistent.sh${NC}"

# Show summary
echo -e "\n${YELLOW}Test Summary${NC}"
echo "============"
if [ -f "$TEST_RESULTS/events.log" ]; then
    echo -e "\n${YELLOW}Logged events:${NC}"
    cat "$TEST_RESULTS/events.log"
fi

if [ -f "$TEST_RESULTS/verification.log" ]; then
    echo -e "\n${YELLOW}Verification results:${NC}"
    cat "$TEST_RESULTS/verification.log"
fi

if [ -f "$TEST_RESULTS/errors.log" ]; then
    echo -e "\n${RED}Errors detected:${NC}"
    cat "$TEST_RESULTS/errors.log"
fi

echo -e "\n${YELLOW}Test complete! Check Hammerspoon console for debug output.${NC}"

# Restore normal config automatically
echo -e "\n${YELLOW}Restoring normal folderwatcher config...${NC}"
osascript -e 'tell application "Hammerspoon" to execute lua code "folderwatcher.reload()"'

echo -e "${GREEN}✓ Normal config restored${NC}"