@ECHO OFF

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


setlocal enableDelayedExpansion
set NL=^



set vagrantci__buf= !NL! ^
================================================== !NL!


set vagrantci__header= !NL! ^
================================================== !NL! ^
                   VagrantCI !NL!

set vagrantci__footer= !NL! ^
================================================== !NL! ^
!NL!



IF "%arg1%" == "run" GOTO :RUN
IF "%arg1%" == "destroy" GOTO :DESTROY
GOTO :UNKNOWN

:RUN

	set vm_setup_ready=0

	if exist %status_file% (
		set vm_setup_ready=1
	)

	if %vm_setup_ready% == 0 (

		echo !vagrantci__header!

		echo " ** halting VM ** "
		call vagrant halt --force


		echo !vagrantci__buf!
		echo " ** destroy VM ** "
		call vagrant destroy --force
		DEL "%status_file%" > NUL 2> NUL
		echo ""

		echo !vagrantci__buf!
		echo " ** setup VM ** "
		call vagrant up --provision

		echo !vagrantci__buf!
		echo " ** suspending VM ** "
		call vagrant suspend

		echo !vagrantci__buf!
		echo " ** saving VM snapshot vagrantci001 ** "
		call vagrant snapshot save "vagrantci001"

		echo !vagrantci__buf!
		echo " ** CI run ** "
		echo ""
		call vagrant up --provision

		echo !vagrantci__footer!

	) else (

		echo !vagrantci__header!

		echo " ** halting VM ** "
		call vagrant suspend
		call vagrant halt --force

		echo !vagrantci__buf!
		echo " ** resetting to VM snapshot vagrantci001 ** "
		call vagrant snapshot restore "vagrantci001"

		echo !vagrantci__buf!
		echo " ** CI run ** "
		echo ""
		call vagrant up --provision

		echo !vagrantci__footer!
	)

	GOTO NEXT

:DESTROY

		echo !vagrantci__header!

		echo really destroy VM? [Y/n]
		set INPUT=
		set /P INPUT=:
		If "%INPUT%"=="n" goto nod
		If "%INPUT%"=="N" goto nod
:yesd
		echo " ** destroy VM ** "
		call vagrant destroy --force
		DEL "%status_file%" > NUL 2> NUL
		goto contd
:nod
		echo ...
:contd

		echo !vagrantci__footer!

	GOTO NEXT


:UNKNOWN

	echo !vagrantci__header!
	echo "vagrantci.bat run	-> run CI"
	echo "vagrantci.bat destroy	-> destroy VM"
	echo !vagrantci__footer!

:NEXT

