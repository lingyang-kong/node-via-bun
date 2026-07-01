#!/bin/sh
set -eu

script_dir="$(CDPATH='' cd "$(dirname "$0")" && pwd)"

"$script_dir/print-command.sh" bunx "$@"
