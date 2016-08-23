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



__REPO_TYPE="svn"

if [ `ls -1d "/code_base/.git" 2>/dev/null`"x" != "x" ]; then
	__REPO_TYPE="git"

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
	if [ "`/srv/dl/repouser.txt`""x" != "x" ]; then
		__REPO_USER="`/srv/dl/repouser.txt`"
	fi
	#----------
	#----------
	__REPO_PASS=""
	if [ "`/srv/dl/repopass.txt`""x" != "x" ]; then
		__REPO_PASS="`/srv/dl/repopass.txt`"
	fi
	#----------
	#----------

else

	#----------
	#----------
	__REPO_COMMITHASH="`cd /code_base/ && svnversion`"
	#----------
	#----------
	url__=`cd /code_base/ && svn info --xml|grep '<url>'|sed -e 's#<url>##'|sed -e 's#</url>##'`
	__REPO_URL="$url__"
	#----------
	#----------
	base_dir_=`cd /code_base/ && svn info |grep -i 'Repository Root'|awk '{print $3}'|awk -F'/' '{ print $NF }'`
	__REPO_BASEDIR="$base_dir_"
	#----------
	#----------
	__REPO_USER="user001"
	if [ "`cat /srv/dl/repouser.txt`""x" != "x" ]; then
		__REPO_USER="`cat /srv/dl/repouser.txt`"
	fi
	#----------
	#----------
	__REPO_PASS=""
	if [ "`cat /srv/dl/repopass.txt`""x" != "x" ]; then
		__REPO_PASS="`cat /srv/dl/repopass.txt`"
	fi
	#----------
	#----------

fi


export __REPO_COMMITHASH
export __REPO_URL
export __REPO_BASEDIR
export __REPO_USER
export __REPO_PASS
export __REPO_TYPE

echo "
__REPO_COMMITHASH=""$__REPO_COMMITHASH""
__REPO_URL=""$__REPO_URL""
__REPO_BASEDIR=""$__REPO_BASEDIR""
__CI_BUILDNUM="$__CI_BUILDNUM"
__CI_BUILDNUM_M_1="$__CI_BUILDNUM_M_1"
__REPO_USER="$__REPO_USER"
__REPO_PASS=""'""$__REPO_PASS""'""
__REPO_TYPE="$__REPO_TYPE"
export __REPO_COMMITHASH
export __REPO_URL
export __REPO_BASEDIR
export __CI_BUILDNUM
export __CI_BUILDNUM_M_1
export __REPO_USER
export __REPO_PASS
export __REPO_TYPE
" > /tmp/_git_vars.sh



#  __REPO_COMMITHASH
#  __REPO_URL
#  __REPO_BASEDIR
#  __CI_BUILDNUM
#  __CI_BUILDNUM_M_1
#  __REPO_USER
#  __REPO_PASS
#  __REPO_TYPE

