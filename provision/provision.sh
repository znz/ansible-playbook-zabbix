#!/bin/sh
set -e
apt-get install -y ansible
ansible-playbook /vagrant/provision/site.yml --connection=local
