#!/bin/bash
set -e

# Check if the directory exists
if ! test -d /home/node/.config/roocode; then
  echo "Error: /home/node/.config/roocode directory does not exist"
  exit 1
fi

# Check if the file exists
if ! test -f /home/node/.config/roocode/.roomodes; then
  echo "Error: /home/node/.config/roocode/.roomodes file does not exist"
  exit 1
fi

# Check if the file is not empty
if ! test -s /home/node/.config/roocode/.roomodes; then
  echo "Error: /home/node/.config/roocode/.roomodes file is empty"
  exit 1
fi

echo "/home/node/.config/roocode/.roomodes checks passed"