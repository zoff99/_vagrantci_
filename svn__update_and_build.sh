#! /bin/bash

new=`cd .. && svn info -r HEAD 2>/dev/null | grep -i "Last Changed Rev" 2>/dev/null | cut -d':' -f2 | tr -d " "`
old=`cd .. && svn info 2>/dev/null | grep -i "Last Changed Rev" 2>/dev/null | cut -d':' -f2 | tr -d " "`

echo "old rev=""$old"
echo "new rev=""$new"

if [ "$old""x" != "$new""x" ]; then
	echo ""
	echo "============================="
	echo "update and run..."
	echo "============================="
	echo ""
	svn up .. && bash vagrantci.sh run
else
	echo ""
	echo "============================="
	echo "no update"
	echo "============================="
	echo ""
fi
