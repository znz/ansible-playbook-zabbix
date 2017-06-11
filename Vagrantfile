# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = ENV['VM_HOSTNAME'] || 'zbx.127.0.0.1.nip.io'
  config.vm.box = 'debian/stretch64'

  config.vm.network :forwarded_port, guest: 80, host: 2680

  config.vm.provider 'virtualbox' do |vb|
    # Don't boot with headless mode
    vb.gui = true if ENV['VM_GUI']

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || '512']

    vb.cpus = 2
    vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
    vb.customize [
      'modifyvm', :id,
      '--hwvirtex', 'on',
      '--nestedpaging', 'on',
      '--largepages', 'on',
      '--ioapic', 'on',
      '--pae', 'on',
      '--paravirtprovider', 'kvm',
    ]
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'provision/playbook.yml'
    ansible.verbose = ENV['ANSIBLE_VERBOSE'] if ENV['ANSIBLE_VERBOSE']
    ansible.tags = ENV['ANSIBLE_TAGS'] if ENV['ANSIBLE_TAGS']

    ansible.galaxy_role_file = 'provision/requirements.yml'
    unless ENV['ANSIBLE_GALAXY_WITH_FORCE']
      # without --force
      ansible.galaxy_command = 'ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}'
    end
    ansible.extra_vars = {
      nadoka_fprog_irc_host: ENV['NADOKA_FPROG_IRC_HOST'],
      nadoka_fprog_irc_port: ENV['NADOKA_FPROG_IRC_PORT'],
      nadoka_fprog_irc_pass: ENV['NADOKA_FPROG_IRC_PASS'],
      nadoka_fprog_channel_info: ENV['NADOKA_FPROG_CHANNEL_INFO'],
      nadoka_slack_irc_host: ENV['NADOKA_SLACK_IRC_HOST'],
      nadoka_slack_irc_port: ENV['NADOKA_SLACK_IRC_PORT'],
      nadoka_slack_irc_pass: ENV['NADOKA_SLACK_IRC_PASS'],
      nadoka_slack_irc_user: ENV['NADOKA_SLACK_IRC_USER'],
    }
  end
end
