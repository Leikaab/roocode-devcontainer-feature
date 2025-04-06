#!/bin/bash

# Optional: Load the devcontainer-cli functionality
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from dev-container-features-test-lib
check "Verify python version (example)" bash -c "python --version | grep '3.11'" # Adjust based on default/tested option
check "Verify jq is installed" command -v jq
check "Verify git alias 'st' exists (example)" bash -c "git config --global --get-regexp '^alias\.st$'"

# Report result
# If any of the checks above fail, the script will exit non-zero triggering a failure
reportResults