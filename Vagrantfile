Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "CiviCRM"
  config.vm.network "forwarded_port", guest: 80, host: 8888
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "2048"
   end
end
