#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e
# stty erase ^H
###########

# function to clear temp file/folder on exit
function clear_on_exit {
  cd
  rm -rf "$TMPFOLDER"
}

# exec function on exit
trap clear_on_exit EXIT

# create temp folder
TMPFOLDER=$(mktemp -d -p $HOME) || exit 1

################################
# shell begin
cd $TMPFOLDER

# doing something
