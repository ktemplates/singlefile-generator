#!/bin/bash

# ---------------------------------------------
# Constants
# ---------------------------------------------
HEADER="#!/bin/"
SHELL="bash"
FILE=""

HELP="
# --------------------
Support template: 
  1. Bash
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

B_CD="
cd "$(dirname "$(realpath $0)")"
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
# Bug:          ...
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

# ---------------------------------------------
# app logic
# ---------------------------------------------

while getopts  't:f:h' flag; do
  case "${flag}" in
    t) SHELL="$(to_lower_case $OPTARG)" ;;
    f) FILE="$OPTARG" ;;
    h) echo "$HELP"; exit 0 ;;
  esac
done

RESULT="$HEADER$SHELL\n"
echo "Using template: $SHELL"

if [[ $SHELL == "bash" ]]; then
  echo "This will ask some section that you might need."
  echo "If you need it please enter 'Y' otherwise enter some of charactor to next"
  printf "Add Header? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_HEADER" && echo " -- Add!"
  printf "Add Constants? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_CONSTANT" && echo " -- Add!"
  printf "Add Function? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_FUNCTION" && echo " -- Add!"
  printf "Add App logic? " && [[ $(ask) == "y" ]] && RESULT="$RESULT\n$B_SEC_APP_LOGIC" && echo " -- Add!"
fi

if [[ $FILE != "" ]]; then
  printf "$RESULT\n" > $FILE
else
  printf "$RESULT\n"
fi
