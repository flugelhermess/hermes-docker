#!/bin/bash
if [ "$1" = "Username" ]; then
    echo "flugelhermess"
elif [ "$1" = "Password" ]; then
    echo "${GITHUB_TOKEN}"
fi
