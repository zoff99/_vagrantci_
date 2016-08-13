#!/usr/bin/env bash


START_ALL=$(date +%s)

START=$(date +%s)
echo "configuring CI machine..."

# circleCI specific ---
groupadd -g 99000 ubuntu >> /srv/dl/install.log 2>&1
useradd -m -u 88000 -g 99000 -s /bin/bash -d /home/ubuntu ubuntu >> /srv/dl/install.log 2>&1
echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chown ubuntu:ubuntu /home/ubuntu >> /srv/dl/install.log 2>&1
usermod -G vagrant ubuntu >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


START=$(date +%s)
echo "install packages..."

# apt-get update --fix-missing
apt-get update >> /srv/dl/install.log 2>&1

/usr/share/debconf/fix_db.pl >> /srv/dl/install.log 2>&1
dpkg-reconfigure dictionaries-common >> /srv/dl/install.log 2>&1

apt-get install -m -q -y g++ make git curl vim htop bc mc >> /srv/dl/install.log 2>&1
apt-get install -m -q -y imagemagick >> /srv/dl/install.log 2>&1
apt-get install -m -q -y wget unzip openjdk-7-jdk >> /srv/dl/install.log 2>&1
apt-get install -m -q -y xvfb xdotool telnet x11-utils xvkbd >> /srv/dl/install.log 2>&1
apt-get install -m -q -y xterm jq libyaml-ruby ruby-json >> /srv/dl/install.log 2>&1
apt-get install -m -q -y mesa-utils >> /srv/dl/install.log 2>&1

/usr/share/debconf/fix_db.pl >> /srv/dl/install.log 2>&1
dpkg-reconfigure dictionaries-common >> /srv/dl/install.log 2>&1

# cat /srv/tools/circle_pkgs.txt | xargs -L10 apt-get -m -q -y install >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

START=$(date +%s)
echo "install webserver..."

apt-get install -m -q -y apache2 >> /srv/dl/install.log 2>&1

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /www_srv /var/www
fi

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


START=$(date +%s)
echo "download SDK..."
# SDK
wget --continue "https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" -O /srv/dl/sdk_24.4.1.tgz >> /srv/dl/install.log 2>&1
END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

START=$(date +%s)
echo "download NDK..."
# NDK
wget --continue "http://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip" -O /srv/dl/ndk_12b.zip >> /srv/dl/install.log 2>&1
END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


START=$(date +%s)
echo "install NDK/SDK..."

mkdir -p /usr/local/ >> /srv/dl/install.log 2>&1
cd /usr/local/ && unzip /srv/dl/ndk_12b.zip >> /srv/dl/install.log 2>&1
cd /usr/local/ && ln -sf android-ndk-r12b android-ndk >> /srv/dl/install.log 2>&1
cd /usr/local/ && tar -xzvf /srv/dl/sdk_24.4.1.tgz >> /srv/dl/install.log 2>&1
cd /usr/local/ && chown -R root:root android-sdk-linux >> /srv/dl/install.log 2>&1
END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

START=$(date +%s)
echo "start Xvfb..."

cp /srv/tools/start_xvfb.sh /usr/local/bin/start_xvfb.sh >> /srv/dl/install.log 2>&1
chmod u+rwx /usr/local/bin/start_xvfb.sh >> /srv/dl/install.log 2>&1
/usr/local/bin/start_xvfb.sh start >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

echo '

################ CI ################
################ CI ################
ADB_INSTALL_TIMEOUT=10
ANDROID_HOME=/usr/local/android-sdk-linux
ANDROID_NDK=/usr/local/android-ndk
CI_PULL_REQUEST=
CI_PULL_REQUESTS=
CIRCLE_ARTIFACTS=/www_srv/1/circle-artifacts/
CIRCLE_BRANCH=debug002
CIRCLE_BUILD_IMAGE=ubuntu-12.04
CIRCLE_BUILD_NUM=1
CIRCLE_BUILD_URL=https://127.0.0.1/gh/zoff99/zanavi/1
CIRCLECI=true
CIRCLE_COMPARE_URL=https://github.com
CIRCLE_NODE_INDEX=0
CIRCLE_NODE_TOTAL=1
CIRCLE_PREVIOUS_BUILD_NUM=0
CIRCLE_PROJECT_REPONAME=zanavi
CIRCLE_PROJECT_USERNAME=zoff99
CIRCLE_REPOSITORY_URL=https://github.com/zoff99/zanavi
CIRCLE_SHA1=5fcc91cb99a146b1c7e46eb798573d88c4f337b7
CIRCLE_TEST_REPORTS=/www_srv/1/circle-junit/
CIRCLE_USERNAME=zoff99
CI_REPORTS=/www_srv/1/circle-junit/
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

. /etc/profile >> /srv/dl/install.log 2>&1


######### output dirs #########
printf '. /etc/profile ; mkdir -p $CI_REPORTS \n' | su - ubuntu >> /srv/dl/install.log 2>&1
printf '. /etc/profile ; mkdir -p $CIRCLE_ARTIFACTS \n' | su - ubuntu >> /srv/dl/install.log 2>&1
######### output dirs #########


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
        echo y | android update sdk --no-ui --all --filter build-tools-23.0.1 >> /srv/dl/install.log 2>&1

        echo y | android update sdk --no-ui --all --filter android-10 >> /srv/dl/install.log 2>&1
        echo y | android update sdk --no-ui --all --filter android-21 >> /srv/dl/install.log 2>&1
        # echo y | android update sdk --no-ui --all --filter android-23 >> /srv/dl/install.log 2>&1
        # echo y | android update sdk --no-ui --all --filter android-24 >> /srv/dl/install.log 2>&1

        echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-21 >> /srv/dl/install.log 2>&1

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

cp /srv/tools/circle-android /usr/bin/circle-android >> /srv/dl/install.log 2>&1
chmod a+rx /usr/bin/circle-android >> /srv/dl/install.log 2>&1

cp /srv/tools/fb-adb /usr/bin/fb-adb >> /srv/dl/install.log 2>&1
chmod a+rx /usr/bin/fb-adb >> /srv/dl/install.log 2>&1

END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'


/bin/bash /srv/tools/repo_stats.sh >> /srv/dl/install.log 2>&1
/bin/bash /srv/tools/repo_get.sh >> /srv/dl/install.log 2>&1


START=$(date +%s)
echo "running tests..."

######## TEST ########
######## TEST ########

printf 'chmod a+rx /srv/tools/test.sh \n /srv/tools/test.sh \n' | su - ubuntu >> /srv/dl/install.log 2>&1

######## TEST ########
######## TEST ########


END=$(date +%s) ; echo $((END-START)) | awk '{printf "%d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'

echo "...ready"
END_ALL=$(date +%s); echo $((END_ALL-START_ALL)) | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}'
