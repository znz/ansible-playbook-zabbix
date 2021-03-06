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
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || '1024']

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
    vars = {
      nadoka_fprog_irc_host: ENV['NADOKA_FPROG_IRC_HOST'],
      nadoka_fprog_irc_port: ENV['NADOKA_FPROG_IRC_PORT'],
      nadoka_fprog_irc_pass: ENV['NADOKA_FPROG_IRC_PASS'],
      nadoka_fprog_channel_info: ENV['NADOKA_FPROG_CHANNEL_INFO'],
      nadoka_slack_irc_host: ENV['NADOKA_SLACK_IRC_HOST'],
      nadoka_slack_irc_port: ENV['NADOKA_SLACK_IRC_PORT'],
      nadoka_slack_irc_pass: ENV['NADOKA_SLACK_IRC_PASS'],
      nadoka_slack_irc_nick: ENV['NADOKA_SLACK_IRC_NICK'],
      postfix_relay_smtp_server: ENV['SMTP_SERVER'],
      postfix_relay_smtp_user: ENV['SMTP_USER'],
      postfix_relay_smtp_pass: ENV['SMTP_PASS'],
      postfix_alias_root: ENV['MAIL_ALIAS_ROOT'],
      zabbix_nadoka_notice_sock: ENV['ZABBIX_NADOKA_NOTICE_SOCK'],
      local_zabbix_nasne: ENV['ZABBIX_NASNE'],
      openvpn_client: []
    }
    if ENV['OPENVPN_NAME']
      vars[:openvpn_client] << {
        name: ENV['OPENVPN_NAME'],
        proto: ENV['OPENVPN_PROTO'],
        host: ENV['OPENVPN_HOST'],
        port: ENV['OPENVPN_PORT'],
        cipher: ENV['OPENVPN_CIPHER'],
        auth: ENV['OPENVPN_AUTH'],
        tls_cipher: ENV['OPENVPN_TLS_CIPHER'],
        ca_crt: ENV['OPENVPN_CA_CRT'],
        ta_key: ENV['OPENVPN_TA_KEY'],
        client_crt: ENV['OPENVPN_CLIENT_CRT'],
        client_key: ENV['OPENVPN_CLIENT_KEY'],
      }
    end
    ansible.extra_vars = vars
  end
end
