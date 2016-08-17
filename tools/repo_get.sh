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


echo
echo "---------------------------------------------------------"
echo "---------------------------------------------------------"
echo "GIT: clone ""$__REPO_URL"
echo "GIT: checkout ""$__REPO_COMMITHASH"
echo "---------------------------------------------------------"
echo "---------------------------------------------------------"
echo

printf '. /tmp/_git_vars.sh \n git clone $__REPO_URL \n pwd \n ls -al \n cd $__REPO_BASEDIR \n git checkout $__REPO_COMMITHASH \n pwd \n ls -al \n' | su - ubuntu

function yaml2json()
{
    ruby -ryaml -rjson -e \
         'puts JSON.pretty_generate(YAML.load(ARGF))' $*
}

ci_json="/tmp/circle_yml.json"
rm -f "$ci_json"
yaml2json /code_base/circle.yml > "$ci_json"

ci_cache_dirs="/srv/dl/ci_cache_dirs.txt"
ci_cache_datadir="/srv/dl/"

################## dirs ##################
bdir="/tmp/CI/"
rm -Rf "$bdir"

mkdir -p "$bdir"

mkdir -p "$bdir"/machine/timezone
mkdir -p "$bdir"/machine/environment
mkdir -p "$bdir"/machine/java

mkdir -p "$bdir"/dependencies/cache_directories
mkdir -p "$bdir"/dependencies/pre

mkdir -p "$bdir"/test/pre
mkdir -p "$bdir"/test/override
################## dirs ##################



level_0_keys=`cat /tmp/circle_yml.json | jq keys[] |wc -l 2>/dev/null|tr -d " "`


ci_rc="/tmp/.ci_rc"
rm -f "$ci_rc"
touch "$ci_rc"

echo
echo "$level_0_keys keys:"

if [ $level_0_keys > 0 ]; then
	cat /tmp/circle_yml.json | jq keys[] | grep 'machine' > /dev/null 2> /dev/null
	res=$?
	if [ $res -eq 0 ]; then
		# -------- machine --------
		echo " * machine"
		level_1_keys=`cat /tmp/circle_yml.json | jq '.machine'| jq keys[] |wc -l 2>/dev/null|tr -d " "`

		if [ $level_1_keys > 0 ]; then
			cat /tmp/circle_yml.json | jq '.machine'|jq keys[] | grep 'timezone' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * timezone"

				new_tz="`cat /tmp/circle_yml.json | jq '.machine.timezone' | sed -e 's#^"##' | sed -e 's#"$##' `"
				new_tz="'Europe/Vienna'"
				new_tz="`echo "$new_tz"| sed -e "s#^'##" | sed -e "s#'##" `"

				echo -n "old Timezone: "
				cat /etc/timezone

				echo -n "setting new Timezone: "
				echo "$new_tz"

				echo "$new_tz" > /etc/timezone
				dpkg-reconfigure -f noninteractive tzdata
			fi


			cat /tmp/circle_yml.json | jq '.machine'|jq keys[] | grep 'environment' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * environment"

				cat /tmp/circle_yml.json | jq '.machine.environment' | jq keys[] | sed -e 's#^"##' | sed -e 's#"$##' | while read _key ; do
					echo -n "$_key"'=' >> "$ci_rc"
					cat /tmp/circle_yml.json | jq '.machine.environment.'"$_key" >> "$ci_rc"
					echo 'export '"$_key" >> "$ci_rc"
				done
			fi

			cat /tmp/circle_yml.json | jq '.machine'|jq keys[] | grep 'java' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * java"

					_java_version=`cat /tmp/circle_yml.json | jq '.machine.java.version' | sed -e 's#^"##' | sed -e 's#"$##'`

					if [ "$_java_version""x" == "oraclejdk8x" ]; then
						echo "     * oraclejdk8"
						apt-get install oracle-java8-installer >>/tmp/jdk8.log 2>/tmp/jdk8.log
						update-alternatives --set java /usr/lib/jvm/java-8-oracle/jre/bin/java >>/tmp/jdk8.log 2>/tmp/jdk8.log
						update-alternatives --set javac /usr/lib/jvm/java-8-oracle/bin/javac >>/tmp/jdk8.log 2>/tmp/jdk8.log
					fi
			fi
		fi
		# -------- machine --------
	fi

	cat /tmp/circle_yml.json | jq keys[] | grep 'dependencies' > /dev/null 2> /dev/null
	res=$?
	if [ $res -eq 0 ]; then
		# -------- dependencies --------
		echo " * dependencies"

		level_1_keys=`cat /tmp/circle_yml.json | jq '.dependencies'| jq keys[] |wc -l 2>/dev/null|tr -d " "`

		if [ $level_1_keys > 0 ]; then
			cat /tmp/circle_yml.json | jq '.dependencies'|jq keys[] | grep 'cache_directories' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * cache_directories"

				cat /tmp/circle_yml.json | jq '.dependencies.cache_directories[]' | sed -e 's#^"##' | sed -e 's#"$##' | while read _key ; do
					echo "     * ""$_key"

					cat "$ci_cache_dirs" 2> /dev/null | grep '^'"$_key"':' > /dev/null 2>/dev/null
					res=$?
					if [ $res -eq 0 ]; then
						echo "     = cache dir:""$_key"
						_cache_data_file=`cat "$ci_cache_dirs" 2> /dev/null | grep '^'"$_key"':' | cut -d':' -f2`
						echo "       ""$_cache_data_file"
					else
						echo "     + new cache dir:""$_key"
						_d_=`date`
						_cache_data_file=`echo "$_key""$_d_" |sha1sum 2>/dev/null |awk '{print $1}'`
						echo "$_key"':'"$ci_cache_datadir"'/'"$_cache_data_file"'.tar' >> "$ci_cache_dirs"

						b_key=`basename "$_key"`
						echo 'cd '"$_key"'/../ ; tar -cvf '"$_cache_data_file"' '"$b_key" >> "$bdir"/dependencies/cache_directories/0_new_dirs.txt
					fi

					echo 'cd '"$_key"'/../ ; tar -xvf '"$_cache_data_file" >> "$bdir"/dependencies/cache_directories/1_all_dirs.txt

				done

			fi



			cat /tmp/circle_yml.json | jq '.dependencies'|jq keys[] | grep 'pre' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * pre"

				_cmd_count=0

				cat /tmp/circle_yml.json | jq '.dependencies.pre' | jq keys[] | sort -n | while read _linenum ; do

					_cmd_count=$[ $_cmd_count + 1 ]
					# echo "     * ""$_cmd_count"

					cat /tmp/circle_yml.json | jq '.dependencies.pre['"$_linenum"']' | jq keys 2>&1| grep 'has no keys' > /dev/null 2>/dev/null
					res2=$? # 0=no keys
					if [ $res2 -eq 0 ]; then
						# flat
						cat /tmp/circle_yml.json | jq '.dependencies.pre['"$_linenum"']' \
							| sed -e 's#^"##' | sed -e 's#"$##' \
							>> "$bdir"/dependencies/pre/"$_cmd_count"_normal.txt
					else
						# keys
						cat /tmp/circle_yml.json | jq '.dependencies.pre['"$_linenum"'][]' | jq keys[] | grep 'background' > /dev/null 2>/dev/null
						_key_no_background=$?
						if [ $_key_no_background -eq 1 ]; then
							# normal
							cat /tmp/circle_yml.json | jq '.dependencies.pre['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/dependencies/pre/"$_cmd_count"_normal.txt

						else
							# bg
							cat /tmp/circle_yml.json | jq '.dependencies.pre['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/dependencies/pre/"$_cmd_count"_bg.txt
						fi
					fi
				done
			fi
		fi
		# -------- dependencies --------
	fi

	cat /tmp/circle_yml.json | jq keys[] | grep 'test' > /dev/null 2> /dev/null
	res=$?
	if [ $res -eq 0 ]; then
		# -------- test --------
		echo " * test"

		level_1_keys=`cat /tmp/circle_yml.json | jq '.test'| jq keys[] |wc -l 2>/dev/null|tr -d " "`

		if [ $level_1_keys > 0 ]; then

			cat /tmp/circle_yml.json | jq '.test'|jq keys[] | grep 'pre' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * pre"

				_cmd_count=0


				cat /tmp/circle_yml.json | jq '.test.pre' | jq keys[] | sort -n | while read _linenum ; do

					_cmd_count=$[ $_cmd_count + 1 ]
					# echo "     * ""$_cmd_count"

					cat /tmp/circle_yml.json | jq '.test.pre['"$_linenum"']' | jq keys 2>&1| grep 'has no keys' > /dev/null 2>/dev/null
					res2=$? # 0=no keys
					if [ $res2 -eq 0 ]; then
						# flat
						cat /tmp/circle_yml.json | jq '.test.pre['"$_linenum"']' \
							| sed -e 's#^"##' | sed -e 's#"$##' \
							>> "$bdir"/test/pre/"$_cmd_count"_normal.txt
					else
						# keys
						cat /tmp/circle_yml.json | jq '.test.pre['"$_linenum"'][]' | jq keys[] | grep 'background' > /dev/null 2>/dev/null
						_key_no_background=$?
						if [ $_key_no_background -eq 1 ]; then
							# normal
							cat /tmp/circle_yml.json | jq '.test.pre['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/test/pre/"$_cmd_count"_normal.txt

						else
							# bg
							cat /tmp/circle_yml.json | jq '.test.pre['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/test/pre/"$_cmd_count"_bg.txt
						fi
					fi
				done
			fi



			cat /tmp/circle_yml.json | jq '.test'|jq keys[] | grep 'override' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * override"

				_cmd_count=0


				cat /tmp/circle_yml.json | jq '.test.override' | jq keys[] | sort -n | while read _linenum ; do

					_cmd_count=$[ $_cmd_count + 1 ]
					# echo "     * ""$_cmd_count"

					cat /tmp/circle_yml.json | jq '.test.override['"$_linenum"']' | jq keys 2>&1| grep 'has no keys' > /dev/null 2>/dev/null
					res2=$? # 0=no keys
					if [ $res2 -eq 0 ]; then
						# flat
						cat /tmp/circle_yml.json | jq '.test.override['"$_linenum"']' \
							| sed -e 's#^"##' | sed -e 's#"$##' \
							>> "$bdir"/test/override/"$_cmd_count"_normal.txt
					else
						# keys
						cat /tmp/circle_yml.json | jq '.test.override['"$_linenum"'][]' | jq keys[] | grep 'background' > /dev/null 2>/dev/null
						_key_no_background=$?
						if [ $_key_no_background -eq 1 ]; then
							# normal
							cat /tmp/circle_yml.json | jq '.test.override['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/test/override/"$_cmd_count"_normal.txt

						else
							# bg
							cat /tmp/circle_yml.json | jq '.test.override['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/test/override/"$_cmd_count"_bg.txt
						fi
					fi
				done
			fi
		fi
		# -------- test --------
	fi


	cd "$bdir"/dependencies/pre/ && find . name '*.txt' 2>/dev/null | while read cmd_file; do
		if [ -e "$cmd_file" ]; then
			# echo "$cmd_file"
			sed -i -e 's#\\"#"#g' "$cmd_file" 2>/dev/null
		fi
	done

	cd "$bdir"/test/pre/ && find . name '*.txt' 2>/dev/null | while read cmd_file; do
		if [ -e "$cmd_file" ]; then
			# echo "$cmd_file"
			sed -i -e 's#\\"#"#g' "$cmd_file" 2>/dev/null
		fi
	done
	cd "$bdir"/test/override/ && find . name '*.txt' 2>/dev/null | while read cmd_file; do
		if [ -e "$cmd_file" ]; then
			# echo "$cmd_file"
			sed -i -e 's#\\"#"#g' "$cmd_file" 2>/dev/null
		fi
	done

else
	echo "no commands in circle.yml file"
	exit 1
fi

# cat /tmp/circle_yml.json | jq '.test.override'| jq keys| jq max
# cat /tmp/circle_yml.json | jq '.test.override[16]' | jq keys
# cat /tmp/circle_yml.json | jq '.test.override[16][]' | jq keys


chown -R ubuntu:ubuntu "$bdir"
chmod a+rwx -R "$bdir"
