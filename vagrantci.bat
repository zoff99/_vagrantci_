@echo off

REM
REM VagrantCI - a Poor Man's CI System
REM Copyright (C) 2016  Zoff <zoff@zoff.cc>
REM
REM This program is free software; you can redistribute it and/or
REM modify it under the terms of the GNU General Public License
REM as published by the Free Software Foundation; either version 2
REM of the License, or (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program; if not, write to the Free Software
REM Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
REM

REM C:\HashiCorp\Vagrant\bin\vagrant


set status_file=".\dl\vm_setup_ready.txt"
set arg1=%1

IF "%arg1%" == "run" GOTO :RUN
IF "%arg1%" == "destroy" GOTO :DESTROY
GOTO :UNKNOWN

:RUN

	set vm_setup_ready=0
	if exist %status_file% (
		set vm_setup_ready=1
	)

	if "%vm_setup_ready%" == 0 (
		echo " ** halting VM ** "
		vagrant halt --force

		echo " ** destroy VM ** "
		vagrant destroy --force
		DEL "%status_file%"
		echo ""

		echo " ** setup VM ** "
		vagrant up --provision

		echo " ** suspending VM ** "
		vagrant suspend

		echo " ** saving VM snapshot vagrantci001 ** "
		vagrant snapshot save "vagrantci001"

		echo " ** CI run ** "
		echo ""
		vagrant up --provision
	) else (
		echo " ** halting VM ** "
		vagrant suspend
		vagrant halt --force

		echo " ** resetting to VM snapshot vagrantci001 ** "
		vagrant snapshot restore "vagrantci001"

		echo " ** CI run ** "
		echo ""
		vagrant up --provision
	)

	GOTO NEXT

:DESTROY

		echo " ** destroy VM ** "
		vagrant destroy --force
		DEL "%status_file%"
		echo ""

	GOTO NEXT


:UNKNOWN

	echo " ** unknown command"

:NEXT

