#!/usr/bin/env bash
# shellcheck disable=SC1000,SC1090

# generate by generator version: 2.3.3
# link (https://github.com/Template-generator/create-script-file/tree/2.3.3)

# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.

#/ -----------------------------------
#/ Usage
#/ generator [<type>] [with-help]
#/       -- generate to stdout, [with help]
#/ generator [<type>] <file_name|path|absolute_path> [with-help]
#/       -- generate to file, [with help]
#/ generator [<type>] help
#/       -- show command help or type help
#/ generator version
#/       -- show command version
#/ generator list
#/       -- list all resource type available
#/ -----------------------------------
#/ Create by:    Kamontat Chantrachirathumrong <>kamontat.c@hotmail.com>
#/ Since:        21/05/2018
#/ -----------------------------------
#/ Error code    1      -- error
#/ -----------------------------------

# generator version
export GENERATOR_VERSION="v4.0.0"
export app_version="$GENERATOR_VERSION" # for resource file

to_script_location() {
	local original="${PWD}"
	# handle symlink
	real="$0"
	[ -h "$real" ] && real="$(readlink "$real")"
	cd "$(dirname "$real")" && pwd || exit 1
	cd "$original" || exit 1
}

SCRIPT_LOCATION="$(to_script_location)"
export SCRIPT_LOCATION

DEFAULT_TYPE="shell"
DEFAULT_RESOURCE_FILE="res"

DEFAULT_RESOURCE_LOCATION="${SCRIPT_LOCATION}/${DEFAULT_RESOURCE_FILE}"

export DEFAULT_GENERATOR_TMP_FILE="/tmp/generator.temp"
export DEFAULT_GENERATOR_TMP1_FILE="/tmp/generator.1.temp"

help() {
	grep "^#/ " "${SCRIPT_LOCATION}/generator.sh" | sed 's/#\/ //g'
}

version() {
	echo "generator version: $GENERATOR_VERSION"
}

list() {
	find "$DEFAULT_RESOURCE_LOCATION" -type d -depth 1 | sed "s,${DEFAULT_RESOURCE_LOCATION}/,,g"
}

reinstall() {
	bash "${SCRIPT_LOCATION}/reinstall.sh"
}

uninstall() {
	bash "${SCRIPT_LOCATION}/uninstall.sh"
}

get_absolute_filename() {
	local seperator="/"
	local curr rel_filename basename absolute_dir f s l
	curr="$PWD"
	# $1 : relative filename
	rel_filename="$1"
	f="${rel_filename:0:1}"                  # first char
	s="${rel_filename:1:1}"                  # second char
	l="${rel_filename:${#rel_filename}-1:1}" # last char

	# handle if input have / in the last char, REMOVE IT!
	[[ $l == "/" ]] &&
		rel_filename="${rel_filename:0:${#rel_filename}-1}"
	# handle input is already absolute path
	[[ $f == "/" ]] &&
		echo "$rel_filename" &&
		return 0
	[[ $f == "." ]] && [[ $s == "/" ]] &&
		rel_filename="${rel_filename:2:${#rel_filename}}"

	# relative directory
	dir="$(dirname "$rel_filename")"
	mkdir -p "$dir" &>/dev/null
	# filename
	basename="$(basename "${rel_filename[*]}")"
	test -z "$basename" && seperator=""
	# absolute directory path
	absolute_dir="$(cd "$dir" && pwd)"
	# mere together
	echo "${absolute_dir}${seperator}${basename}"
	cd "$curr" || return 1
}

throw() {
	printf '%s\n' "$1" >&2 && is_integer "$2" && exit "$2"
	return 0
}

throw_if_empty() {
	local text="$1"
	test -z "$text" && throw "$2" "$3"
	return 0
}

# @option
require_argument() {
	throw_if_empty "$LONG_OPTVAL" "'$LONG_OPTARG' require argument" 9
}

# @option
no_argument() {
	[[ -n $LONG_OPTVAL ]] && ! [[ $LONG_OPTVAL =~ "-" ]] && throw "$LONG_OPTARG don't have argument" 9
	OPTIND=$((OPTIND - 1))
}

# @syscall
set_key_value_long_option() {
	if [[ $OPTARG =~ "=" ]]; then
		LONG_OPTVAL="${OPTARG#*=}"
		LONG_OPTARG="${OPTARG%=$LONG_OPTVAL}"
	else
		LONG_OPTARG="$OPTARG"
		LONG_OPTVAL="$1"
		OPTIND=$((OPTIND + 1))
	fi
}

load_option() {
	echo "$@"
	while getopts 'a-:' flag; do
		case "${flag}" in
		-)
			export LONG_OPTARG
			export LONG_OPTVAL
			NEXT="${!OPTIND}"
			set_key_value_long_option "$NEXT"
			require_argument
			eval "export ${LONG_OPTARG}=\"$LONG_OPTVAL\""
			;;
		esac
	done
}

# for option with argument only
only_option() {
	arr=()
	local f t=false
	for opt in "$@"; do
		f="${opt:0:1}" # first char
		! $t &&
			[[ $f == "-" ]] &&
			arr+=("$opt") &&
			t=true && continue

		$t && arr+=("$opt") && t=false
	done

	export ONLY_OPTION=("${arr[@]}")
}

load_type() {
	[[ $1 == "" ]] &&
		printf "empty" && return 1

	local location="$DEFAULT_RESOURCE_LOCATION"

	! test -d "$location" && throw "$location not found" 2

	for full_folder in ${location}/*; do
		folder="${full_folder##*/}"
		[[ "$1" == "$folder" ]] && echo "$folder" && return 0
	done

	printf "empty"
	return 1
}

load_env() {
	local env="${SCRIPT_LOCATION}/.generator.env"
	test -f "$env" &&
		source "$env" ||
		return 0
}

[[ "$1" == "help" ]] ||
	[[ "$1" == "h" ]] ||
	[[ "$1" == "--help" ]] ||
	[[ "$1" == "-h" ]] ||
	[[ "$1" == "?" ]] &&
	help && exit 0

[[ "$1" == "version" ]] ||
	[[ "$1" == "v" ]] ||
	[[ "$1" == "--version" ]] ||
	[[ "$1" == "-v" ]] &&
	version && exit 0

[[ "$1" == "list" ]] ||
	[[ "$1" == "l" ]] ||
	[[ "$1" == "--list" ]] ||
	[[ "$1" == "-l" ]] &&
	list && exit 0

[[ "$1" == "reinstall" ]] ||
	[[ "$1" == "R" ]] ||
	[[ "$1" == "--reinstall" ]] ||
	[[ "$1" == "-R" ]] &&
	reinstall && exit 0

[[ "$1" == "uninstall" ]] ||
	[[ "$1" == "U" ]] ||
	[[ "$1" == "--uninstall" ]] ||
	[[ "$1" == "-U" ]] &&
	reinstall && exit 0

TYPE="$(load_type "$1")" || file="$1"
[[ $TYPE == "empty" ]] &&
	TYPE="$DEFAULT_TYPE"

test -n "$2" && file="$2"
[[ ${file:0:1} == "-" ]] && file=""
[[ $file == "help" ]] ||
	[[ $file == "h" ]] ||
	[[ $file == "?" ]] ||
	[[ $file == "with-help" ]] ||
	[[ $file == "wh" ]] &&
	file=""

ABSOLUTE_FILE="$(get_absolute_filename "$file")"

[[ "$ABSOLUTE_FILE" == "${PWD}" ]] &&
	ABSOLUTE_FILE=""

IS_HELP=false
[[ $2 == "help" ]] ||
	[[ $2 == "h" ]] ||
	[[ $2 == "?" ]] &&
	IS_HELP=true &&
	ABSOLUTE_FILE=""

# FIXME: change way to decoder with-help
WITH_HELP=false
[[ $1 == "with-help" ]] ||
	[[ $1 == "wh" ]] ||
	[[ $2 == "with-help" ]] ||
	[[ $2 == "wh" ]] ||
	[[ $3 == "with-help" ]] ||
	[[ $3 == "wh" ]] &&
	WITH_HELP=true

# list variable in input file
# _{name}_ => name
# parameter
# 1 - file_name
# return
# export 'VARIABLE_ARRAY' variable as array
get_variable() {
	unset VARIABLE_ARRAY
	local regex='.*\_{\([^{}]*\)}\_.*'
	local file="$1" variable_array=()
	grep -q $regex $file || return 1

	while read -r line; do
		result="$(echo "$line" | sed "s/$regex/\1/g")"
		[[ "$result" != "$line" ]] &&
			! [[ "${variable_array[*]}" =~ "$result" ]] &&
			variable_array+=("$result")
	done <"$file"

	export VARIABLE_ARRAY="${variable_array[*]}"
}

is_value_exist() {
	test -n "$1"
}

replace_variable() {
	local variable_name="$1" value="$2" file="$3" result

	# echo "--------------------------------"
	# echo "$variable_name"
	# echo "$value"
	# echo "$file"
	# echo "--------------------------------"

	# exist and size greater than 0
	test -s "$DEFAULT_GENERATOR_TMP_FILE" && file="$DEFAULT_GENERATOR_TMP_FILE"
	! test -f "$DEFAULT_GENERATOR_TMP_FILE" && touch "$DEFAULT_GENERATOR_TMP_FILE"

	test -z "$variable_name" ||
		test -z "$value" ||
		! test -f "$file" &&
		return 1

	# avoid content missing
	result="$(sed "s,_{$variable_name}_,${value},g" "$file")"
	# echo "$result"
	echo "$result" >"$DEFAULT_GENERATOR_TMP_FILE"
}

show_content() {
	test -s "$DEFAULT_GENERATOR_TMP1_FILE" &&
		cat "$DEFAULT_GENERATOR_TMP1_FILE"

	[[ $1 != false ]] && reset_content

	return 0
}

reset_content() {
	test -f "$DEFAULT_GENERATOR_TMP_FILE" &&
		rm -r "$DEFAULT_GENERATOR_TMP_FILE"
	test -f "$DEFAULT_GENERATOR_TMP1_FILE" &&
		rm -r "$DEFAULT_GENERATOR_TMP1_FILE"
}

is_wanted() {
	local folder="$1"
	[[ $WITH_HELP == true ]] && cat "${folder}/desc"
	printf "Loading.. %-10s [Y|n]: " "${folder##*/}"
	read -rn 1 ans
	echo
	[[ $ans == "Y" ]] ||
		[[ $ans == "y" ]]
}

prompt() {
	local var="$1" ans
	printf "Enter %-10s: " "$var"
	read -r ans

	export $var="$ans"
}

generator_one_file() {
	local arr file="$1" result_file
	get_variable "${file}"
	IFS=' ' read -r -a arr <<<"$VARIABLE_ARRAY"

	for var in "${arr[@]}"; do
		value="$(eval "echo \$$var")"
		# printf 'value of %-13s: %s\n' "$var" "$value"
		! is_value_exist "$value" &&
			prompt "$var"

		# update new value
		value="$(eval "echo \$$var")"

		replace_variable "$var" "$value" "${file}"
	done

	result_file=""

	if ((${#arr[@]} == 0)); then
		result_file="$file"
	else
		result_file="$DEFAULT_GENERATOR_TMP_FILE"
	fi

	cat "$result_file" >>"$DEFAULT_GENERATOR_TMP1_FILE"
	echo >>"$DEFAULT_GENERATOR_TMP1_FILE"

	test -f "$DEFAULT_GENERATOR_TMP_FILE" &&
		rm -r "$DEFAULT_GENERATOR_TMP_FILE"
}

loop_generate() {
	for folder in $RESOURCE_REGEX; do
		! is_wanted "${folder}" && continue
		generator_one_file "${folder}/res"
		echo "-----------------"
	done
}

loop_variable() {
	local arr res desc
	for folder in $RESOURCE_REGEX; do
		res="${folder}/res"
		desc="${folder}/desc"
		get_variable "${res}"
		IFS=' ' read -r -a arr <<<"$VARIABLE_ARRAY"

		echo "#   ${folder##*/}"
		cat "$desc"
		((${#arr[@]} > 0)) && echo "Variable(s): "
		for var in "${arr[@]}"; do
			echo ">>  $var"
		done
		echo "--------------"
		echo
	done
}

get_result() {
	if test -n "$ABSOLUTE_FILE"; then
		show_content >"$ABSOLUTE_FILE"
	else
		show_content
	fi
}

pass_thought() {
	local res_file="$1"

	for script in $(find $res_file -iname "*.sh"); do
		bash "$script"
	done
}

export TYPE
export RESOURCE_LOCATION="$DEFAULT_RESOURCE_LOCATION/$TYPE"
export RESOURCE_REGEX="${RESOURCE_LOCATION}/[0-9]*"
export RESOURCE_
export ABSOLUTE_FILE
export FILENAME="${ABSOLUTE_FILE##*/}"
export file_name="$FILENAME" # for resource file
export filename="$FILENAME"  # for resource file
export IS_HELP
export WITH_HELP

export -f is_value_exist
export -f get_variable
export -f replace_variable
export -f show_content
export -f reset_content
export -f prompt
export -f is_wanted

export -f generator_one_file

export -f loop_variable
export -f loop_generate
export -f get_result

# echo "-------------"
# echo "type: $TYPE"
# echo "loca: $RESOURCE_LOCATION"
# echo "file: $ABSOLUTE_FILE"
# echo "name: $FILENAME"
# echo "help: $IS_HELP"
# echo "with: $WITH_HELP"
# echo "-------------"
# echo

reset_content

load_env
only_option "$@"
load_option "${ONLY_OPTION[@]}"
pass_thought "$RESOURCE_LOCATION"

exit 0
