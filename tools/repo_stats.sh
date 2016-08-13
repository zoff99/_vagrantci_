#! /bin/bash

__REPO_COMMITHASH="`cd /code_base/ && git rev-parse --verify HEAD`"
__REPO_URL="`cd /code_base/ && git config --get remote.origin.url`"
# xx="`cd /code_base/ && git rev-parse --show-toplevel`"
__REPO_BASEDIR="`echo "$__REPO_URL"|awk -F"/" '{print $NF}'|cut -d'.' -f 1`"

export __REPO_COMMITHASH
export __REPO_URL
export __REPO_BASEDIR

echo "
__REPO_COMMITHASH="$__REPO_COMMITHASH"
__REPO_URL="$__REPO_URL"
__REPO_BASEDIR="$__REPO_BASEDIR"
export __REPO_COMMITHASH
export __REPO_URL
export __REPO_BASEDIR
" > /tmp/_git_vars.sh
