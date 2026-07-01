#!/bin/sh
set -eu

bin_dir="${1:-/usr/bin}"
expect_nodejs="${NODE_VIA_BUN_EXPECT_NODEJS:-1}"

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

assert_version() {
	version="$1"
	label="$2"

	case "${version}" in
	v*.*.*) ;;
	*)
		printf '%s\n' "${label}: expected Node-style version, got '${version}'" >&2
		exit 1
		;;
	esac
}

node_version="$("${bin_dir}/node" --print process.version)"
assert_version "${node_version}" 'node --print process.version'

node_names='node'
if [ "${expect_nodejs}" != 0 ]; then
	node_names="${node_names} nodejs"
fi

for name in ${node_names}; do
	for flag in --version -v; do
		assert_equal "${node_version}" "$("${bin_dir}/${name}" "${flag}")" "${name} ${flag}"
	done
done

npm_version='99.88.77'
release_index_url='data:application/json,[{"version":"'"${node_version}"'","npm":"'"${npm_version}"'"}]'

for name in npm npx; do
	assert_equal "${npm_version}" \
		"$(NODE_RELEASE_INDEX_URL="${release_index_url}" "${bin_dir}/${name}" --version)" \
		"${name} --version"
done
