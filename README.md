# ansible-playbook-trusty

My template playbook with ja\_jp role.

## Usage

### Ansible in Guest OS

```
    % git clone https://github.com/znz/ansible-playbook-trusty
    % cd ansible-playbook-trusty
    % vagrant up
```

### Ansible from Host OS

```
    % git clone https://github.com/znz/ansible-playbook-trusty
    % cd ansible-playbook-trusty
    % ansible-galaxy install -f -p provision/roles -r provision/roles/Rolefile
    % ANSIBLE_REMOTE=1 vagrant up
```
