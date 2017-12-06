#!/bin/bash
iptables -F
iptables -X
iptables -Z

iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

#iptables -A INPUT -f -m limit --limit 20/s --limit-burst 100 -j ACCEPT
#iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 10 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -m limit --limit 20/s --limit-burst 200 -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
