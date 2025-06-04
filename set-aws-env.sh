#!/usr/bin/env bash
# Load environment variables from .env file

if [ -f .env ]; then
    set -a  # automatically export all variables
    source .env
    set +a
else
    echo "Error: .env file not found. Copy .env.example to .env and configure your settings."
    exit 1
fi
