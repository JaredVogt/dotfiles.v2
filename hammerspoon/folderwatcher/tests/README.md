# Folderwatcher Test Suite

## Overview
This test suite verifies that the folderwatcher module correctly:
- Detects file events (create, modify, delete)
- Passes correct arguments to scripts
- Applies include/exclude filters
- Handles errors gracefully

## Test Structure
```
tests/
├── run_tests.sh          # Main test runner
├── test_config.toml      # Test configuration
├── test_helper.lua       # Hammerspoon console helpers
├── test_scripts/         # Scripts that verify behavior
│   ├── log_event.sh      # Logs all events
│   └── verify_args.sh    # Validates arguments
├── test_results/         # Test outputs (gitignored)
└── test_workspace/       # Temporary test files (gitignored)
```

## Running Tests

### Method 1: Using test_helper.lua (Recommended)
1. Open Hammerspoon console
2. Run: `dofile(hs.configdir .. "/folderwatcher/tests/test_helper.lua")`
3. Run: `startFolderwatcherTests()`
4. In terminal: `cd ~/projects/dotfiles.v2/hammerspoon/folderwatcher/tests && ./run_tests.sh`
5. When done: `restoreFolderwatcherConfig()`

### Method 2: Manual Setup
1. In Hammerspoon console:
   ```lua
   folderwatcher.stop()
   folderwatcher.loadConfig(hs.configdir .. "/folderwatcher/tests/test_config.toml")
   folderwatcher.start()
   ```
2. Run the test script: `./run_tests.sh`
3. Restore normal config when done

### Quick Test
For a quick sanity check:
```lua
dofile(hs.configdir .. "/folderwatcher/tests/test_helper.lua")
quickTestFolderwatcher()
```

## What Gets Tested

1. **Basic Events** - File creation, modification, deletion
2. **Filters** - Include patterns (*.txt, *.log), exclude patterns (*.tmp, test_*)
3. **Script Arguments** - Verifies correct format and values
4. **Error Handling** - Missing scripts generate appropriate errors

## Test Results

- **events.log** - All detected file events
- **verification.log** - Argument validation results
- **errors.log** - Any errors from verify_args.sh
- **\*.marker files** - Presence indicates event was triggered

## Troubleshooting

- Check Hammerspoon console for debug output
- Ensure test config is loaded: `folderwatcher.status()`
- Look for errors in test_results/errors.log
- Verify scripts are executable: `ls -la test_scripts/`