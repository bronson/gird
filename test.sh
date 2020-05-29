#!/bin/bash

# Run this script with no arguments.
# If it exits with no errors then gird works.

# 1. Run a simple test on a directory hierarchy
./gird test-tree
if [ -n "$(git status -s test-tree)" ]; then
    echo 'Test Failure:'
    git status -s test-tree
    exit 1
fi
