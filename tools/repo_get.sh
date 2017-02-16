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




#  __REPO_COMMITHASH
#  __REPO_URL
#  __REPO_BASEDIR
#  __CI_BUILDNUM
#  __CI_BUILDNUM_M_1
#  __REPO_USER
#  __REPO_PASS
#  __REPO_TYPE


if [ "$__REPO_TYPE""x" == "gitx" ]; then

	echo
	echo "---------------------------------------------------------"
	echo "---------------------------------------------------------"
	echo "GIT: clone ""$__REPO_URL"
	echo "GIT: checkout ""$__REPO_COMMITHASH"
	echo "---------------------------------------------------------"
	echo "---------------------------------------------------------"
	echo

	printf '. /tmp/_git_vars.sh \n git clone $__REPO_URL \n pwd \n ls -al \n cd $__REPO_BASEDIR \n git checkout $__REPO_COMMITHASH \n pwd \n ls -al \n' | su - ubuntu

else

	echo
	echo "---------------------------------------------------------"
	echo "---------------------------------------------------------"
	echo "SVN: checkout ""$__REPO_URL"
	echo "SVN: commit# ""$__REPO_COMMITHASH"
	echo "---------------------------------------------------------"
	echo "---------------------------------------------------------"
	echo


	if [ "$__REPO_PASS""x" == "x" ]; then

		printf '. /tmp/_git_vars.sh \n mkdir "$__REPO_BASEDIR" \n cd "$__REPO_BASEDIR" \n svn checkout --non-interactive --trust-server-cert "$__REPO_URL""/" ./ \n pwd \n ls -al \n' | su - ubuntu

	else
		printf '. /tmp/_git_vars.sh \n mkdir "$__REPO_BASEDIR" \n cd "$__REPO_BASEDIR" \n svn checkout --non-interactive --trust-server-cert --username="$__REPO_USER" --password='"'""$__REPO_PASS""'"' "$__REPO_URL""/" ./ \n pwd \n ls -al \n' | su - ubuntu

	fi


fi


# override circle.yml ----------
if [ `ls -1 "/srv/tools/ci_override_circle_yml.txt" 2>/dev/null`"x" != "x" ]; then
	printf '. /tmp/_git_vars.sh \n pwd \n ls -al \n cd $__REPO_BASEDIR \n cp -av /code_base/circle.yml ./circle.yml \n pwd \n ls -al \n' | su - ubuntu
fi
# override circle.yml ----------


function yaml2json()
{
    ruby -ryaml -rjson -e \
         'puts JSON.pretty_generate(YAML.load(ARGF))' $*
}

ci_json="/tmp/circle_yml.json"
rm -f "$ci_json"
# yaml2json /code_base/circle.yml > "$ci_json"
yaml2json /home/ubuntu/"$__REPO_BASEDIR"/circle.yml > "$ci_json"

## --- workaround a bug ---
sed -i -e 's#dpkg --foreign-architecture#dpkg --add-architecture#g' "$ci_json"
## --- workaround a bug ---

ci_cache_dirs="/srv/dl/ci_cache_dirs.txt"
ci_cache_dirs2="/srv/dl/ci_cache_dirs2.txt"
ci_cache_dirs3="/srv/dl/ci_cache_dirs3.txt"
ci_cache_datadir="/srv/dl/"

################## dirs ##################
export bdir="/tmp/CI/"
rm -Rf "$bdir"

mkdir -p "$bdir"

mkdir -p "$bdir"/general/artifacts

mkdir -p "$bdir"/machine/timezone
mkdir -p "$bdir"/machine/environment
mkdir -p "$bdir"/machine/java

mkdir -p "$bdir"/dependencies/cache_directories
mkdir -p "$bdir"/dependencies/pre

mkdir -p "$bdir"/compile/pre
mkdir -p "$bdir"/compile/override

mkdir -p "$bdir"/test/pre
mkdir -p "$bdir"/test/override
################## dirs ##################

function filter_special_chars()
{
	sed -i -e 's#\\\\#\\#g' "$1"
}

function remove_specials_from_cmd_file()
{
	cd "$1" && find . name '*.txt' 2>/dev/null | while read cmd_file; do
		if [ -e "$cmd_file" ]; then
			# echo "$cmd_file"
			sed -i -e 's#\\"#"#g' "$cmd_file" 2>/dev/null
			filter_special_chars "$cmd_file" 2>/dev/null
		fi
	done
}


level_0_keys=`cat /tmp/circle_yml.json | jq keys[] |wc -l 2>/dev/null|tr -d " "`


ci_rc="/tmp/.ci_rc"
rm -f "$ci_rc"
touch "$ci_rc"

cp -v "/srv/tools/jq" "/tmp/jq"
export jq2="/tmp/jq"
chmod a+rx "$jq2"


function process_subkey()
{

			cat /tmp/circle_yml.json | jq '.'"$mainkey"''|jq keys[] | grep "$subkey" > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * ""$subkey"

				_cmd_count=0

				cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'' | jq keys[] | sort -n | while read _linenum ; do

					_cmd_count=$[ $_cmd_count + 1 ]
					# echo "     * ""$_cmd_count"

					cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"']' | jq keys 2>&1| grep 'has no keys' > /dev/null 2>/dev/null
					res2=$? # 0=no keys
					if [ $res2 -eq 0 ]; then
						# flat
						cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"']' \
							| sed -e 's#^"##' | sed -e 's#"$##' \
							>> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_normal.txt
					else
						# -------------- keys --------------

						# background:
						cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"'][]' | jq keys[] | grep 'background' > /dev/null 2>/dev/null
						_key_no_background=$?

						# pwd:
						cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"'][]' | jq keys[] | grep 'pwd' > /dev/null 2>/dev/null
						_key_no_pwd=$?

						if [ $_key_no_pwd -eq 0 ]; then
							if [ $_key_no_background -eq 1 ]; then
								echo -n 'cd ' >> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_normal.txt
								cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"']' | jq '.[].pwd' \
									| sed -e 's#^"##' | sed -e 's#"$##' \
									>> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_normal.txt
							else
								echo -n 'cd ' >> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_bg.txt
								cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"']' | jq '.[].pwd' \
									| sed -e 's#^"##' | sed -e 's#"$##' \
									>> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_bg.txt
							fi
						fi


						if [ $_key_no_background -eq 1 ]; then
							# normal
							cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_normal.txt
						else
							# bg
							cat /tmp/circle_yml.json | jq '.'"$mainkey"'.'"$subkey"'['"$_linenum"']' | jq keys[0] \
								| sed -e 's#^"##' | sed -e 's#"$##' \
								>> "$bdir"/"$mainkey"/"$subkey"/"$_cmd_count"_bg.txt
						fi
					fi
				done
			fi

}



echo
echo "$level_0_keys keys:"

if [ $level_0_keys > 0 ]; then


	cat /tmp/circle_yml.json | jq keys[] | grep 'general' > /dev/null 2> /dev/null
	res=$?
	if [ $res -eq 0 ]; then
		# -------- general --------
		echo " * general"
		level_1_keys=`cat /tmp/circle_yml.json | jq '.general'| jq keys[] |wc -l 2>/dev/null|tr -d " "`

		if [ $level_1_keys > 0 ]; then

			cat /tmp/circle_yml.json | jq '.general'|jq keys[] | grep 'artifacts' > /dev/null 2> /dev/null
			res=$?
			if [ $res -eq 0 ]; then
				echo "   * artifacts"

				cat /tmp/circle_yml.json | jq '.general.artifacts' | jq keys[] | sed -e 's#^"##' | sed -e 's#"$##' | while read _key ; do
					artefact_dir_=`cat /tmp/circle_yml.json | jq '.general.artifacts['"$_key"']' 2> /dev/null | tr -d '\r'| tr -d '\n'`
					echo 'cd /home/ubuntu/"$CIRCLE_PROJECT_REPONAME"/' >> "$bdir"/general/artifacts/"$_key"_artefacts.txt
					echo 'cp -av '"$artefact_dir_"' "$CIRCLE_ARTIFACTS"/' >> "$bdir"/general/artifacts/"$_key"_artefacts.txt
				done
			fi

		fi
		# -------- general --------
	fi





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

				cat /tmp/circle_yml.json | $jq2 '.machine.environment' | $jq2 keys_unsorted[] | sed -e 's#^"##' | sed -e 's#"$##' | while read _key ; do
					echo -n "$_key"'=' >> "$ci_rc"
					cat /tmp/circle_yml.json | $jq2 '.machine.environment.'"$_key" >> "$ci_rc"
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

				set -x

				echo "   * cache_directories"

				cp -v "$ci_cache_dirs" "$ci_cache_dirs2" > /dev/null 2> /dev/null

				cat /tmp/circle_yml.json | jq '.dependencies.cache_directories[]' | sed -e 's#^"##' | sed -e 's#"$##' | while read _key ; do
					echo "     * ""$_key"

					cat "$ci_cache_dirs" 2> /dev/null | grep '^'"$_key"':' > /dev/null 2>/dev/null
					res=$?
					if [ $res -eq 0 ]; then
						echo "     = cache dir:""$_key"
						_cache_data_file=`cat "$ci_cache_dirs" 2> /dev/null | grep '^'"$_key"':' | cut -d':' -f2`
						echo "       ""$_cache_data_file"

						b_key=`basename "$_key"`
						echo 'cd '"$_key"'/../ && tar -cvf '"$_cache_data_file"' '"$b_key" >> "$bdir"/dependencies/cache_directories/0_new_dirs.txt

						# mark found dir -------
						cat "$ci_cache_dirs2" 2> /dev/null | grep -v '^'"$_key"':' > "$ci_cache_dirs3" 2>/dev/null
						mv "$ci_cache_dirs3" "$ci_cache_dirs2"
						# mark found dir -------
					else
						echo "     + new cache dir:""$_key"
						_d_=`date`
						_cache_data_file=`echo "$_key""$_d_" |sha1sum 2>/dev/null |awk '{print $1}'`
						echo "$_key"':'"$ci_cache_datadir"'/'"$_cache_data_file"'.tar' >> "$ci_cache_dirs"

						b_key=`basename "$_key"`
						echo 'cd '"$_key"'/../ && tar -cvf '"$ci_cache_datadir"'/'"$_cache_data_file"'.tar'' '"$b_key" >> "$bdir"/dependencies/cache_directories/0_new_dirs.txt
					fi

					echo 'mkdir -p '"$_key"' && cd '"$_key"'/../ && tar -xvf '"$_cache_data_file" >> "$bdir"/dependencies/cache_directories/1_all_dirs.txt

				done

				# remove old cache files that are not in circle.yml anymore
				cat "$ci_cache_dirs2" 2> /dev/null | grep ':' > /dev/null 2>/dev/null
				res=$?
				if [ $res -eq 0 ]; then
					cat "$ci_cache_dirs2" 2> /dev/null | cut -d':' -f2 2>/dev/null | while read _key ; do
						# remove cache file
						echo rm -v "$_key"
						# remove entry from list file
						cat "$ci_cache_dirs" 2> /dev/null | grep -v "$_key" > "$ci_cache_dirs3" 2>/dev/null
						mv "$ci_cache_dirs3" "$ci_cache_dirs"
					done
				fi
				rm -f "$ci_cache_dirs2" 2> /dev/null
				rm -f "$ci_cache_dirs3" 2> /dev/null

				set +x

			fi


			export mainkey='dependencies'
			export subkey='pre'
			process_subkey
			remove_specials_from_cmd_file "$bdir""/dependencies/pre/"

		fi
		# -------- dependencies --------
	fi

	cat /tmp/circle_yml.json | jq keys[] | grep 'compile' > /dev/null 2> /dev/null
	res=$?
	if [ $res -eq 0 ]; then
		# -------- compile --------
		echo " * compile"

		level_1_keys=`cat /tmp/circle_yml.json | jq '.compile'| jq keys[] |wc -l 2>/dev/null|tr -d " "`

		if [ $level_1_keys > 0 ]; then

			export mainkey='compile'
			export subkey='pre'
			process_subkey
			remove_specials_from_cmd_file "$bdir""/compile/pre/"

			export mainkey='compile'
			export subkey='override'
			process_subkey
			remove_specials_from_cmd_file "$bdir""/compile/override/"


		fi
		# -------- compile --------
	fi


	cat /tmp/circle_yml.json | jq keys[] | grep 'test' > /dev/null 2> /dev/null
	res=$?
	if [ $res -eq 0 ]; then
		# -------- test --------
		echo " * test"

		level_1_keys=`cat /tmp/circle_yml.json | jq '.test'| jq keys[] |wc -l 2>/dev/null|tr -d " "`

		if [ $level_1_keys > 0 ]; then

			export mainkey='test'
			export subkey='pre'
			process_subkey
			remove_specials_from_cmd_file "$bdir""/test/pre/"

			export mainkey='test'
			export subkey='override'
			process_subkey
			remove_specials_from_cmd_file "$bdir""/test/override/"


		fi
		# -------- test --------
	fi


else
	echo "no commands in circle.yml file"
	exit 1
fi


chown -R ubuntu:ubuntu "$bdir"
chmod a+rwx -R "$bdir"
