#!/usr/bin/env bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

./shellcheck-stable/shellcheck prereq-check-dev.sh
./shellcheck-stable/shellcheck build.sh
./shellcheck-stable/shellcheck lib/info.sh
./shellcheck-stable/shellcheck lib/utils.sh
./shellcheck-stable/shellcheck lib/checks.sh
./shellcheck-stable/shellcheck lib/security/security-checks.sh
