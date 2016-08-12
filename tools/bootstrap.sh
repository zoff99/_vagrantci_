#!/usr/bin/env bash

echo "configuring CI machine..."


# circleCI specific ---
groupadd -g 99000 ubuntu
useradd -m -u 1000 -g 99000 -s /bin/bash -d /home/ubuntu ubuntu
echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chown ubuntu:ubuntu /home/ubuntu

apt-get update --fix-missing
apt-get install -q -y g++ make git curl vim htop bc mc wget

# install packages
cat /srv/tools/circle_pkgs.txt
cat /srv/tools/circle_pkgs.txt | xargs -L10 apt-get install

apt-get install -y apache2

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /www_srv /var/www
fi

mkdir /d/

# SDK
wget "https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" -O /d/sdk_24.4.1.zip


# NDK
wget "http://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip" -O /d/ndk_12b.zip


echo "...ready"
