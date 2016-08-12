#!/usr/bin/env bash

echo "configuring CI machine..."


# circleCI specific ---
groupadd -g 1000 ubuntu
useradd -m -u 1000 -g 1000 -s /bin/bash -d /home/ubuntu ubuntu"
echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
chown ubuntu:ubuntu /home/ubuntu"

apt-get update --fix-missing"
apt-get install -q -y g++ make git curl vim htop bc"


apt-get install -y apache2

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

echo "...ready"
