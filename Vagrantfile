#

Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.hostname = "circleci.box"
  config.vm.network :private_network, ip: "192.168.77.33"

  hostname = "circleci.box"
  locale = "en_GB.UTF-8"

  # Shared folders
  config.vm.synced_folder ".", "/srv"

  # circleCI specific ---
  config.vm.provision :shell, :inline =>  "groupadd -g 1000 ubuntu"
  config.vm.provision :shell, :inline =>  "useradd -m -u 1000 -g 1000 -s /bin/bash -d /home/ubuntu ubuntu"
  config.vm.provision :shell, :inline =>  "echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
  config.vm.provision :shell, :inline =>  "chown ubuntu:ubuntu /home/ubuntu"
  # circleCI specific ---

  # Setup
  config.vm.provision :shell, :inline => "touch .hushlogin"
  config.vm.provision :shell, :inline => "hostnamectl set-hostname #{hostname} && locale-gen #{locale}"
  config.vm.provision :shell, :inline => "apt-get update --fix-missing"
  config.vm.provision :shell, :inline => "apt-get install -q -y g++ make git curl vim htop bc"

  #
  config.vm.provision :shell, path: "tools/bootstrap.sh"

end
