#!/usr/bin/env bash
set -euo pipefail

# Backwards-compatible entry point. New and existing machines use the same
# staged installer; see bin/bootstrap --help for the available safe modes.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin/bootstrap" "$@"
