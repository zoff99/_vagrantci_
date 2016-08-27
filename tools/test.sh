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

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'

delay_1=0
delay_2=1

command_chars=80

timeout_value_normal="120.5m" # 2h
timeout_value_bg="300.5m" # 5h

export bdir="/tmp/CI/"
export ldir="/tmp/logCI/"
export pids="/tmp/ci_bg_pids.txt"

mkdir -p "$ldir"
rm -f "$pids"

# echo "dependencies/cache_directories"
# cd "$bdir"/dependencies/cache_directories
#find . -name '*.txt' 2> /dev/null | sort -V | while read _cmdfile; do
#	ls -al "$_cmdfile"
#done

html_template_001='<HTML>
<head>
<style>
pre {
    font-size:small;
	font-family: "Lucida Console", Monaco, monospace;
}

summary {
    font-size:large;
	font-family: "Lucida Console", Monaco, monospace;
	color:Black;
}

summary.red{
	background-color: Red;
	border:2px dotted Black;
}

summary.green{
	background-color: LightGreen;
	border:2px dotted Green;
}

summary.blue{
	background-color: LightBlue;
	border:2px dotted Black;
}

</style>
</head>
'

html_template_cmd_head_1='<details>
<summary class="@@REDGREEN@@">[@@TIME@@]&nbsp;@@TITLE@@</summary>
'

html_template_cmd_command_1='
<p><pre>'

html_template_cmd_command_2='</pre><p><HR>
'



html_template_cmd_log_1='<p>
<pre>'

html_template_cmd_log_2='</pre>
</p>
'

html_template_cmd_head_2='</details>
'

html_template_099='</HTML>
'

html_template_output_files_1='<a href="'
html_template_output_files_2='">'
html_template_output_files_3='</a><BR>'


rm -f "$CIRCLE_ARTIFACTS"/index.html
echo "$html_template_001" >> "$CIRCLE_ARTIFACTS"/index.html

echo '<br><div align="center"><H2>VagrantCI Build:'"$CIRCLE_PROJECT_REPONAME"' #'"$CIRCLE_BUILD_NUM"'</H2></div><br>' >> "$CIRCLE_ARTIFACTS"/index.html
echo '<a href="' >> "$CIRCLE_ARTIFACTS"/index.html
echo "$CIRCLE_REPOSITORY_URL" >> "$CIRCLE_ARTIFACTS"/index.html
echo '">repository URL</a><br><br>' >> "$CIRCLE_ARTIFACTS"/index.html

echo '<br><br><div>' >> "$CIRCLE_ARTIFACTS"/index.html
echo '@@::++_O_U_T_P_U_T_F_I_L_E_S_++::@@' >> "$CIRCLE_ARTIFACTS"/index.html
echo '</div><br><br>' >> "$CIRCLE_ARTIFACTS"/index.html


function sync_install_log_()
{
	# sync install.log
	cp /srv/dl/install.log "$CIRCLE_ARTIFACTS"/install.log
}


function clean_up()
{

sync_install_log_

# ---- paste all bg logs into HTML file ----
bg_count=`cat "$CIRCLE_ARTIFACTS"/index.html | grep '@@%%::' | wc -l | tr -d ' '`
bb_count=0

if [ "$bg_count""x" != "0x" ]; then
	bb_count=$[ $bb_count + 1 ]
	cp "$CIRCLE_ARTIFACTS"/index.html /tmp/temp_read.$$.$bb_count.txt
	cat /tmp/temp_read.$$.$bb_count.txt | grep '@@%%::' | sed -e 's.^@@%%::..' | sed -e 's.@@%%::$..' | while read fname; do

		rm -f /tmp/xsed.$$.$bb_count.txt
		fname_quoted="`echo "$fname"|sed -e 's#/#\\\\/#g'`"
		echo '/@@%%::'"$fname_quoted"'@@%%::/ {
  r '"${fname}"'
  d
}' </dev/null >/tmp/xsed.$$.$bb_count.txt

		sed -f /tmp/xsed.$$.$bb_count.txt "$CIRCLE_ARTIFACTS"/index.html </dev/null >/tmp/temp_html.$$.$bb_count.txt
		cp /tmp/temp_html.$$.$bb_count.txt "$CIRCLE_ARTIFACTS"/index.html
		rm -f "/tmp/temp_html.$$.$bb_count.txt"
		rm -f /tmp/xsed.$$.$bb_count.txt
	done

fi
# ---- paste all bg logs into HTML file ----


# collect artifacts -------------------------

fname="/tmp/outputfiles.$$.tmp"
rm -f "$fname"
echo '<a href="../circle-junit/"><B>other files</b></a><br><br>' >> "$fname"

cd "$CIRCLE_ARTIFACTS"
find . -maxdepth 1|sort -n|grep -v '^./index.html$'|grep -v '^\.$' | grep -v '^\.\.$'| while read output_file; do
	echo -n "$html_template_output_files_1" >> "$fname"
	echo -n "$output_file" >> "$fname"
	echo -n "$html_template_output_files_2" >> "$fname"
	echo -n "$output_file" >> "$fname"
	echo "$html_template_output_files_3" >> "$fname"
done
# collect artifacts -------------------------

echo '/@@::++_O_U_T_P_U_T_F_I_L_E_S_++::@@/ {
r '"${fname}"'
d
}' </dev/null >/tmp/xsed.$$.outputfiles.txt

cp "$CIRCLE_ARTIFACTS"/index.html /tmp/temp_html.$$.outputfiles.txt
sed -f /tmp/xsed.$$.outputfiles.txt "$CIRCLE_ARTIFACTS"/index.html </dev/null >/tmp/temp_html.$$.outputfiles.txt
cp /tmp/temp_html.$$.outputfiles.txt "$CIRCLE_ARTIFACTS"/index.html

rm -f /tmp/xsed.$$.outputfiles.txt
rm -f /tmp/temp_html.$$.outputfiles.txt




# ---- kill all background jobs that are still running ----

if [ "`cat "$pids" 2>/dev/null|grep -v '^$'|wc -l`""x" != "0x" ]; then
	echo
	echo "========== INFO ==========="
	echo "-- bg jobs still running --"
	cat "$pids" 2>/dev/null
	echo "-- bg jobs still running --"

	# -- first kill all childs
	cat "$pids" | xargs -L1 pkill -P > /dev/null 2> /dev/null
	cat "$pids" | xargs -L1 pkill -9 -P > /dev/null 2> /dev/null
	# -- now kill processes itself
	cat "$pids" | xargs -L1 pkill > /dev/null 2> /dev/null
	cat "$pids" | xargs -L1 pkill -9 > /dev/null 2> /dev/null

	echo "========== INFO ==========="
	echo

fi
# ---- kill all background jobs that are still running ----


echo "$html_template_099" >> "$CIRCLE_ARTIFACTS"/index.html

}


_must_exit_=0
_exit_code_=0
echo $_must_exit_ > /tmp/_must_exit_
echo $_exit_code_ > /tmp/_exit_code_


sync_install_log_


function exit2()
{
	echo $_must_exit_ > /tmp/_must_exit_
	echo $_exit_code_ > /tmp/_exit_code_
	exit $_exit_code_
}


function run_test_group()
{

	mainkey_tests="$1"
	subkey_tests="$2"
	need_exit="$3"

if [ "$need_exit""x" == "ex_yesx" ]; then
	need_ex=1
else
	need_ex=0
fi

echo "$mainkey_tests""/""$subkey_tests"
_l="$ldir"/"$mainkey_tests"/"$subkey_tests"/
_c="$bdir"/"$mainkey_tests"/"$subkey_tests"/
cd "$_c"
mkdir -p "$_l"
tmpf="/tmp/ls.$$.tmp"
rm -f "$tmpf"
find . -name '*.txt' 2> /dev/null | sort -V > "$tmpf"
cat "$tmpf" | while read _cmdfile; do

	if [ $need_ex -eq 1 ]; then
		if [ ${_must_exit_} -ne 0 ]; then
			export _must_exit_
			export _exit_code_
			exit2 ${_exit_code_}
		fi
	fi

	sleep $delay_1
	START=$(date +%s)
	_l2="$_l"'/'"$_cmdfile"
	_c2="$_c""$_cmdfile"
	echo "$_cmdfile"|grep 'bg\.txt' > /dev/null 2> /dev/null
	_not_bg=$?
	if [ $_not_bg -eq 1 ]; then
		echo -e "${GREEN}""$_cmdfile""${NC}"
		echo -e "${NC}""== COMMAND =="
		cat "$_c2" |head -2|cut -c 1-${command_chars}
		echo -e "${NC}""============="
		( cd ~/"$CIRCLE_PROJECT_REPONAME" ; . /tmp/.ci_rc ; timeout --signal=SIGKILL "$timeout_value_normal" /bin/bash -c "$_c2" </dev/null >> "$_l2" 2>&1 )
		excode=$?
		END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'
		time_formatted=`echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'`

		_red_green='green'
		if [ $excode -ne 0 ]; then
			_red_green='red'
		fi
		echo "$html_template_cmd_head_1" | sed -e "s#@@REDGREEN@@#${_red_green}#" \
			| sed -e "s#@@TIME@@#${time_formatted}#" \
			| sed -e "s#@@TITLE@@#${mainkey_tests}.${subkey_tests} ${_cmdfile}#" \
			>> "$CIRCLE_ARTIFACTS"/index.html

		# ------- commands -------
		rm -f "/tmp/xyz.txt"
		cat "$_c2" | sed -e 's#<#\&lt;#g' | sed -e 's#>#\&gt;#g' > /tmp/xyz.txt
		echo "$html_template_cmd_command_1" >> "$CIRCLE_ARTIFACTS"/index.html
		cat "/tmp/xyz.txt" >> "$CIRCLE_ARTIFACTS"/index.html
		echo "$html_template_cmd_command_2" >> "$CIRCLE_ARTIFACTS"/index.html
		# ------- commands -------

		# ------- log -------
		rm -f "/tmp/xyz.txt"
		cat "$_l2" | sed -e 's.#..g' | sed -e 's#<#\&lt;#g' | sed -e 's#>#\&gt;#g' > /tmp/xyz.txt
		echo "$html_template_cmd_log_1" >> "$CIRCLE_ARTIFACTS"/index.html
		cat "/tmp/xyz.txt" >> "$CIRCLE_ARTIFACTS"/index.html
		echo "$html_template_cmd_log_2" >> "$CIRCLE_ARTIFACTS"/index.html
		# ------- log -------

		echo "$html_template_cmd_head_2" >> "$CIRCLE_ARTIFACTS"/index.html

		if [ $excode -ne 0 ]; then

			if [ "$mainkey_tests""/""$subkey_tests""/x" == "test/override/x" ]; then
				echo -e "${RED}""===== TEST FAILED ====="
			else
				echo -e "${RED}""===== ERROR ====="
			fi
			cat $_c2
			echo "====== LOG ======"
			tail -10 "$_l2"
			echo "================="

			if [ $need_ex -eq 1 ]; then
				clean_up
				_must_exit_=1
				_exit_code_=$excode
				export _must_exit_
				export _exit_code_
				exit2 $excode
			fi
		fi
	else
		sleep $delay_2
		echo -e "${GREEN}""$_cmdfile${NC} ${RED}[BG]${NC}"
		echo -e "${NC}""== COMMAND =="
		cat "$_c2" |head -2|cut -c 1-${command_chars}
		echo -e "${NC}""============="
		( cd ~/"$CIRCLE_PROJECT_REPONAME" ; . /tmp/.ci_rc ; timeout --signal=SIGKILL "$timeout_value_bg" /bin/bash -c "$_c2" </dev/null >> "$_l2" 2>&1 )&
		echo $! >> "$pids"

		_red_green='blue'
		echo "$html_template_cmd_head_1" | sed -e "s#@@REDGREEN@@#${_red_green}#" \
			| sed -e "s#@@TIME@@#-:--:--#" \
			| sed -e "s#@@TITLE@@#${mainkey_tests}.${subkey_tests} ${_cmdfile}#" \
			>> "$CIRCLE_ARTIFACTS"/index.html

		# ------- commands -------
		rm -f "/tmp/xyz.txt"
		cat "$_c2" | sed -e 's#<#\&lt;#g' | sed -e 's#>#\&gt;#g' > /tmp/xyz.txt
		echo "$html_template_cmd_command_1" >> "$CIRCLE_ARTIFACTS"/index.html
		cat "/tmp/xyz.txt" >> "$CIRCLE_ARTIFACTS"/index.html
		echo "$html_template_cmd_command_2" >> "$CIRCLE_ARTIFACTS"/index.html
		# ------- commands -------

		echo "$html_template_cmd_log_1" >> "$CIRCLE_ARTIFACTS"/index.html
		echo '@@%%::'"$_l2"'@@%%::' >> "$CIRCLE_ARTIFACTS"/index.html
		echo "$html_template_cmd_log_2" >> "$CIRCLE_ARTIFACTS"/index.html
		echo "$html_template_cmd_head_2" >> "$CIRCLE_ARTIFACTS"/index.html
	fi

	sync_install_log_
done

}


function sync_and_check_exit()
{
	sync_install_log_
	export _must_exit_=`cat /tmp/_must_exit_`
	export _exit_code_=`cat /tmp/_exit_code_`
	if [ ${_must_exit_} -ne 0 ]; then
		exit ${_exit_code_}
	fi
}

run_test_group "dependencies" "pre" "ex_yes"
sync_and_check_exit

run_test_group "test" "pre" "ex_yes"
sync_and_check_exit

run_test_group "test" "override" "x"
sync_and_check_exit

clean_up


export _must_exit_=0
export _exit_code_=0
echo $_must_exit_ > /tmp/_must_exit_
echo $_exit_code_ > /tmp/_exit_code_

