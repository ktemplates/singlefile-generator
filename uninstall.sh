#!/usr/bin/env bash

# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.

bin="/usr/local/bin"
folder="$bin/_generator"

rm -rf "$bin/generator" &&
	echo "deleted generator cli" ||
	echo "error deleting generator cli" >&2
rm -rf "$bin/generator-resource" &&
	echo "deleted generator-resource cli" ||
	echo "error deleting generator-resource cli" >&2
rm -rf "$folder" &&
	echo "deleted generator folder" ||
	echo "error deleting generator folder" >&2
