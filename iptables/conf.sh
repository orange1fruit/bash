#!/bin/bash

export ipt="iptables"
# test title
# wan
export wan=ens160
export wan_ip=213.33.236.86

# lan
export lan=ens32
export lan_ip_range=192.168.0.0/23

# flush & delete chain
$ipt -F
$ipt -F -t nat
$ipt -F -t mangle
$ipt -X
$ipt -t nat -X
$ipt -t mangle -X

# create chain
$ipt -N SSH
$ipt -N ASTERISK
$ipt -N FREEPBX
$ipt -N ISCSI
$ipt -N ICMP

# Deny everything that is not allowed
$ipt -P INPUT DROP
$ipt -P OUTPUT DROP
$ipt -P FORWARD DROP

# routing for other chain
$ipt -A INPUT -j SSH
$ipt -A INPUT -j ASTERISK
$ipt -A INPUT -j FREEPBX
$ipt -A INPUT -j ISCSI
$ipt -A INPUT -j ICMP


# hmmm
$ipt -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$ipt -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

# permit localhost & out
$ipt -A INPUT -i lo -j ACCEPT
$ipt -A OUTPUT -o lo -j ACCEPT
$ipt -A OUTPUT -o $lan -j ACCEPT
$ipt -A OUTPUT -o $wan -j ACCEPT

# permit icmp
$ipt -A ICMP -i $lan -p icmp --icmp-type 3 -j ACCEPT
$ipt -A ICMP -i $lan -p icmp --icmp-type 8 -j ACCEPT
$ipt -A ICMP -i $lan -p icmp --icmp-type 12 -j ACCEPT

# permit iscsi
$ipt -A ISCSI -i $lan -s 192.168.3.96 -p 6 -m multiport --dport 3260,860 -j ACCEPT
$ipt -A ISCSI -i $lan -s 192.168.3.96 -p 17 -m multiport --dport 3260,860 -j ACCEPT

# permit ssh
$ipt -A SSH -p 6 --dport 22 -j ACCEPT

# permit asterisk
# $ipt -A INPUT -i $wan -p 6 --dport 5060 -j ACCEPT
$ipt -A ASTERISK -p 17 -m multiport --dport 10000:40000 -j ACCEPT
$ipt -A ASTERISK -p 17 -m multiport --dport 5060,5160 -j ACCEPT
$ipt -A ASTERISK -i $lan -p 17 --dport 4569 -j ACCEPT

# permit freepbx

$ipt -A FREEPBX -i $lan -p 6 --dport 80 -j ACCEPT
$ipt -A FREEPBX -i $lan -p 6 --dport 81 -j ACCEPT

fail2ban-client start

# backup

# iptables-save

/usr/sbin/iptables-save > /scripts/iptables/backup
