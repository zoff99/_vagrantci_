#

ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.hostname = "circleci.box"
  config.vm.network :private_network, ip: "192.168.77.33"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.ssh.username = "vagrant"

  hostname = "circleci.box"
  locale = "en_GB.UTF-8"

  # Shared folders
  config.vm.synced_folder ".", "/srv"
  config.vm.synced_folder "..", "/code_base"
  config.vm.synced_folder "www/", "/www_srv", create: true

  # Setup
  config.vm.provision :shell, :inline => "touch .hushlogin"

  # configure the machine
  config.vm.provision :shell, path: "tools/bootstrap.sh"

end
