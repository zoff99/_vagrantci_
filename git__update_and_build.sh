#! /bin/bash

busy_file='./dl/vm_ci_running.txt'

if [ -e "$busy_file" ]; then
	# echo " ** VM running / busy ** "
	exit 0
fi


# Your branch is up-to-date
# Your branch is behind

cd .. && git remote -v update > /dev/null 2> /dev/null;
git remote -v update > /dev/null 2> /dev/null;
git remote -v update > /dev/null 2> /dev/null;
git status 2>&1 | grep 'Your branch is up-to-date' > /dev/null 2> /dev/null

need_update=$?

if [ "$need_update""x" != "0x" ]; then
	echo ""
	echo "============================="
	echo "update and run..."
	echo "============================="
	echo ""
	git pull && cd _vagrantci_ && bash vagrantci.sh run
# else
	# cd _vagrantci_
	# :
	# echo ""
	# echo "============================="
	# echo "no update"
	# echo "============================="
	# echo ""
fi

