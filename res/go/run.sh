#!/usr/bin/env bash
# shellcheck disable=SC2154

required() {
	error=""
	test -z "$package_name" && error="package name, $error"

	test -n "$error" && echo "$error" && return 1

	return 0
}

export -f required
