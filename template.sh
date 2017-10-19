#!/bin/bash

# ---------------------------------------------
# script description
# ---------------------------------------------

VERSION="v2.0"

# ---------------------------------------------
# Constants
# ---------------------------------------------
HEADER="#!/usr/bin/env"
SHELL="bash"
FILE=""

HELP="
# --------------------
Option: 
  -t -> template
  -f -> file location and name
  -h -> help command
# --------------------
Support template: 
  1. Bash
  2. Zsh
# --------------------
Creator:   Kamontat Chantrachirathumrong
Version:   1.0
# --------------------
"

RESULT=""

# ---------------------------------------------
# help command
# ---------------------------------------------

# have 1 params, and it is `help` open help command and exit
[ -n $1 ] && [[ "$1" == "help" ]] && echo "$HELP" && exit 0

# ---------------------------------------------
# Bash TEMPLATE
# ---------------------------------------------

B_LINE="# -------------------------------------------------"

B_HELPER="
# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
"

B_CD="
cd \"\$(dirname \"\$(realpath \"\$0\")\")\"
"

B_SEC_HEADER="
$B_LINE
# Description:  ...
# Create by:    ...
# Since:        ...
$B_LINE
# Version:      0.0.1  -- description
#               0.0.2b -- beta-format
$B_LINE
# Error code    1      -- error
$B_LINE
# Bug:          ...
$B_LINE
"

B_SEC_CONSTANT="
$B_LINE
# Constants
$B_LINE
"

B_SEC_FUNCTION="
$B_LINE
# Functions
$B_LINE
"

B_SEC_APP_LOGIC="
$B_LINE
# App logic
$B_LINE
"

# ---------------------------------------------
# Functions
# ---------------------------------------------

to_lower_case() {
  echo $1 | tr '[:upper:]' '[:lower:]'
}

ask() {
  read -n 1 ans
  to_lower_case $ans
}

have_file() {
  [ -n $FILE ] && return 0 || return 1
}

# @params - 1 - extension regex
is_file_has_extension() {
  echo "$FILE" | grep "$2" 2>/dev/null
}

# @params - 1 - extension regex
#           2 - default extension
update_extension() {
  if have_file; then 
    ! is_file_has_extension "$1" && FILE="$FILE.$2"
  fi
}

user_input() {
  printf "$1 " && [[ $(ask) == "y" ]] && return 0 || return 1
}

sucessful() {
  echo " -- Add!"
}

failure() {
  echo
}

# ---------------------------------------------
# app logic
# ---------------------------------------------

while getopts  't:f:hv' flag; do
  case "${flag}" in
    t) SHELL="$(to_lower_case $OPTARG)" ;;
    f) FILE="$OPTARG" ;;
    v) echo "$VERSION"; exit 0 ;;
    h) echo "$HELP"; exit 0 ;;
    ?) echo "$HELP"; exit 1 ;;
  esac
done

RESULT="$HEADER $SHELL\n"
echo "Using template: $SHELL"

if [[ $SHELL == "bash" || $SHELL == "zsh" ]]; then
  echo "This will ask some section that you might need."
  echo "If you need it please enter 'Y' otherwise enter some of charactor to next"
  RESULT="$RESULT\n$B_HELPER"
  user_input "Add Header section?" && RESULT="$RESULT\n$B_SEC_HEADER\n$B_CD" && sucessful || failure
  user_input "Add Constants section?" && RESULT="$RESULT\n$B_SEC_CONSTANT" && sucessful || failure
  user_input "Add Function section?" && RESULT="$RESULT\n$B_SEC_FUNCTION" && sucessful || failure
  user_input "Add App logic section?" && RESULT="$RESULT\n$B_SEC_APP_LOGIC" && sucessful || failure
  
  update_extension "[\.].*[s][ch].*" "sh"
fi

if $(have_file); then
  printf "$RESULT\n" > $FILE
  [[ $SHELL == "bash" || $SHELL == "zsh" ]] && chmod +x $FILE
else
  printf "$RESULT\n"
fi
