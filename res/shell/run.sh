#!/usr/bin/env bash
# shellcheck disable=SC2154

required() {
	error=""
	test -z "$shell_name" && error="shell name, $error"

	test -n "$error" && echo "$error" && return 1

	return 0
}

after() {
	result="$1"
	chmod +x "$result"
}

export -f required
export -f after
