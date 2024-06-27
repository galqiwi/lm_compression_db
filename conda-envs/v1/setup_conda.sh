#!/bin/bash

set -euo pipefail

MINICONDA_INIT_FILE=Miniconda3-py310_24.4.0-0-Linux-x86_64.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

if test -d ./miniconda; then
  echo "./miniconda already exists, exiting"
  exit 0
fi

wget -q https://repo.anaconda.com/miniconda/"$MINICONDA_INIT_FILE"
sha256sum "$MINICONDA_INIT_FILE" > miniconda.sha256sum
chmod +x "$MINICONDA_INIT_FILE"

set +euo pipefail
./"$MINICONDA_INIT_FILE" -b -f -p ./miniconda
set -euo pipefail
