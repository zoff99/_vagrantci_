#! /bin/bash

#if [ -f /etc/provision_env_disk_added_date ]
#then
#   echo "Provision runtime already done."
#   exit 0
#fi

pkill -9 -u ubuntu > /dev/null 2>&1
umount -f /dev/sdb1 > /dev/null 2>&1
umount -f /dev/sdb1 > /dev/null 2>&1

fdisk -u /dev/sdb <<EOF > /dev/null 2>&1
n
p
1


w
EOF

mkfs.ext4 /dev/sdb1 > /dev/null 2>&1
mkdir -p /home/ubuntu > /dev/null 2>&1
mount -t ext4 /dev/sdb1 /home/ubuntu

date > /etc/provision_env_disk_added_date 2>/dev/null

