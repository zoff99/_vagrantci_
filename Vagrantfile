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


ENV["LC_ALL"] = "en_US.UTF-8"

# Vagrant.require_version ">= 1.8.0", "< 1.9.0"
Vagrant.configure("2") do |config|

#
# -------------- Hashicorp 12.04 LTS --------------
#  config.vm.box = "hashicorp/precise64"
#  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
# ---------------------------------------
#
# -------------- Ubuntu 14.04 LTS --------------
  config.vm.box = "ubuntu/trusty64"
# ---------------------------------------
#
# -------------- Bento 14.04 LTS --------------
# https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04/versions/2.2.9
  config.vm.box = "bento/ubuntu-14.04"
  config.vm.box_version = " =2.2.9"
# ---------------------------------------

#  this does not work on windows -------
#  config.vm.hostname = "circleci.box"
#  this does not work on windows -------

  config.vm.network :forwarded_port, guest: 80, host: 56999, id: "www", auto_correct: true
  config.vm.network :forwarded_port, guest: 22, host: 52999, id: "ssh", auto_correct: true
#  cXonfig.vm.network :private_network, ip: "192.168.77.33"


  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end

   config.vm.box_check_update = false

#  config.ssh.private_key_path = "./.vagrant/i_prv_key"
  config.ssh.username = "vagrant"
#  config.ssh.password = "vagrant"
  config.ssh.insert_key = false 
#  config.ssh.paranoid = false

  hostname = "circleci.box"
  locale = "en_US.UTF-8"

  # Shared folders
  config.vm.synced_folder ".", "/srv"
  config.vm.synced_folder "..", "/code_base"
  config.vm.synced_folder "www/", "/www_srv", create: true






  VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))
  file_to_disk = File.join(VAGRANT_ROOT, 'expand.vdi')
  config.vm.provision :shell, :inline => "echo ARG=" + ARGV[0]

  if ARGV[0] == "up"
      config.vm.provision :shell, :inline => "echo UP1"
      if File.exist?(file_to_disk)
        config.vm.provision :shell, :inline => "echo UNMOUNT"
        config.vm.provision :shell, :inline => "umount -f /dev/sdb1"
      end
  end

  config.vm.provider :virtualbox do |vb|
    if ARGV[0] == "up" && ! File.exist?(file_to_disk)
      config.vm.provision :shell, :inline => "echo UP2"
      vb.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', 80 * 1024]
    end
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
  end





  if ARGV[0] == "up"
    # partition the disk
    config.vm.provision :shell, :inline => "echo PART"
    config.vm.provision :shell, path: "tools/extra_disk.sh"
  end



  # Setup
  config.vm.provision :shell, :inline => "touch .hushlogin"

  # configure the machine
  config.vm.provision :shell, path: "tools/bootstrap.sh"

end
