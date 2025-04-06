#!/bin/bash

# This script tests the 'roocode' feature

# Source the test utilities library
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib
set -e

# Options specific to this feature
MODESCONFIGPATH="${MODESCONFIGPATH:-"/home/node/.config/roocode/.roomodes"}" # Default value if not set
SETTINGS_JSON_PATH="${_REMOTE_USER_HOME}/.vscode-server/data/Machine/settings.json"

# Definition specific tests
check "Verify Roo Cline extension is installed" bash -c 'code --list-extensions | grep -i "RooVeterinaryInc.roo-cline"'

check "Verify modes config file exists at specified path" test -f "$MODESCONFIGPATH"

# Check if settings directory exists before checking the file itself
check "Verify VS Code settings directory exists" test -d "$(dirname "$SETTINGS_JSON_PATH")"

check "Verify VS Code settings file exists" test -f "$SETTINGS_JSON_PATH"

# Check setting using jq, assuming it's installed by install.sh
check "Verify roocode.modesConfigPath setting is correctly configured in VS Code settings using jq" jq -e --arg path "$MODESCONFIGPATH" '."roocode.modesConfigPath" == $path' "$SETTINGS_JSON_PATH"

# Report results
# If any of the checks above exited with a non-zero exit code, the script will have exited automatically due to 'set -e'
reportResults