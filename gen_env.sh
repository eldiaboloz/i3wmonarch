#!/usr/bin/env bash

set -e

cat ./uefi_and_hybrid_mbr.sh | grep -P '^\s*:' | perl -pe 's/^\s*: \$\{([^=:]+):*=([^}]+)}/\1=\2/g'

