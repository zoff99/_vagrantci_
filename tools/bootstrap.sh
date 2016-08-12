#!/usr/bin/env bash

echo "configuring CI machine..."


# circleCI specific ---
groupadd -g 99000 ubuntu
useradd -m -u 1000 -g 99000 -s /bin/bash -d /home/ubuntu ubuntu
echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chown ubuntu:ubuntu /home/ubuntu

# apt-get update --fix-missing
apt-get update

apt-get install -m -q -y g++ make git curl vim htop bc mc
apt-get install -m -q -y imagemagick
apt-get install -m -q -y wget unzip openjdk-7-jdk
apt-get install -m -q -y xvfb xdotool telnet x11-utils xvkbd
apt-get install -m -q -y xterm

cat /srv/tools/circle_pkgs.txt | xargs -L10 apt-get -m -q -y install


apt-get install -m -q -y apache2

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /www_srv /var/www
fi


# SDK
wget --continue "https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" -O /srv/dl/sdk_24.4.1.tgz

# NDK
wget --continue "http://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip" -O /srv/dl/ndk_12b.zip

mkdir -p /usr/local/
cd /usr/local/ && unzip /srv/dl/ndk_12b.zip
cd /usr/local/ && ln -sf android-ndk-r12b android-ndk
cd /usr/local/ && tar -xzvf /srv/dl/sdk_24.4.1.tgz
cd /usr/local/ && chown -R root:root android-sdk-linux

cp /srv/tools/start_xvfb.sh /usr/local/bin/start_xvfb.sh
chmod u+rwx /usr/local/bin/start_xvfb.sh
/usr/local/bin/start_xvfb.sh start

echo '

################ CI ################
################ CI ################
ADB_INSTALL_TIMEOUT=10
ANDROID_HOME=/usr/local/android-sdk-linux
ANDROID_NDK=/usr/local/android-ndk
CI_PULL_REQUEST=
CI_PULL_REQUESTS=
CIRCLE_ARTIFACTS=/tmp/circle-artifacts.DRdrYJX
CIRCLE_BRANCH=debug002
CIRCLE_BUILD_IMAGE=ubuntu-12.04
CIRCLE_BUILD_NUM=786
CIRCLE_BUILD_URL=https://circleci.com/gh/zoff99/zanavi/786
CIRCLECI=true
CIRCLE_COMPARE_URL=https://github.com/zoff99/zanavi/compare/248311b0a304...5fcc91cb99a1
CIRCLE_NODE_INDEX=0
CIRCLE_NODE_TOTAL=1
CIRCLE_PREVIOUS_BUILD_NUM=785
CIRCLE_PROJECT_REPONAME=zanavi
CIRCLE_PROJECT_USERNAME=zoff99
CIRCLE_REPOSITORY_URL=https://github.com/zoff99/zanavi
CIRCLE_SHA1=5fcc91cb99a146b1c7e46eb798573d88c4f337b7
CIRCLE_TEST_REPORTS=/tmp/circle-junit.DqtzY5Z
CIRCLE_USERNAME=zoff99
CI_REPORTS=/tmp/circle-junit.DqtzY5Z
CI=true
DISPLAY=:99

PATH=$PATH:/usr/local/android-sdk-linux/tools:/usr/local/android-sdk-linux/platform-tools:/usr/local/android-ndk

if [ -d "/home/ubuntu/bin" ] ; then
    PATH="/home/ubuntu/bin:$PATH"
fi


export ADB_INSTALL_TIMEOUT ANDROID_HOME ANDROID_NDK CI_PULL_REQUEST CI_PULL_REQUESTS CIRCLE_ARTIFACTS CIRCLE_BRANCH
export CIRCLE_BUILD_IMAGE CIRCLE_BUILD_NUM CIRCLE_BUILD_URL CIRCLECI CIRCLE_COMPARE_URL CIRCLE_NODE_INDEX CIRCLE_NODE_TOTAL
export CIRCLE_PREVIOUS_BUILD_NUM CIRCLE_PROJECT_REPONAME CIRCLE_PROJECT_USERNAME CIRCLE_REPOSITORY_URL CIRCLE_SHA1
export CIRCLE_TEST_REPORTS CIRCLE_USERNAME CI_REPORTS CI
export PATH DISPLAY


################ CI ################
################ CI ################
' >> /etc/profile

. /etc/profile

echo y | android update sdk --no-ui --all --filter platform-tools
echo y | android update sdk --no-ui --all --filter "tools"
echo y | android update sdk --no-ui --all --filter build-tools-23.0.1

echo y | android update sdk --no-ui --all --filter android-10
echo y | android update sdk --no-ui --all --filter android-21
echo y | android update sdk --no-ui --all --filter android-23
echo y | android update sdk --no-ui --all --filter android-24


cp /srv/tools/circle-android /usr/bin/circle-android
chmod a+rx /usr/bin/circle-android

cp /srv/tools/fb-adb /usr/bin/fb-adb
chmod a+rx /usr/bin/fb-adb
