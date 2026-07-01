#!/bin/sh
set -eu

root="$(CDPATH= cd "$(dirname "$0")/.." && pwd)"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/node-via-bun-test.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT HUP INT TERM

fake_bun="${root}/scripts/test-fake-bun.sh"
fake_bunx="${root}/scripts/test-fake-bunx.sh"
npm_version_script="${tmp_dir}/npm-version.js"
multicall="${tmp_dir}/node-via-bun"

export NODE_VIA_BUN_TEST_NPM_VERSION_PATH="${npm_version_script}"

# shellcheck disable=SC2046
"${CC:-cc}" $(sed '/^[[:space:]]*$/d' "${root}/src/cflags.txt") \
	-DBUN_PATH="\"${fake_bun}\"" \
	-DBUNX_PATH="\"${fake_bunx}\"" \
	-DNPM_VERSION_PATH="\"${npm_version_script}\"" \
	"${root}/src/node-via-bun.c" -o "${multicall}"

for name in node nodejs npm npx; do
	ln "${multicall}" "${tmp_dir}/${name}"
done

assert_equal() {
	expected="$1"
	actual="$2"
	label="$3"

	if [ "${actual}" = "${expected}" ]; then
		return 0
	fi

	printf '%s\n' "${label}: expected '${expected}', got '${actual}'" >&2
	exit 1
}

while IFS='|' read -r expected command label; do
	label="${label:-${command}}"

	actual="$(PATH="${tmp_dir}${PATH:+:${PATH}}" sh -c "${command}")"

	assert_equal "${expected}" "${actual}" "${label}"
done <<-'EOF'
	v99.0.0|node --version
	v99.0.0|node -v
	v99.0.0|nodejs --version
	99.88.77|npm --version
	99.88.77|npx --version
	bun install left-pad|npm install left-pad|npm passthrough
	bunx cowsay hello|npx cowsay hello|npx passthrough
EOF

if "${multicall}" 2>"${tmp_dir}/unknown.err"; then
	printf '%s\n' 'unknown applet: expected failure' >&2
	exit 1
fi

assert_equal 'node-via-bun: unknown applet' "$(cat "${tmp_dir}/unknown.err")" 'unknown applet'
