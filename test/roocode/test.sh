#!/bin/bash

# This script tests the 'roocode' feature

# Source the test utilities library
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib
set -e

# Determine user/home if not provided by test environment
_REMOTE_USER="${_REMOTE_USER:-"$(id -un 1000 2>/dev/null || echo vscode)"}"
_REMOTE_USER_HOME="${_REMOTE_USER_HOME:-"/home/${_REMOTE_USER}"}"

# Options specific to this feature
# MODESCONFIGPATH is now expected to be set by the test framework based on scenarios.json
SETTINGS_JSON_PATH="${_REMOTE_USER_HOME}/.vscode-server/data/Machine/settings.json"

# Ensure jq is available
check "jq is installed" command -v jq

# Definition specific tests
# install.sh determines user/home and creates the file relative to that.
# For root/debian scenarios, this should consistently be /home/node/.config/roocode/.roomodes
EXPECTED_MODES_PATH="/home/node/.config/roocode/.roomodes"
check "Verify modes config file exists at determined user path (${EXPECTED_MODES_PATH})" test -f "$EXPECTED_MODES_PATH"

# Check if settings directory exists before checking the file itself
check "Verify VS Code settings directory exists" test -d "$(dirname "$SETTINGS_JSON_PATH")"

check "Verify VS Code settings file exists" test -f "$SETTINGS_JSON_PATH"

# Check setting using jq, assuming it's installed by install.sh
# The setting in settings.json should reflect the *actual* path determined and used by install.sh
check "Verify roocode.modesConfigPath setting matches determined path (${EXPECTED_MODES_PATH}) in VS Code settings using jq" jq -e --arg path "$EXPECTED_MODES_PATH" '."roocode.modesConfigPath" == $path' "$SETTINGS_JSON_PATH"

# Report results
# If any of the checks above exited with a non-zero exit code, the script will have exited automatically due to 'set -e'
reportResults