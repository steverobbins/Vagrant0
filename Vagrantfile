# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box       = "chef/centos-6.5"
  config.vm.host_name = "192.168.50.100.xip.io"
  
  config.vm.provision     :shell, :path => "bootstrap.sh"
  config.vm.network       :forwarded_port, guest: 80, host: 8081
  config.vm.synced_folder "~/html", "/var/www/html"
  config.vm.synced_folder "~/Project/n98-magerun", "/root/n98-magerun"
  config.vm.network       "private_network", ip: "192.168.50.100"

  config.vm.provider :virtualbox do |vb|
    vb.customize [
        "modifyvm", :id,
        "--memory", "4096",
    ]
    vb.name = "192.168.50.100.xip.io"
  end
end
