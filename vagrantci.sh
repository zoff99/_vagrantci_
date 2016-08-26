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

status_file='./dl/vm_setup_ready.txt'


vagrantci__buf='
==================================================
'

vagrantci__header='
==================================================
                   VagrantCI
'

vagrantci__footer='
==================================================

'

usage()
{
        echo "$vagrantci__header"
        echo " ${0}: run        -> run CI                       "
        echo " ${0}: destroy    -> destroy VM                   "
        echo "$vagrantci__footer"
}

if [ "$1""x" == "x" ]; then
        usage
        exit 0
else
        if [ ! -e ../circle.yml ]; then
                echo "$vagrantci__header"
                echo " \"circle.yml\" not found in parent directory. [../]"
                echo " run from correct directory"
                echo "$vagrantci__footer"
                exit 1
        fi

        if [ ! -e ./Vagrantfile ]; then
                echo "$vagrantci__header"
                echo " \"Vagrantfile\" not found in current directory."
                echo " run from correct directory"
                echo "$vagrantci__footer"
                exit 1
        else
                if [ "$1""x" == "runx" ]; then
                        vm_setup_ready=0
                        if [ -d ./dl ]; then
                                if [ -e "$status_file" ]; then
                                        vm_setup_ready=1
                                fi
                        fi

                        # if vm already setup then just run once
                        # otherwise need to run 2 times (setup + first-CI-run)
                        if [ "$vm_setup_ready""x" == "0x" ]; then
                                echo "$vagrantci__header"
                                echo " ** halting VM ** "
                                vagrant halt --force 2> /dev/null

                                echo "$vagrantci__buf"
                                echo " ** destroy VM ** "
                                printf 'Y\n'|vagrant destroy --force 2> /dev/null
                                rm -f "$status_file"

                                echo "$vagrantci__buf"
                                echo " ** setup VM ** "
                                echo " this can take a long time!!"
                                echo ""
                                vagrant up --provision </dev/null
                                res1=$?

                                if [ $res1 -ne 0 ]; then
                                        echo ""
                                        echo " ++ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "
                                        echo " ++ "
                                        echo " ++ ERROR in setup of VM!!"
                                        echo " ++ "
                                        echo " ++ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "

                                        echo "$vagrantci__buf"
                                        echo " ** halting VM ** "
                                        vagrant halt --force </dev/null
                                        echo "$vagrantci__footer"

                                        exit 1
                                fi

                                echo "$vagrantci__buf"
                                echo " ** suspending VM ** "
                                vagrant suspend </dev/null

                                echo "$vagrantci__buf"
                                echo " ** saving VM snapshot vagrantci001 ** "
                                vagrant snapshot save "vagrantci001" </dev/null

                                echo "$vagrantci__buf"
                                echo " ** CI run ** "
                                echo ""
                                vagrant up --provision </dev/null
                                echo "$vagrantci__footer"
                        else
                                echo "$vagrantci__header"
                                echo " ** halting VM ** "
                                vagrant suspend </dev/null
                                vagrant halt --force </dev/null

                                echo "$vagrantci__buf"
                                echo " ** resetting to VM snapshot vagrantci001 ** "
                                echo " ** CI run ** "
                                vagrant snapshot restore "vagrantci001" </dev/null
                                res1=$?

                                if [ $res1 -ne 0 ]; then
                                        echo ""
                                        echo " ++ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "
                                        echo " ++ "
                                        echo " ++     ERROR "
                                        echo " ++ "
                                        echo " ++ -- retrying -- "
                                        echo " ++ "
                                        echo " ++ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "

                                        echo "$vagrantci__buf"
                                        echo " ** wait a bit ** "
                                        sleep 120

                                        echo "$vagrantci__header"
                                        echo " ** halting VM ** "
                                        vagrant suspend </dev/null
                                        vagrant halt --force </dev/null

                                        echo "$vagrantci__buf"
                                        echo " ** resetting to VM snapshot vagrantci001 ** "
                                        echo " ** CI run ** "
                                        vagrant snapshot restore "vagrantci001" </dev/null
                                fi

                                echo "$vagrantci__footer"
                        fi
                elif [ "$1""x" == "destroyx" ]; then
                        echo "$vagrantci__header"
                        read -p " really destroy VM? [Y/n]:" resp
                        if [ "$resp""x" == "nx" ];then
                                :
                        elif [ "$resp""x" == "Nx" ];then
                                :
                        else
                                printf 'Y\n'|vagrant destroy --force
                                rm -f "$status_file"
                        fi
                        echo "$vagrantci__footer"
                else
                        echo "$vagrantci__header"
                        echo " ** unknown command"
                        echo "$vagrantci__footer"
                        exit 1
                fi
        fi
fi
