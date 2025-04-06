#!/bin/bash
# install.sh for roocode devcontainer feature

set -e

# Input variable from devcontainer-feature.json options
# Default path uses _REMOTE_USER_HOME if MODESCONFIGPATH is not set
# This will be set later after USER_HOME is determined
# MODESCONFIGPATH="${MODESCONFIGPATH:-${_REMOTE_USER_HOME}/.config/roocode/.roomodes}"

# Determine the non-root user and home directory
USERNAME=""
USER_HOME=""

# 1. Check if _REMOTE_USER is set and non-root
if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    USERNAME="${_REMOTE_USER}"
    echo "Using provided _REMOTE_USER: ${USERNAME}"
# 2. Check if running as root
elif [ "$(id -u)" -eq 0 ]; then
    echo "Running as root."
    # Try to find user 1000
    EXISTING_USER_1000=$(id -un 1000 2>/dev/null)
    if [ -n "${EXISTING_USER_1000}" ]; then
        USERNAME=${EXISTING_USER_1000}
        echo "Using existing user '${USERNAME}' (UID 1000)."
    else
        # If user 1000 not found, create a default user 'node'
        USERNAME=node
        echo "User 1000 not found. Checking/creating user '${USERNAME}' with UID 1000."
        if ! id -u ${USERNAME} > /dev/null 2>&1; then
            # Create group if it doesn't exist
            if ! getent group ${USERNAME} > /dev/null 2>&1; then
                groupadd -r ${USERNAME} -g 1000
            fi
            # Create user - removed -l flag, ensure home dir exists with correct perms
            useradd -r -u 1000 -g ${USERNAME} -m -s /bin/bash ${USERNAME}
            echo "Attempted to create user '${USERNAME}'."
            # Verify user creation and home directory
            if ! id -u ${USERNAME} > /dev/null 2>&1; then
                echo "Error: Failed to create user '${USERNAME}'."
                exit 1
            fi
            USER_HOME_CREATED=$(getent passwd ${USERNAME} | cut -d: -f6)
            if [ -z "${USER_HOME_CREATED}" ] || [ ! -d "${USER_HOME_CREATED}" ]; then
                echo "Warning: Home directory '${USER_HOME_CREATED:-/home/$USERNAME}' not found or not created automatically for ${USERNAME}. Attempting manual creation."
                # Use the standard expected path if getent failed
                USER_HOME_TO_CREATE="/home/${USERNAME}"
                mkdir -p "${USER_HOME_TO_CREATE}"
                # Attempt chown, using USERNAME for group as fallback if group creation failed earlier or isn't primary
                chown "${USERNAME}:${USERNAME}" "${USER_HOME_TO_CREATE}" || echo "Warning: Initial chown for ${USER_HOME_TO_CREATE} failed."
            fi
        else
             echo "User '${USERNAME}' already exists."
        fi
    fi
# 3. Running as non-root
else
    USERNAME=$(id -un)
    echo "Running as non-root user '${USERNAME}'."
fi

# Determine home directory for the determined USERNAME
# 1. Prefer _REMOTE_USER_HOME if set and valid for the determined user
#    (Note: This might be set for root, but we want the non-root user's home)
#    We will prioritize finding the actual user's home first.

# 2. Get home dir of the determined USERNAME from /etc/passwd
USER_HOME=$(getent passwd ${USERNAME} | cut -d: -f6)
echo "Attempting to get home directory for '${USERNAME}' via getent: Result='${USER_HOME}'"

# 3. Fallback if getent fails or home dir doesn't exist/isn't a directory
if [ -z "${USER_HOME}" ] || [ ! -d "${USER_HOME}" ]; then
    # If _REMOTE_USER_HOME is set AND matches the determined USERNAME's expected home, use it.
    # This handles cases where home might be non-standard but provided.
    EXPECTED_REMOTE_HOME_FOR_USER="/home/${USERNAME}" # Common pattern
    if [ -n "${_REMOTE_USER_HOME}" ] && [ -d "${_REMOTE_USER_HOME}" ]; then
         # Simple check: Does the provided home belong to the user?
         # A more robust check might involve stat -c '%U' $_REMOTE_USER_HOME
         # For now, we assume if _REMOTE_USER_HOME is provided, it's intended.
         USER_HOME="${_REMOTE_USER_HOME}"
         echo "Home directory for '${USERNAME}' not found via getent. Using provided _REMOTE_USER_HOME: ${USER_HOME}"
    else
        # Standard fallback
        FALLBACK_HOME="/home/${USERNAME}"
        echo "Home directory for '${USERNAME}' not found via getent and _REMOTE_USER_HOME not suitable/provided. Using standard fallback: ${FALLBACK_HOME}"
        USER_HOME="${FALLBACK_HOME}"
        # Ensure home directory exists if we derived it
        # Ensure home directory exists if we derived it via fallback
        if [ ! -d "${USER_HOME}" ]; then
            echo "Creating fallback home directory ${USER_HOME} for user ${USERNAME}."
            # Create parent directories if they don't exist
            mkdir -p "$(dirname "${USER_HOME}")"
            # Create the home directory itself
            mkdir -p "${USER_HOME}"
            # Attempt to set ownership
            USER_GROUP=$(id -gn ${USERNAME} 2>/dev/null || echo ${USERNAME})
            if chown "${USERNAME}:${USER_GROUP}" "${USER_HOME}"; then
                echo "Ownership set for ${USER_HOME}"
            else
                echo "Warning: Failed to set ownership for ${USER_HOME}. Permissions might be incorrect."
            fi
        fi
    fi
else
    echo "Using home directory for '${USERNAME}' from /etc/passwd: ${USER_HOME}"
fi

# 4. Final check: If _REMOTE_USER is set and _REMOTE_USER_HOME is provided,
#    ensure USER_HOME matches _REMOTE_USER_HOME if they are for the same user.
#    This handles cases where getent might find a different home than specified.
if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" = "${USERNAME}" ] && \
   [ -n "${_REMOTE_USER_HOME}" ] && [ "${USER_HOME}" != "${_REMOTE_USER_HOME}" ]; then
    echo "Warning: Determined home '${USER_HOME}' differs from provided _REMOTE_USER_HOME '${_REMOTE_USER_HOME}' for user '${USERNAME}'. Preferring _REMOTE_USER_HOME."
    USER_HOME="${_REMOTE_USER_HOME}"
    # Ensure the directory exists if we switch to it
    # Ensure the preferred directory exists if we switch to it
    if [ ! -d "${USER_HOME}" ]; then
        echo "Creating preferred home directory ${_REMOTE_USER_HOME} for user ${USERNAME}..."
        # Create parent directories if they don't exist
        mkdir -p "$(dirname "${USER_HOME}")"
        # Create the home directory itself
        mkdir -p "${USER_HOME}"
        # Attempt to set ownership
        USER_GROUP=$(id -gn ${USERNAME} 2>/dev/null || echo ${USERNAME})
        if chown "${USERNAME}:${USER_GROUP}" "${USER_HOME}"; then
            echo "Ownership set for ${USER_HOME}"
        else
            echo "Warning: Failed to set ownership for ${USER_HOME}. Permissions might be incorrect."
        fi
    fi
fi


# Final check for valid user and home
if [ -z "${USERNAME}" ] || [ -z "${USER_HOME}" ]; then
    echo "Error: Could not reliably determine a valid user or home directory."
    exit 1
fi

# Now set the MODESCONFIGPATH using the determined USER_HOME
MODESCONFIGPATH="${MODESCONFIGPATH:-${USER_HOME}/.config/roocode/.roomodes}"
echo "Installing roocode feature..."
echo "Modes config path: ${MODESCONFIGPATH}"
echo "Determined user: ${USERNAME}"
echo "Determined user home: ${USER_HOME}"

# Install jq for JSON manipulation
echo "Installing jq..."
if ! command -v jq &> /dev/null; then
    apt-get update && apt-get install -y jq
else
    echo "jq is already installed."
fi

# Create directory for modes file
MODES_DIR="$(dirname "$MODESCONFIGPATH")"
echo "Creating modes config directory: ${MODES_DIR}"
mkdir -p "${MODES_DIR}"

# Create default .roomodes file
echo "Creating default .roomodes file at ${MODESCONFIGPATH}..."
cat << EOF > "$MODESCONFIGPATH"
# Roo Mode Configuration - Generated by roocode devcontainer feature

[mode.boomerang-mode]
name = "Boomerang Mode"
description = "You are Roo, a strategic workflow orchestrator who coordinates complex tasks by delegating them to appropriate specialized modes."
instructions = """
Your role is to coordinate complex workflows by delegating tasks to specialized modes, optimizing for quality, cost, and speed based on the underlying models.

**Core Responsibilities:**

1.  **Task Decomposition:** When given a complex task, break it down into logical, discrete subtasks suitable for delegation.

2.  **Intelligent Delegation (Mode Selection):** For each subtask, use the \`new_task\` tool. Critically evaluate the subtask's requirements against the available modes and their underlying models:
    *   **High Capability (Gemini 2.5 Pro - Free, Rate Limited):** Modes like \`infra-codegen\`, \`code-reviewer\`, \`optimizer\`, \`pseudocode-architect\`, \`spec-writer\`, \`doc-writer\`, \`debugger\`. Use these for tasks requiring deep understanding, complex reasoning, high accuracy, or specialized knowledge (infra, architecture, review, debugging). Be mindful of rate limits; sequence tasks if necessary or if parallel execution might hit limits.
    *   **Very High Capability (Claude 3.7 - Expensive, Not Rate Limited):** The \`sr-codegen\` mode. Use this for the most critical, complex code generation tasks where top-tier quality, robustness, and security are paramount, and the cost is justified. Also suitable when rate limits on free models are a blocker for urgent tasks.
    *   **Moderate Capability (Quasar - Free, Rate Limited):** The \`free-codegen\` mode. Use this for moderately complex coding tasks where cost savings are desired, and potential rate limits are acceptable. A good alternative to \`jr-codegen\` if slightly higher capability is needed without incurring cost, accepting rate limits.
    *   **Lower Capability (Gemini 2.0 Flash - Cheap, Largely Unrestricted):** Modes like \`jr-codegen\` and \`test-writer\`. Use these for simpler, routine tasks like generating boilerplate code, straightforward functions based on clear specs, or writing standard unit tests. Excellent for cost-sensitive tasks or when speed/throughput (minimal rate limits) is important for non-critical items.
    *   **Your Selection Rationale:** Clearly state *why* you chose a specific mode in your reasoning (see point 4), referencing the task's needs and the chosen mode/model's strengths (e.g., \\"Delegating complex architecture pseudocode to \`pseudocode-architect\` (Gemini 2.5 Pro) for its high capability, accepting potential rate limits.\\" or \\"Using \`jr-codegen\` (Gemini 2.0 Flash) for this utility function because it's straightforward, cost-effective, and less likely to be rate-limited.\\").

3.  **Subtask Instruction:** When using \`new_task\`, provide comprehensive instructions in the \`message\` parameter, including:
    *   All necessary context from the parent task or previous subtasks.
    *   A clearly defined scope for the subtask.
    *   An explicit statement that the subtask should *only* perform the specified work.
    *   An instruction for the subtask to signal completion using \`attempt_completion\`, providing a concise, thorough summary of the outcome in the \`result\` (this summary is the source of truth for progress).
    *   A statement that these specific instructions supersede any conflicting general instructions of the subtask's mode.

4.  **Transparency and Reasoning:** Track subtask progress. When delegating or upon completion, explain the workflow to the user. Justify your choice of mode for each subtask based on the criteria outlined in point 2 (task complexity, criticality, cost, rate limits, required capability).

5.  **Synthesis and Overview:** Once all subtasks are complete, synthesize the results from the \`attempt_completion\` summaries and provide a comprehensive overview of the final outcome.

6.  **Clarification and Adaptation:** Ask clarifying questions if the main task or constraints are unclear. Suggest workflow improvements or alternative delegation strategies if initial results indicate a different approach might be better (e.g., switching to a more capable model if a cheaper one fails, or sequencing tasks if rate limits are hit).

7.  **Maintain Clarity:** Use subtasks appropriately. If a request introduces a significantly different type of work or requires different expertise/cost/speed considerations, create a new subtask rather than overloading an existing one.
"""

[mode.code]
name = "Senior Code Generator"
description = "You write complex or critical application code with high standards for maintainability, security, and performance"

[mode.architect]
name = "Architect"
description = "You are Roo, an experienced technical leader who is inquisitive and an excellent planner"

[mode.ask]
name = "Ask"
description = "You are Roo, a knowledgeable technical assistant focused on answering questions and providing information about software development, technology, and related topics"

[mode.debug]
name = "Debug"
description = "You are Roo, an expert software debugger specializing in systematic problem diagnosis and resolution"

[mode.jr-codegen]
name = "Junior Code Generator"
description = "You turn pseudocode or detailed specs into clean, idiomatic, production-grade code using best practices"

[mode.free-codegen]
name = "Free Ratelimited Junior Code Generator"
description = "You turn pseudocode or detailed specs into clean, idiomatic, production-grade code using best practices"

[mode.infra-codegen]
name = "Infrastructure Code Generator"
description = "You create scripts, infrastructure-as-code (Terraform, Dockerfiles, etc"

[mode.code-reviewer]
name = "Code Reviewer"
description = "You analyze code quality, performance, security, and maintainability"

[mode.optimizer]
name = "Code Optimizer"
description = "You refine and optimize existing code for performance, readability, and maintainability without changing its core functionality"

[mode.test-writer]
name = "Test Writer"
description = "You generate automated test cases (unit, integration, etc"

[mode.pseudocode-architect]
name = "Pseudocode Architect"
description = "You write detailed pseudocode based on specifications and high-level requirements to guide implementation logic and system design"

[mode.spec-writer]
name = "Specification Writer"
description = "You create detailed functional or technical specifications for features, APIs, and systems based on high-level requirements"

[mode.doc-writer]
name = "Documentation Writer"
description = "You write clear and concise documentation for codebases, APIs, features, and systems, targeting the intended audience (users or developers)"

[mode.debugger]
name = "Debugger"
description = "You analyze code, error messages, and context to identify the root cause of bugs or unexpected behavior"
EOF

# Update VS Code settings.json
SETTINGS_JSON_PATH="${USER_HOME}/.vscode-server/data/Machine/settings.json"
SETTINGS_DIR="$(dirname "$SETTINGS_JSON_PATH")"

echo "Updating VS Code settings at ${SETTINGS_JSON_PATH}..."
mkdir -p "$SETTINGS_DIR"

# Ensure the settings file exists and is owned by the remote user before modifying
if [ ! -f "$SETTINGS_JSON_PATH" ]; then
    echo "{}" > "$SETTINGS_JSON_PATH"
    echo "Initialized empty ${SETTINGS_JSON_PATH}"
    USER_GROUP=$(id -gn ${USERNAME} 2>/dev/null || echo ${USERNAME}) # Get group or fallback to username
    chown "${USERNAME}:${USER_GROUP}" "$SETTINGS_JSON_PATH"
fi

# Ensure the file is valid JSON or re-initialize it
if ! jq empty "$SETTINGS_JSON_PATH" > /dev/null 2>&1; then
    echo "Warning: ${SETTINGS_JSON_PATH} contains invalid JSON. Re-initializing."
    echo "{}" > "$SETTINGS_JSON_PATH"
    USER_GROUP=$(id -gn ${USERNAME} 2>/dev/null || echo ${USERNAME}) # Get group or fallback to username
    chown "${USERNAME}:${USER_GROUP}" "$SETTINGS_JSON_PATH" # Ensure ownership after potential overwrite
fi

# Add/update the setting using jq safely
TMP_JSON=$(mktemp)
if jq --arg path "$MODESCONFIGPATH" '."roocode.modesConfigPath" = $path' "$SETTINGS_JSON_PATH" > "$TMP_JSON"; then
    mv "$TMP_JSON" "$SETTINGS_JSON_PATH"
    echo "Updated roocode.modesConfigPath in $SETTINGS_JSON_PATH"
else
    echo "Error: Failed to update ${SETTINGS_JSON_PATH} with jq."
    rm -f "$TMP_JSON"
    # Optionally exit here if this setting is critical
    # exit 1
fi

# Set ownership for modes directory and settings directory
echo "Setting ownership for created files/directories..."
USER_GROUP=$(id -gn ${USERNAME} 2>/dev/null || echo ${USERNAME}) # Get group or fallback to username
chown -R "${USERNAME}:${USER_GROUP}" "${MODES_DIR}"
# Ensure settings dir ownership is correct too, in case mkdir created it
chown -R "${USERNAME}:${USER_GROUP}" "$SETTINGS_DIR"
# Ensure settings file ownership is correct after modification by root (jq)
chown "${USERNAME}:${USER_GROUP}" "$SETTINGS_JSON_PATH"


echo "roocode feature installation complete."