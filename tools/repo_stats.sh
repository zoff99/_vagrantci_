#! /bin/bash
#
# VagrantCI - a Poor Man's CI System
# Copyright (C) 2016  Zoff <zoff@zoff.cc>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#


#----------
#----------
__REPO_COMMITHASH="`cd /code_base/ && git rev-parse --verify HEAD`"
#----------
#----------
__REPO_URL="`cd /code_base/ && git config --get remote.origin.url`"
#----------
#----------
# xx="`cd /code_base/ && git rev-parse --show-toplevel`"
__REPO_BASEDIR="`echo "$__REPO_URL"|awk -F"/" '{print $NF}'|cut -d'.' -f 1`"
#----------
#----------
__REPO_USER="user001"
#----------
#----------


export __REPO_COMMITHASH
export __REPO_URL
export __REPO_BASEDIR
export __REPO_USER

echo "
__REPO_COMMITHASH="$__REPO_COMMITHASH"
__REPO_URL="$__REPO_URL"
__REPO_BASEDIR="$__REPO_BASEDIR"
__CI_BUILDNUM="$__CI_BUILDNUM"
__CI_BUILDNUM_M_1="$__CI_BUILDNUM_M_1"
__REPO_USER="$__REPO_USER"
export __REPO_COMMITHASH
export __REPO_URL
export __REPO_BASEDIR
export __CI_BUILDNUM
export __CI_BUILDNUM_M_1
export __REPO_USER
" > /tmp/_git_vars.sh



#  __REPO_COMMITHASH
#  __REPO_URL
#  __REPO_BASEDIR
#  __CI_BUILDNUM
#  __CI_BUILDNUM_M_1
#  __REPO_USER

