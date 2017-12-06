#!/bin/bash
iptables -F
iptables -X
iptables -Z

iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
