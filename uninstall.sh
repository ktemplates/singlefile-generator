#!/usr/bin/env bash

# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.

bin="/usr/local/bin"
folder="$bin/_generator"

rm -rf "$bin/generator"
rm -rf "$folder"
