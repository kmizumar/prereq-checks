#!/usr/bin/env bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

TESTDIR="$(cd "$(dirname "{BASH_SOURCE[0]}")" && pwd)"

./check_selinux.sh
