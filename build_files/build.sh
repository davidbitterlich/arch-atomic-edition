#!/bin/bash
set -ouex pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "::group::Executing basic stuff"
trap 'echo "::endgroup::"' EXIT

