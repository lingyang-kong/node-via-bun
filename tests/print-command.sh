#!/bin/sh
set -eu

label="$1"
shift

printf '%s' "$label"
for arg in "$@"; do
	printf ' %s' "$arg"
done
printf '\n'
