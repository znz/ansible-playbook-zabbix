#!/bin/sh
set -ex
: ${UFW=ufw}

# default policies
$UFW -f enable
$UFW default deny
#$UFW default reject outgoing
$UFW default allow outgoing

# minimum ports
$UFW allow out 53
$UFW allow out 80/tcp
$UFW allow out 443/tcp
$UFW allow out 123/udp

# sshd
$UFW limit 22/tcp

# nginx
$UFW allow 80/tcp

# zabbix-agent
$UFW allow out 10050/tcp
