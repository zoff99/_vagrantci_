#!/usr/bin/env bash
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


#### check what run we should do ####
#
vm_send_email_file="/srv/dl/vm_send_email.txt"
vm_email_send_to_file="/srv/dl/emailto.txt"

if [ `ls -1 "$vm_send_email_file" 2>/dev/null`"x" != "x" ]; then
	email_file=`cat "$vm_send_email_file" | tr -d '\r'| tr -d '\n'`

	if [ `ls -1 "$vm_email_send_to_file" 2>/dev/null`"x" != "x" ]; then
		email_to=`cat "$vm_email_send_to_file" | tr -d '\r'| tr -d '\n'`
		mail -a "Content-type: text/html" -s "VagrantCI Build" "$email_to" < "$email_file"
	fi

	rm -f "$vm_send_email_file"
fi
