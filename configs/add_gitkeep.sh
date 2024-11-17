#!/bin/bash

# Find all empty directories and add .gitkeep files to them
find . -type d -empty -not -path "*/\.*" -exec touch {}/.gitkeep \;

echo "Added .gitkeep files to all empty directories!" 