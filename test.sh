#!/usr/bin/env xyz
# shellcheck disable=SC1000

# generate by 2.3.0
# link (https://github.com/Template-generator/script-genrating/tree/2.3.0)

# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.

#/ -----------------------------------
#/ Description:  ...
#/ How to:       ...
#/               ...
#/ Option:       --help | -h | -? | help | h | ?
#/                   > show this message
#/               --version | -v | version | v
#/                   > show command version
#/ -----------------------------------
#/ Create by:    NAME SURNAME <EMAIL>
#/ Since:        dd/MM/YYYY
#/ -----------------------------------
#/ Version:      0.0.1   -- description
#/               0.0.2b1 -- beta-format
#/               0.0.2a1 -- alpha-format
#/ -----------------------------------
#/ Error code    1      -- error
#/ -----------------------------------
#/ Bug:          ...
#/ -----------------------------------

# move current folder to same as shell folder
cd "$(dirname "$0")" || exit 1
# cd "$(dirname "$(realpath "$0")")" || exit 1

help() {
  grep "^#/" "test.sh" | sed 's/#\/ //g'
}

# [[ "$1" == "--help" ]] ||
#   [[ "$1" == "-h" ]] ||
#   [[ "$1" == "-?" ]] ||
#   [[ "$1" == "help" ]] ||
#   [[ "$1" == "h" ]] ||
#   [[ "$1" == "?" ]] &&
#   help

version() {
  echo "test.sh version: 0.0.1"
}


# [[ "$1" == "--version" ]] ||
#   [[ "$1" == "-v" ]] ||
#   [[ "$1" == "version" ]] ||
#   [[ "$1" == "v" ]] &&
#   version

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
	while getopts 'Hh?Vv-:' flag; do
		case "${flag}" in
		H) help && exit 0 ;;
		h) help && exit 0 ;;
		?) help && exit 0 ;;
		V) version && exit 0 ;;
		v) version && exit 0 ;;
		-)
			export LONG_OPTARG
			export LONG_OPTVAL
			NEXT="${!OPTIND}"
			set_key_value_long_option "$NEXT"
			case "${OPTARG}" in
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

# load_option "$@"

