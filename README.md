# ansible-playbook-zabbix

Zabbix with postgresql on Ubuntu 14.04

## Usage

- Setup using ansible
- open `http://zbx1404.127.0.0.1.xip.io/zabbix/` or `http://localhost:3080/zabbix/`

### Ansible in Guest OS

```
    % git clone https://github.com/znz/ansible-playbook-zabbix
    % cd ansible-playbook-zabbix
    % vagrant up
```

### Ansible from Host OS

```
    % git clone https://github.com/znz/ansible-playbook-zabbix
    % cd ansible-playbook-zabbix
    % ansible-galaxy install -f -p provision/roles -r provision/roles/Rolefile
    % ANSIBLE_REMOTE=1 vagrant up
```
