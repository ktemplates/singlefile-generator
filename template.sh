#!/bin/bash

# ---------------------------------------------
# script description
# ---------------------------------------------

VERSION="v1.0.2"

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
# Bash TEMPLATE
# ---------------------------------------------

B_LINE="# -------------------------------------------------"

B_HELPER="
# set -x #DEBUG - Display commands and their arguments as they are executed.
# set -v #VERBOSE - Display shell input lines as they are read.
# set -n #EVALUATE - Check syntax of the script but don't execute.
"

B_CD="
cd "\$(dirname "\$(realpath \$0)")"
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

function to_lower_case {
  echo $1 | tr '[:upper:]' '[:lower:]'
}

function ask {
  read -n 1 ans
  to_lower_case $ans
}

function have_file {
  [ -x $FILE ] && echo false || echo true
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
  printf "Add Header? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_HEADER\n$B_CD" && echo " -- Add!"
  printf "Add Constants? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_CONSTANT" && echo " -- Add!"
  printf "Add Function? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_FUNCTION" && echo " -- Add!"
  printf "Add App logic? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_APP_LOGIC" && echo " -- Add!"
  
  # if no extension
  if $(have_file); then
    [ $(echo "$FILE" | grep "[\.].*[s][ch].*" 2>/dev/null) ] || FILE="$FILE.sh"
  fi
fi

if $(have_file); then
  printf "$RESULT\n" > $FILE
  [[ $SHELL == "bash" || $SHELL == "zsh" ]] && chmod +x $FILE
else
  printf "$RESULT\n"
fi
