#!/usr/bin/env bash

# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.

#/ -------------------------------------------------
#/ Description:  ...
#/ How to:       generator.sh
#/                                      -- gen, with default template to stdout
#/               generator.sh <filename[.ext]>...
#/                                      -- gen, with default template to file(s)
#/               generator.sh [<filename[.ext]>...] [-t|--type <name>] [...]
#/                                      -- gen, with input variable and option
#/ Options:      --help | -h
#/                      -- help command
#/               --version | -v
#/                      -- get version
#/               --type | -t <script type>
#/                      -- input type name, specify by folder in 'res' folder
#/                      -- link: https://github.com/Template-generator/script-genrating/tree/master/res
#/               --shell | -s <shell name>
#/                      -- use with type 'shell'
#/               --package | -p <package name>
#/                      -- use with type 'go'
#/ Create by:    Kamontat Chantrachirathumrong
#/ Since:        18 / 04 / 2018
#/ -------------------------------------------------
#/ Version:      0.0.1  -- Add option
#/               1.0.0  -- Completed first version
#/               1.1.0  -- Improvement and enhancement, also Fix
#/               2.0.0  -- Easier to install, uninstall, reinstall
#/               2.0.1  -- fix create error, and version error
#/               2.0.2  -- fix help and version error, update documents
#/               2.1.0  -- Add more features to shell res
#/               2.1.1  -- fix a lot of decode problem
#/               2.2.0  -- add app version
#/ -------------------------------------------------
#/ Error code    1      -- error
#/               2      -- location not found
#/               3      -- variable not exist
#/               5      -- require value not exist
#/               10     -- option and argument missing
#/ -------------------------------------------------

ORIGINAL="$PWD"

# handle symlink
real="$0"
[ -h "$real" ] && real="$(readlink "$real")"
cd "$(dirname "$real")" || exit 1

help() {
	cat "generator.sh" | grep "^#/" | sed "s/#\/ //g"
}

version() {
	echo "2.2.0"
}

# -------------------------------------------------
# Constants
# -------------------------------------------------

test -z "$DEFAULT" && export DEFAULT="shell"
test -z "$SUB_DEFAULT" && export SUB_DEFAULT="bash"

GENERATE_STR=""
REQUIRE=""

# -------------------------------------------------
# Functions
# -------------------------------------------------

# |-------------------------------------------------|
# |  Helper                                         |
# |-------------------------------------------------|

to_lower_case() {
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

to_upper_case() {
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

is_integer() {
	[[ $1 =~ ^[0-9]+$ ]] 2>/dev/null && return 0 || return 1
}

throw() {
	printf '%s\n' "$1" >&2 && is_integer "$2" && exit "$2"
	return 0
}

throw_if_empty() {
	# shellcheck disable=SC2015
	[ -n "$1" ] && return 0 || throw "$2" "$3"
}

setup() {
	name="$1"
	value="$2"
	export "$name"="$value"
}

get_variable_name() {
	local regex=".*\$\${\([^{}]*\)}.*"
	content="$1"

	grep -q $regex <<<"$content" || return 1
	echo "$content" | tr -d "\n" | sed "s/$regex/\1/g"
}

replace_filename() {
	local filename="$1" all="$2"
	test -n "$filename" &&
		file_name="$filename" &&
		export RESULT=$(sed "s/\${file_name}/$file_name/g" <<<"$all")

	export file_name
}

# |-------------------------------------------------|
# |  Printer                                        |
# |-------------------------------------------------|

_print() {
	header="$1"
	message="$2"

	printf "%10s: %s" "$header" "$message"
}

print_replace() {
	name="$1"
	str="$(printf "Replace %-15s file [Y|n]?" "$name")"

	_print "warning" "$str"
}

print_add() {
	header="$1"
	name="$2"

	str="$(printf "Add %-16s section [Y|n]?" "$name")"

	_print "$header" "$str"
}

end_print() {
	lr="$(to_lower_case "$1")"

	[[ $lr == "a" ]] ||
		[[ $lr == "ad" ]] ||
		[[ $lr == "add" ]] ||
		[[ $lr == "0" ]] &&
		printf "\e[u-- ADD!\e[10C\n"

	[[ $lr == "n" ]] ||
		[[ $lr == "no" ]] ||
		[[ $lr == "not" ]] ||
		[[ $lr == "none" ]] ||
		[[ $lr == "1" ]] &&
		printf "\e[u-- NONE!!\e[10C\n"

	[[ $lr == "e" ]] ||
		[[ $lr == "er" ]] ||
		[[ $lr == "err" ]] ||
		[[ $lr == "error" ]] ||
		[[ $lr == "-1" ]] &&
		printf "\e[u-- ERROR!!!\e[10C\n"
}

# |-------------------------------------------------|
# |  User interactive                               |
# |-------------------------------------------------|

confirm() {
	printf "  "
	local ans
	read -rn 1 ans
	printf "  \e[s"
	[[ $(to_lower_case "$ans") == "y" ]]
}

prompt() {
	local name="$1" ans

	printf "Enter %s?: " "$name"
	read -r ans

	export RESULT="$ans"
}

# |-------------------------------------------------|
# |  Option APIs                                    |
# |-------------------------------------------------|

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

# |-------------------------------------------------|
# |  Script APIs                                    |
# |-------------------------------------------------|

load_argument() {
	local files options=()
	for i in "$@"; do
		if [[ $i =~ "-" ]]; then
			# options+=("$i")
			break
		else
			files+=("$i")
			shift
		fi
	done

	test -z "$FILES" && export FILES=("${files[@]}")
	test -z "$OPTIONS" && export OPTIONS=("$@")
}

load_option() {
	while getopts 'DdHhVvIiUuRrS:s:P:p:T:t:-:' flag; do
		case "${flag}" in
		D) set -x ;;
		d) set -x ;;
		H) help && exit 0 ;;
		h) help && exit 0 ;;
		V) version && exit 0 ;;
		v) version && exit 0 ;;
		s) shell_name="$OPTARG" ;;
		S) shell_name="$OPTARG" ;;
		p) package_name="$OPTARG" ;;
		P) package_name="$OPTARG" ;;
		t) DEFAULT="$OPTARG" ;;
		T) DEFAULT="$OPTARG" ;;
		i) "./install.sh" && exit 0 ;;
		I) "./install.sh" && exit 0 ;;
		u) "./uninstall.sh" && exit 0 ;;
		U) "./uninstall.sh" && exit 0 ;;
		r) "./reinstall.sh" && exit 0 ;;
		R) "./reinstall.sh" && exit 0 ;;
		-)
			export LONG_OPTARG
			export LONG_OPTVAL
			NEXT="${!OPTIND}"
			set_key_value_long_option "$NEXT"
			case "${OPTARG}" in
			debug)
				no_argument
				set -x
				;;
			help)
				no_argument
				help
				exit 0
				;;
			version)
				no_argument
				version
				exit 0
				;;
			shell*)
				require_argument
				shell_name="$LONG_OPTVAL"
				;;
			type*)
				require_argument
				DEFAULT="$LONG_OPTVAL"
				;;
			package*)
				require_argument
				package_name="$LONG_OPTVAL"
				;;
			install)
				no_argument
				"./install.sh" && exit 0
				;;
			uninstall)
				no_argument
				"./uninstall.sh" && exit 0
				;;
			reinstall)
				no_argument
				"./reinstall.sh" && exit 0
				;;
			*)
				# because optspec is assigned by 'getopts' command
				# shellcheck disable=SC2154
				if [ "$OPTERR" == 1 ] && [ "${optspec:0:1}" != ":" ]; then
					echo "Unexpected option '$LONG_OPTARG', run --help for more information" >&2
					exit 9
				fi
				;;
			esac
			;;
		?)
			echo "Unexpected option, run --help for more information" >&2
			exit 10
			;;
		*)
			echo "Unexpected option $flag, run --help for more information" >&2
			exit 10
			;;
		esac
	done
}

load_res() {
	location="${PWD}/res/$DEFAULT"
	run_script="${location}/run.sh"

	! test -d "$location" && throw "$DEFAULT not found on location ($location)" 2
	! test -f "$run_script" && throw "$run_script not found on location"
	test -f "$run_script" &&
		source "$run_script"
	# setup "file_name" "generator.sh" &&
	# if ! error=$(required); then
	# 	throw "'$error' variable not exist" 3
	# fi

	for file in ${location}/*; do
		grep -q "[^0-9]\.sh" <<<"$file" && continue

		number=${file%%.*}
		number=${number//$location\//}

		name=${file##*.}
		name="$(to_upper_case "$name")"
		print_add "$number" "$name"
		if ! confirm; then
			end_print "not"
			continue
		fi
		content="$(cat "$file")"
		if variable="$(get_variable_name "$content")"; then
			if ! [[ $variable == "file_name" ]]; then

				replace="${!variable}"
				if test -z "${!variable}" &&
					prompt "$variable"; then
					eval "export ${variable}=$RESULT" &&
						replace="$RESULT"
				fi

				content=$(sed "s/\$\${$variable}/$replace/g" <<<"$content")
			else
				REQUIRE="file_name,$REQUIRE"
			fi
		fi

		# echo "-------- $variable --------"
		GENERATE_STR="${GENERATE_STR}${content}\n"
		end_print "add"
	done
}

# -------------------------------------------------
# App logic
# -------------------------------------------------

app_version="$(version)"

load_argument "$@"

load_option "${OPTIONS[@]}"

if ! load_res; then
	throw "cannot load resource" 1
fi

# stdout
if [ ${#FILES} -eq 0 ]; then
	# prompt
	[[ "$REQUIRE" =~ "file_name" ]] &&
		prompt "file_name" &&
		eval "export ${variable}=$RESULT" &&
		replace="$RESULT"
	# replace
	replace_filename "$replace" "$GENERATE_STR"

	echo "---------- OUTPUT ----------"

	# check
	if ! error=$(required); then
		throw "${error} not exist!" 5
	fi
	# output
	printf "${RESULT}\n"
	# file
else
	for file in "${FILES[@]}"; do
		replace_filename "$file" "$GENERATE_STR"

		echo "---------- OUTPUT ----------"

		if ! error=$(required); then
			throw "${error} not exist!" 5
		fi

		if test -f "${file}"; then
			print_replace "$file"
			if ! confirm; then
				end_print "not"
				continue
			fi
			end_print "add"
		fi

		printf "${RESULT}\n" >"${ORIGINAL}/${file}"
		cd "${ORIGINAL}" || exit 1
		after "$file"
	done
fi
