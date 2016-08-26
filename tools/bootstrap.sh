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
vm_setup_ready_file="/srv/dl/vm_setup_ready.txt"

vm_setup_ready_flag=0
if [ `ls -1 "$vm_setup_ready_file" 2>/dev/null`"x" != "x" ]; then
	vm_setup_ready_flag=1
fi
#
#### check what run we should do ####


START_ALL=$(date +%s)

START=$(date +%s)

if [ $vm_setup_ready_flag -eq 0 ]; then
	echo ""
	echo "+RUN TYPE:configuring CI machine..."
	echo ""
else
	echo ""
	echo "+RUN TYPE:CI run..."
	echo ""
fi

echo "rotating install logfile..."
cp -av /srv/dl/install.log /srv/dl/install.log.1 2> /dev/null
echo "clearing install logfile..."
echo "" > /srv/dl/install.log

# ---------------------------------------
function sync_install_log_()
{
        # sync install.log
        cp /srv/dl/install.log "$CIRCLE_ARTIFACTS"/install.log
	chmod a+rw "$CIRCLE_ARTIFACTS"/install.log
}
# ---------------------------------------



if [ $vm_setup_ready_flag -eq 0 ]; then

# circleCI specific ---
groupadd -g 99000 ubuntu >> /srv/dl/install.log 2>&1
useradd -m -u 88000 -g 99000 -s /bin/bash -d /home/ubuntu ubuntu >> /srv/dl/install.log 2>&1
echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chown ubuntu:ubuntu /home/ubuntu >> /srv/dl/install.log 2>&1
usermod -G vagrant ubuntu >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

fi


export DEBIAN_FRONTEND=noninteractive


if [ $vm_setup_ready_flag -eq 0 ]; then

START=$(date +%s)
echo "update package list..."

echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90forceyes
echo 'APT::Get::force-yes "true";' >> /etc/apt/apt.conf.d/90forceyes

# --------- update index 1 ---------
# --------- update index 1 ---------
apt-get update >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
# --------- update index 1 ---------
# --------- update index 1 ---------




apt-get install -m -q -y bc >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi

fi



#----------
# build num
#----------
echo "get build number..."

yy="0""`cat /srv/dl/_buildnum_.txt 2>/dev/null`"
yy=`echo "$yy" | bc 2> /dev/null`

if [ "$yy""x" == "x" ]; then
	yy="0"
fi

__CI_BUILDNUM=$[ $yy + 1]
__CI_BUILDNUM_M_1=$[ $__CI_BUILDNUM - 1 ]

if [ $vm_setup_ready_flag -eq 0 ]; then
	:
else
	echo "save build number..."
	echo "$__CI_BUILDNUM" > /srv/dl/_buildnum_.txt
	chmod a+rw /srv/dl/_buildnum_.txt
fi

export __CI_BUILDNUM
export __CI_BUILDNUM_M_1

#----------
# build num
#----------


if [ $vm_setup_ready_flag -eq 0 ]; then

echo "install packages..."

# tzdata --> sometimes changes system time :-(

apt-get install -m -q -y wamerican >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
echo dictionaries-common dictionaries-common/default-wordlist select 'american (American English)' | debconf-set-selections
echo dictionaries-common dictionaries-common/default-ispell select 'american (American English)' | debconf-set-selections

apt-get install -m -q -y dictionaries-common >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi

apt-get install -m -q -y python-software-properties >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi

# add gradle repo
printf '\n' | add-apt-repository ppa:cwchien/gradle >> /srv/dl/install.log 2>&1
# add jdk1.8 repo
printf '\n' | apt-add-repository ppa:webupd8team/java >> /srv/dl/install.log 2>&1
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
# add svn 1.7 repo
# apt-key adv --keyserver keyserver.ubuntu.com --recv-key A2F4C039
# printf '\n' | add-apt-repository ppa:svn/ppa >> /srv/dl/install.log 2>&1
# add svn 1.8 repo
printf '\n' | add-apt-repository ppa:dominik-stadler/subversion-1.8 >> /srv/dl/install.log 2>&1


# --------- update index 2 ---------
# --------- update index 2 ---------
apt-get update >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
# --------- update index 2 ---------
# --------- update index 2 ---------


apt-get install -m -q -y gradle-2.10 >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y g++ make git curl vim htop mc zip >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y subversion >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y libc6:i386 libncurses5:i386 libstdc++6:i386 >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y imagemagick maven gradle >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y wget unzip openjdk-7-jdk >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y xvfb xdotool telnet x11-utils xvkbd >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y xterm jq libyaml-ruby ruby-json >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y mesa-utils ant iftop >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y libiconv-hook-dev gettext libsaxonb-java >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y libz-dev libz-dev:i386 libz1 libz1:i386 >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi
apt-get install -m -q -y oracle-java8-installer >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi

## large package list ##
cat /srv/tools/pkgs.txt | xargs -L10 apt-get -m -q -y install >> /srv/dl/install.log 2>&1
## large package list ##

# set java to 1.7 again (gradle moves it back to 1.6) [jdk sets it to 1.8]
update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java >> /srv/dl/install.log 2>&1
update-alternatives --set javac /usr/lib/jvm/java-7-openjdk-amd64/bin/javac >> /srv/dl/install.log 2>&1


update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX >> /srv/dl/install.log 2>&1
# export LANGUAGE=en_US.UTF-8
# locale-gen en_US.UTF-8 >> /srv/dl/install.log 2>&1
dpkg-reconfigure locales >> /srv/dl/install.log 2>&1


END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


fi


if [ $vm_setup_ready_flag -eq 0 ]; then


START=$(date +%s)
echo "install webserver..."

apt-get install -m -q -y apache2 >> /srv/dl/install.log 2>&1
res=$? ; if [ $res -ne 0 ];then exit 1;fi

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /www_srv /var/www
fi

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

fi




if [ $vm_setup_ready_flag -eq 0 ]; then


START=$(date +%s)
echo "download SDK..."
# SDK
wget --continue "https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" -O /srv/dl/sdk_24.4.1.tgz >> /srv/dl/install.log 2>&1
END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

START=$(date +%s)
echo "download NDK..."
# NDK
# wget --continue 'http://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip' -O /srv/dl/ndk_12b.zip >> /srv/dl/install.log 2>&1
# wget --continue 'http://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip' -O /srv/dl/ndk_11c.zip >> /srv/dl/install.log 2>&1
wget --continue 'http://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip' -O /srv/dl/ndk_10e.zip >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


START=$(date +%s)
echo "install NDK/SDK..."

mkdir -p /usr/local/ >> /srv/dl/install.log 2>&1

# NDK ----------
# cd /usr/local/ && unzip /srv/dl/ndk_12b.zip >> /srv/dl/install.log 2>&1
# cd /usr/local/ && ln -sf android-ndk-r12b android-ndk >> /srv/dl/install.log 2>&1
# cd /usr/local/ && unzip /srv/dl/ndk_11c.zip >> /srv/dl/install.log 2>&1
# cd /usr/local/ && ln -sf android-ndk-r11c android-ndk >> /srv/dl/install.log 2>&1
cd /usr/local/ && unzip /srv/dl/ndk_10e.zip >> /srv/dl/install.log 2>&1
cd /usr/local/ && ln -sf android-ndk-r10e android-ndk >> /srv/dl/install.log 2>&1

cd /usr/local/ && chmod -R a+rx android-ndk >> /srv/dl/install.log 2>&1
# NDK ----------

cd /usr/local/ && tar -xzvf /srv/dl/sdk_24.4.1.tgz >> /srv/dl/install.log 2>&1
cd /usr/local/ && chown -R root:root android-sdk-linux >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


START=$(date +%s)
echo "start Xvfb..."

cp /srv/tools/start_xvfb.sh /usr/local/bin/start_xvfb.sh >> /srv/dl/install.log 2>&1
chmod u+rwx /usr/local/bin/start_xvfb.sh >> /srv/dl/install.log 2>&1

ps -ef |grep 'Xvfb'  >> /srv/dl/install.log 2>&1

/usr/local/bin/start_xvfb.sh stop >> /srv/dl/install.log 2>&1
sleep 1
/usr/local/bin/start_xvfb.sh stop >> /srv/dl/install.log 2>&1
sleep 1
/usr/local/bin/start_xvfb.sh start >> /srv/dl/install.log 2>&1

ps -ef |grep 'Xvfb'  >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


fi


# echo "checking Xvfb..."
# ps -ef |grep 'Xvfb'  >> /srv/dl/install.log 2>&1
# ls -al /usr/local/bin/start_xvfb.sh



/bin/bash /srv/tools/repo_stats.sh >> /srv/dl/install.log 2>&1

#  __REPO_COMMITHASH
#  __REPO_URL
#  __REPO_BASEDIR
#  __CI_BUILDNUM
#  __CI_BUILDNUM_M_1
#  __REPO_USER
#  __REPO_PASS
#  __REPO_TYPE

. /tmp/_git_vars.sh


echo "saving copy of profile..."
cp -av /etc/profile /tmp/profile_save >> /srv/dl/install.log 2>&1

echo '

################ CI ################
################ CI ################
ADB_INSTALL_TIMEOUT=10
ANDROID_HOME=/usr/local/android-sdk-linux
ANDROID_NDK=/usr/local/android-ndk
CI_PULL_REQUEST=
CI_PULL_REQUESTS=
CIRCLE_ARTIFACTS=/www_srv/'"$__CI_BUILDNUM"'/circle-artifacts/
CIRCLE_BRANCH=debug001
CIRCLE_BUILD_IMAGE=ubuntu-12.04
CIRCLE_BUILD_NUM='"$__CI_BUILDNUM"'
CIRCLE_BUILD_URL=https://127.0.0.1/gh/'"$__REPO_USER"'/'"$__REPO_BASEDIR"'/'"$__CI_BUILDNUM"'
CIRCLECI=true
CIRCLE_COMPARE_URL='"$__REPO_URL"'
CIRCLE_NODE_INDEX=0
CIRCLE_NODE_TOTAL=1
CIRCLE_PREVIOUS_BUILD_NUM='"$__CI_BUILDNUM_M_1"'
CIRCLE_PROJECT_REPONAME='"$__REPO_BASEDIR"'
CIRCLE_PROJECT_USERNAME='"$__REPO_USER"'
CIRCLE_REPOSITORY_URL='"$__REPO_URL"'
CIRCLE_SHA1='"$__REPO_COMMITHASH"'
CIRCLE_TEST_REPORTS=/www_srv/'"$__CI_BUILDNUM"'/circle-junit/
CIRCLE_USERNAME='"$__REPO_USER"'
CI_REPORTS=/www_srv/'"$__CI_BUILDNUM"'/circle-junit/
CI=true
DISPLAY=:99

PATH=$PATH:/usr/local/android-sdk-linux/tools:/usr/local/android-sdk-linux/platform-tools:/usr/local/android-ndk

if [ -d "/home/ubuntu/bin" ] ; then
    PATH="/home/ubuntu/bin:$PATH"
fi

DEBIAN_FRONTEND=noninteractive

export ADB_INSTALL_TIMEOUT ANDROID_HOME ANDROID_NDK CI_PULL_REQUEST CI_PULL_REQUESTS CIRCLE_ARTIFACTS CIRCLE_BRANCH
export CIRCLE_BUILD_IMAGE CIRCLE_BUILD_NUM CIRCLE_BUILD_URL CIRCLECI CIRCLE_COMPARE_URL CIRCLE_NODE_INDEX CIRCLE_NODE_TOTAL
export CIRCLE_PREVIOUS_BUILD_NUM CIRCLE_PROJECT_REPONAME CIRCLE_PROJECT_USERNAME CIRCLE_REPOSITORY_URL CIRCLE_SHA1 
export CIRCLE_TEST_REPORTS CIRCLE_USERNAME CI_REPORTS CI
export PATH DISPLAY
export DEBIAN_FRONTEND

################ CI ################
################ CI ################
' >> /etc/profile


. /etc/profile >> /srv/dl/install.log 2>&1


######### output dirs #########
printf '. /etc/profile ; mkdir -p $CI_REPORTS \n' | su - ubuntu >> /srv/dl/install.log 2>&1
printf '. /etc/profile ; mkdir -p $CIRCLE_ARTIFACTS \n' | su - ubuntu >> /srv/dl/install.log 2>&1
######### output dirs #########



if [ $vm_setup_ready_flag -eq 0 ]; then


START=$(date +%s)
echo "install Android APIs..."

have_apis=0
if [ `ls -1 /srv/dl/android_apis.tar.gz 2>/dev/null`"x" != "x" ]; then
	have_apis=1
fi

if [ $have_apis -eq 0 ]; then
	###################### SDK ######################
	###################### SDK ######################
	echo y | android update sdk --no-ui --all --filter platform-tools >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter tools >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter build-tools-23.0.0 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter build-tools-23.0.1 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter build-tools-23.0.2 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter build-tools-23.0.3 >> /srv/dl/install.log 2>&1

	echo y | android update sdk --no-ui --all --filter android-4 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-8 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-9 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-10 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-15 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-21 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-22 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-23 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter android-24 >> /srv/dl/install.log 2>&1

	echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-21 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-22 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-23 >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-24 >> /srv/dl/install.log 2>&1

	echo y | android update sdk --no-ui --all --filter extra-android-support >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter extra-google-google_play_services >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter extra-google-m2repository >> /srv/dl/install.log 2>&1
	echo y | android update sdk --no-ui --all --filter extra-android-m2repository >> /srv/dl/install.log 2>&1
	###################### SDK ######################
	###################### SDK ######################

	cd /usr/local/ && tar -czvf /srv/dl/android_apis.tar.gz android-sdk-linux >> /srv/dl/install.log 2>&1
else
	cd /usr/local/ && tar -xzvf /srv/dl/android_apis.tar.gz >> /srv/dl/install.log 2>&1
fi

# writeable by all, so update as normal user is possible
cd /usr/local/ && chmod -R a+rxw android-sdk-linux >> /srv/dl/install.log 2>&1


cp /srv/tools/fb-adb /usr/bin/fb-adb >> /srv/dl/install.log 2>&1
chmod a+rx /usr/bin/fb-adb >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


fi


# fix ACLs: writeable by all, so update as normal user is possible
cd /usr/local/ && chmod -R a+rxw android-sdk-linux >> /srv/dl/install.log 2>&1
# fix ACLs
cd /usr/local/ && chmod -R a+rx android-ndk >> /srv/dl/install.log 2>&1



cp /srv/tools/circle-android /usr/bin/circle-android >> /srv/dl/install.log 2>&1
chmod a+rx /usr/bin/circle-android >> /srv/dl/install.log 2>&1

if [ $vm_setup_ready_flag -eq 0 ]; then
	# tweak "apt-get install" ------ 1 ----------------
	cp -av /usr/bin/apt-get /usr/bin/apt-get.ORIG
	echo '#!/bin/bash
	export DEBIAN_FRONTEND=noninteractive
	/usr/bin/apt-get.ORIG -y -m "$@"
	' > /usr/bin/apt-get

	chown root:root /usr/bin/apt-get
	chmod a+rx /usr/bin/apt-get
	chmod u+x /usr/bin/apt-get
	# tweak "apt-get install" ------ 1 ----------------
else
	# tweak "apt-get install" ------ 2 ----------------
	echo '#!/bin/bash
	export DEBIAN_FRONTEND=noninteractive
	/usr/bin/apt-get.ORIG -y -m "$@"
	' > /usr/bin/apt-get

	chown root:root /usr/bin/apt-get
	chmod a+rx /usr/bin/apt-get
	chmod u+x /usr/bin/apt-get
	# tweak "apt-get install" ------ 2 ----------------
fi

if [ $vm_setup_ready_flag -eq 0 ]; then
	:
else
	echo "getting source from git..."
	/bin/bash /srv/tools/repo_get.sh >> /srv/dl/install.log 2>&1
fi


sync_install_log_



if [ $vm_setup_ready_flag -eq 0 ]; then
	:
else

START=$(date +%s)
echo "running tests..."

######## TEST ########
######## TEST ########

printf "cd $CIRCLE_PROJECT_REPONAME"' \n chmod a+rx /srv/tools/test.sh \n /srv/tools/test.sh \n' | su - ubuntu 2>&1 | tee -a /srv/dl/install.log

export _must_exit_=`cat /tmp/_must_exit_`
export _exit_code_=`cat /tmp/_exit_code_`

sync_install_log_

if [ "$_must_exit_""x" != "0x" ];then
	exit $_exit_code_
fi

######## TEST ########
######## TEST ########

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

fi


if [ $vm_setup_ready_flag -eq 0 ]; then
	# restore /etc/profile after setup, for next run!
	echo "restoring state..."
	cp -av /tmp/profile_save /etc/profile >> /srv/dl/install.log 2>&1
	rm -f /tmp/_git_vars.sh
	echo "...ready"

	# set flag that VM setup is done
	echo "set setup-ready flag..."
	touch "$vm_setup_ready_file"

	sync

	sleep 15
fi


echo "...ready"
END_ALL=$(date +%s); echo $((END_ALL-START_ALL)) | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}'
