#!/bin/bash
# Exit script on any error
set -e

# --- Roocode Feature Installation Script ---

# Options are passed as environment variables (uppercase)
# Accessing options defined in devcontainer-feature.json:
PYTHON_VERSION="${PYTHONVERSION:-"default"}" # Default value if not provided
INSTALL_GIT_ALIAS="${INSTALLGITALIAS:-"true"}"

echo "Starting roocode feature installation..."
echo "Python Version requested: ${PYTHON_VERSION}"
echo "Install Git Alias: ${INSTALL_GIT_ALIAS}"

# Make sure apt-get lists are updated
apt-get update -y

# --- INSTALL YOUR ROOCODE DEPENDENCIES HERE ---
# This is where you add the core logic for your feature.

# Example: Install common tools (adjust as needed)
echo "Installing common utilities..."
apt-get install -y --no-install-recommends \
    curl \
    wget \
    jq \
    unzip \
    ca-certificates \
    git # Ensure git is installed if needed for later steps

# Example: Install a specific Python version (if not handled by another feature)
# This is a simplified example; using a dedicated Python feature is often better.
if [ "${PYTHON_VERSION}" != "default" ] && [ "${PYTHON_VERSION}" != "none" ]; then
    echo "Installing Python ${PYTHON_VERSION}..."
    # Add commands to install Python (e.g., using deadsnakes PPA or pyenv)
    # apt-get install -y software-properties-common
    # add-apt-repository ppa:deadsnakes/ppa -y
    # apt-get update -y
    # apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-pip python3-is-python${PYTHON_VERSION:0:1}
    echo "WARNING: Python installation example is basic. Consider using the official Python feature."
fi

# Example: Install Node.js (using NodeSource)
# echo "Installing Node.js..."
# curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
# apt-get install -y nodejs

# Example: Install specific Python packages
# echo "Installing Python packages..."
# pip install --upgrade pip
# pip install black flake8 mypy # Add your roocode Python dependencies

# Example: Configure Git
if [ "${INSTALL_GIT_ALIAS}" = "true" ]; then
    echo "Configuring Git aliases..."
    # Add commands to setup git aliases globally or for the vscode user later
    # git config --global alias.co checkout
    # git config --global alias.br branch
    # git config --global alias.st status
    # Note: Running as root here. Consider setting for the non-root user if applicable.
fi

# Example: Clone a configuration repository
# echo "Cloning configuration repository..."
# git clone https://github.com/your-org/your-roocode-configs.git /opt/roocode-configs
# chown -R _REMOTE_USER:_REMOTE_USER /opt/roocode-configs # Change ownership if needed

# Example: Copy configuration files (assuming you add them to your feature's directory)
# mkdir -p /etc/roocode
# cp ./path/to/your/config/file /etc/roocode/config.yaml

# --- CLEANUP ---
echo "Cleaning up apt caches..."
rm -rf /var/lib/apt/lists/*

echo "Roocode feature installation completed."