# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = ENV["VM_HOSTNAME"] || "ja-jp.127.0.0.1.xip.io"
  config.vm.box = 'trusty-server-cloudimg-amd64'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'

  #config.vm.network :forwarded_port, guest: 80, host: 3080

  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    vb.gui = true if ENV["VM_GUI"]

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", ENV["VM_MEMORY"] || "512"]
  end

  if ENV["ANSIBLE_REMOTE"]
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/site.yml"
      ansible.verbose = ENV["ANSIBLE_VERBOSE"] if ENV["ANSIBLE_VERBOSE"]
      ansible.tags = ENV["ANSIBLE_TAGS"] if ENV["ANSIBLE_TAGS"]
    end
  else
    config.vm.provision :shell, :path => 'provision/provision.sh'
  end
  config.vm.network :forwarded_port, guest: 80, host: 8022
end
