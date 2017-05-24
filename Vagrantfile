# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  Vagrant.configure("2") do |config|
    config.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "192.168.33.10"
    config.vm.network "forwarded_port", guest: 443, host: 443, host_ip: "192.168.33.10"
    config.vm.network "forwarded_port", guest: 3306, host: 3306
  end
  #config.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "192.168.33.10"

  # argument is a set of non-required options.
  config.vm.synced_folder "./www", "/var/www"
  config.vm.synced_folder ".", "/vagrant"

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |v|
      v.name = "lamp"
  end

  system("
      if [ #{ARGV[0]} = 'up' ]; then
          LOCAL_PATH='./www/'
          if [ ! -d ${LOCAL_PATH} ]; then
              mkdir ${LOCAL_PATH}
          fi
      fi
  ")

  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provision "shell", path: "shell/provision.sh"
  config.vm.provision "shell", path: "shell/up.sh", run: "always"
end
