#!/bin/sh
set -eu

npm_version_path="${NODE_VIA_BUN_TEST_NPM_VERSION_PATH:?NODE_VIA_BUN_TEST_NPM_VERSION_PATH must be set}"
script_dir="$(CDPATH='' cd "$(dirname "$0")" && pwd)"

case "${1:-}" in
--print)
	if [ "${2:-}" = "process.version" ]; then
		echo "v99.0.0"
		exit 0
	fi
	;;
"$npm_version_path")
	echo "99.88.77"
	exit 0
	;;
esac

"$script_dir/print-command.sh" bun "$@"
