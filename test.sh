#!/bin/bash

# Run this script with no arguments.
# If it exits with no errors then gird works.

./gird test
if [ -n "$(git status -s test-tree)" ]; then
    echo 'Test Failure:'
