#!/bin/bash

# This script tests the installation of the 'roocode' feature.
# It verifies that jq is installed, the default modes file is created
# with expected content, and the VS Code settings.json is updated correctly.

set -e

# Import test library functions
# shellcheck source=/dev/null
source dev-container-features-test-lib

echo "--- Verifying roocode feature installation ---"

# Logic to determine the remote user's home directory, mirroring install.sh logic
_REMOTE_USER_HOME=""
if id vscode > /dev/null 2>&1; then
    _REMOTE_USER_HOME="/home/vscode"
else
    # Try to get home dir for user 1000
    _REMOTE_USER_HOME=$(getent passwd 1000 | cut -d: -f6)
    # Handle cases where user 1000 doesn't exist or home dir is different
    if [ -z "${_REMOTE_USER_HOME}" ] || [ ! -d "${_REMOTE_USER_HOME}" ]; then
         # Try the current user if not root
         CURRENT_UID=$(id -u)
         if [ "${CURRENT_UID}" != "0" ]; then
             _REMOTE_USER_HOME=$(getent passwd ${CURRENT_UID} | cut -d: -f6)
         fi
         # Fallback to root if all else fails (less ideal but might cover some cases)
         if [ -z "${_REMOTE_USER_HOME}" ] || [ ! -d "${_REMOTE_USER_HOME}" ]; then
             _REMOTE_USER_HOME="/root"
             echo "Warning: Could not determine non-root user home directory. Falling back to ${_REMOTE_USER_HOME}."
         fi
    fi
fi

echo "Detected remote user home: ${_REMOTE_USER_HOME}"

# Define expected paths based on the determined home directory
# Assuming default path for modes config as per install.sh logic
MODESCONFIGPATH="${_REMOTE_USER_HOME}/.config/roocode/.roomodes"
# Assuming standard VS Code server path
SETTINGS_JSON_PATH="${_REMOTE_USER_HOME}/.vscode-server/data/Machine/settings.json"

# --- Test Execution ---

# 1. Check if jq is installed and available in the PATH
check "jq command is available" command -v jq

# 2. Check if the default modes configuration file exists
check "Default modes file exists at ${MODESCONFIGPATH}" test -f "${MODESCONFIGPATH}"

# 3. Check if the modes file contains a known default entry
#    Using grep -q for quiet check, command succeeds if pattern found
check "Modes file contains default [mode.boomerang-mode]" grep -q '\[mode.boomerang-mode\]' "${MODESCONFIGPATH}"

# 4. Check if the VS Code settings.json file exists
#    Note: This might fail if VS Code Server hasn't run yet, but the install script attempts to create the dir structure.
check "VS Code settings.json exists at ${SETTINGS_JSON_PATH}" test -f "${SETTINGS_JSON_PATH}"

# 5. Check if settings.json contains the correct 'roocode.modesConfigPath' setting using jq
#    jq -e sets exit code 0 if the expression is true/non-empty, 1 otherwise.
#    We pass the expected path as an argument to jq for safe comparison.
check "settings.json contains correct roocode.modesConfigPath" jq \
    --arg expectedPath "${MODESCONFIGPATH}" \
    -e \
    '.["roocode.modesConfigPath"] == $expectedPath' \
    "${SETTINGS_JSON_PATH}"

# --- Report Results ---
reportResults
