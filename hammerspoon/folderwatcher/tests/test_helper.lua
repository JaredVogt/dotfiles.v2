-- Hammerspoon test helper for folderwatcher
-- Run this from Hammerspoon console to set up testing

-- Function to start testing
function startFolderwatcherTests()
    -- Ensure folderwatcher is loaded
    if not folderwatcher then
        folderwatcher = require("folderwatcher.folderwatcher")
    end
    
    -- Stop current watchers
    folderwatcher.stop()
    
    -- Load test config
    local testConfigPath = hs.configdir .. "/folderwatcher/tests/test_config.toml"
    print("Loading test config: " .. testConfigPath)
    
    if folderwatcher.loadConfig(testConfigPath) then
        print("Test config loaded successfully")
        folderwatcher.start()
        print("Test watchers started")
        print("")
        print("Now run: ./run_tests.sh")
    else
        print("Failed to load test config!")
    end
end

-- Function to restore normal config
function restoreFolderwatcherConfig()
    folderwatcher.stop()
    folderwatcher.loadConfig() -- Uses default config path
    folderwatcher.start()
    print("Restored normal folderwatcher config")
end

-- Quick test function
function quickTestFolderwatcher()
    startFolderwatcherTests()
    print("")
    print("Quick test: Creating test file...")
    
    local testFile = os.getenv("HOME") .. "/projects/dotfiles.v2/hammerspoon/folderwatcher/tests/test_workspace/quick_test.txt"
    os.execute("touch " .. testFile)
    
    hs.timer.doAfter(2, function()
        print("Check test_results/events.log for results")
        print("Run restoreFolderwatcherConfig() when done testing")
    end)
end

print("Folderwatcher test helper loaded!")
print("")
print("Available functions:")
print("  startFolderwatcherTests()    - Load test config and start test watchers")
print("  quickTestFolderwatcher()     - Run a quick test")
print("  restoreFolderwatcherConfig() - Restore normal config")
print("  folderwatcher.status()       - Check current watcher status")