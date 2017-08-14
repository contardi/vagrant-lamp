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
  # via 127.0.0.1 to disable public access
  Vagrant.configure("2") do |config|
    config.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "192.168.50.10"
    config.vm.network "forwarded_port", guest: 443, host: 443, host_ip: "192.168.50.10"
    config.vm.network "forwarded_port", guest: 3306, host: 3306
  end

  # argument is a set of non-required options.
  config.vbguest.auto_update = true

  config.nfs.map_uid = Process.uid
  config.nfs.map_gid = Process.gid

  config.vm.synced_folder "./www", "/var/www",
    create: true,
    nfs: true,
    linux__nfs_options: ['rw','no_subtree_check','all_squash','async'],
    bsd__nfs_options: ['async', '-alldirs', '-mapall=501:20']

  config.vm.synced_folder "./shell", "/vagrant", nfs: true

  config.vm.network "private_network", ip: "192.168.50.10"

  config.vm.provider "virtualbox" do |v|
      v.name = "lamp.php7"
      v.memory = 1536
      v.cpus = 2
  end

  system("/bin/bash ./shell/host.sh #{ARGV[0]}")

  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provision "shell", path: "shell/provision.sh"
  config.vm.provision "shell", path: "shell/up.sh", run: "always"
end
