#!/usr/bin/env bash

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
#/ Version:      0.0.1  -- description
#/               0.0.2b -- beta-format
#/ -----------------------------------
#/ Error code    1      -- error
#/ -----------------------------------
#/ Bug:          ...
#/ -----------------------------------

cd "$(dirname "$0")" || exit 1

$PWD/uninstall.sh

$PWD/install.sh
