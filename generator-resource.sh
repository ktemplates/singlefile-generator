#!/usr/bin/env bash
# shellcheck disable=SC1000

# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.

#/ -----------------------------------
#/ Usage
#/ generator-resource header <name>
#/       -- generate header
#/ generator-resource subheader <header> <name>
#/       -- generate subheader
#/ -----------------------------------
#/ Create by:    Kamontat Chantrachirathumrong <>kamontat.c@hotmail.com>
#/ Since:        dd/MM/YYYY
#/ -----------------------------------

# handle symlink
real="$0"
[ -h "$real" ] && real="$(readlink "$real")"
cd "$(dirname "$real")" || exit 1

DEFAULT_RESOURCE_FILE="res"
DEFAULT_RESOURCE_LOCATION="${PWD}/${DEFAULT_RESOURCE_FILE}"

if [[ $1 == "header" ]] || [[ $1 == "h" ]]; then
	test -z "$2" && echo "require 1 parameter, header name" && exit 2
	head="${DEFAULT_RESOURCE_LOCATION}/$2"
	mkdir "$head" &&
		cp "${DEFAULT_RESOURCE_LOCATION}/_" "${head}/start.sh" &&
		chmod +x "${head}/start.sh"
elif [[ $1 == "subheader" ]] || [[ $1 == "s" ]]; then
	test -z "$2" && echo "require 2 parameter, header name and subheader name" && exit 2
	test -z "$3" && echo "require 2 parameter, subheader name" && exit 2

	head="${DEFAULT_RESOURCE_LOCATION}/$2"
	mkdir -p "$head" &>/dev/null &&
		cp "${DEFAULT_RESOURCE_LOCATION}/_" "${head}/start.sh" &&
		chmod +x "${head}/start.sh"

	size="$(ls -1q "$head" | wc -l | tr -d " ")"
	dir="${head}/${size}.${3}"
	mkdir -p "$dir"
	cd "$dir" || exit 1
	touch res desc
else
	echo "error"
fi
