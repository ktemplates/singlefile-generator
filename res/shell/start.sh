#!/usr/bin/env bash
# shellcheck disable=SC2154

# set -x #DEBUG - Display commands and their arguments as they are executed.

## Helper variable
### TYPE                        -- (string)  type of command (should same with directory name)
### RESOURCE_LOCATION           -- (path)    absolute current directory
### RESOURCE_REGEX              -- (regex)   regex for loop all resource file in directory
### ABSOLUTE_FILE               -- (path)    input file, which user expect to saved as
### FILENAME                    -- (string)  output filename
### IS_HELP                     -- (boolean) is user need help from generate
### WITH_HELP                   -- (boolean) output help in runtime, before interaction prompt
### GENERATOR_VERSION           -- (string)  generator version

## Helper method
### get_variable $1             -- $context, get list of variable by '$VARIABLE_ARRAY'
### is_value_exist $1           -- check is enviroment of variable name exist
### replace_variable $1 $2 $3   -- $var_name $value $content, this support recursive replace.
###                             -- and you can get content by 'show_content' method
### show_content                -- show content that replaced by 'replace_variable' method,
###                             -- note that after run this method your saving content will gone.
### prompt $1                   -- $key, prompt value from user
### is_wanted $1                -- $folder, ask user did they want this file

### generator_one_file $1       -- $filename, for generate file in resource, and also replace logic.
### loop_variable               -- loop and show help command in each type
### loop_generate               -- looping generate across resource files
### get_result                  -- get generated result

if [[ $IS_HELP == true ]]; then
	loop_variable
else
	loop_generate
	get_result
	
	if test -n "$ABSOLUTE_FILE"; then
		chmod +x "$ABSOLUTE_FILE"
	fi
fi
