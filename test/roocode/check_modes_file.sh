#!/bin/bash
# check_modes_file.sh - Test script to verify .roomodes file existence and content

set -e

# Variables
MODES_DIR="/home/node/.config/roocode"
MODES_FILE="${MODES_DIR}/.roomodes"

# Check if directory exists
if ! test -d "${MODES_DIR}"; then
  echo "Error: Modes directory '${MODES_DIR}' does not exist." >&2
  exit 1
fi
echo "Directory '${MODES_DIR}' exists."

# Check if file exists
if ! test -f "${MODES_FILE}"; then
  echo "Error: Modes file '${MODES_FILE}' does not exist." >&2
  exit 1
fi
echo "File '${MODES_FILE}' exists."

# Check if file is not empty
if ! test -s "${MODES_FILE}"; then
  echo "Error: Modes file '${MODES_FILE}' is empty." >&2
  exit 1
fi
echo "File '${MODES_FILE}' is not empty."

echo "Success: Modes file check passed."
exit 0