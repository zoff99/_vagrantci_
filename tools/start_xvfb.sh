#!/bin/bash
#
# VagrantCI - VagrantCI - a Poor Man's CI System
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

#description: Starts xvfb on display 99
#
if [ -z "$1" ]; then
echo "`basename $0` {start|stop}"
    exit
fi

case "$1" in
start)
    /usr/bin/Xvfb :99 -screen 0 1280x1024x24 &
;;

stop)
    killall Xvfb
;;
esac
