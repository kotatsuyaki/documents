#!/bin/sh
#
# Usage:
# 
#     ./scripts/build.sh \
#                        ./src/references/main.md \
#                        ./build/references-fancy.pdf \
#                        ./defaults/pdf-fancy.yml \
#                        ./src/references

mkdir -p $4

# Prepend per-document defaults before global defaults
if [[ -f "$4/defaults.yml" ]]; then
    LOCAL_DEFAULTS="--defaults=$4/defaults.yml"
fi

# Create output dir (https://unix.stackexchange.com/a/351917)
mkdir -p "${2%/*}"

pandoc "$1" \
    --output="$2" \
    $LOCAL_DEFAULTS --defaults="$3" \
    --resource-path="$4"
