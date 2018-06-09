#! /bin/bash

### BEGIN INIT INFO
# Provides: sudo
# Required-Start: $local_fs $remote_fs
# Required-Stop:
# X-Start-Before: rmnologin
# Default-Start: 2 3 4 5
# Default-Stop:
# Short-Description: Provide limited super user privileges to specific users
# Description: Provide limited super user privileges to specific users.
### END INIT INFO


#Convertir en enrutador

echo 1 > /proc/sys/net/ipv4/ip_forward


#Flush de reglas IPTABLES

iptables -F
iptables -X
iptables -Z
iptables -t nat -F


#Permitir todo por defecto

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP




###########DNS


iptables -A OUTPUT -p tcp --dport 53 -o eth0 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -i eth0 -j ACCEPT

iptables -A OUTPUT -p udp --dport 53 -o eth0 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -i eth0 -j ACCEPT



#DNS para red aula y DMZ


iptables -A FORWARD -p tcp --dport 53  -j ACCEPT
iptables -A FORWARD -p tcp --sport 53  -j ACCEPT

iptables -A FORWARD -p udp --dport 53  -j ACCEPT
iptables -A FORWARD -p udp --sport 53  -j ACCEPT




###########HTTP & HTTPS


iptables -A INPUT -p tcp --dport 80 -i eth0 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -o eth0 -j ACCEPT

iptables -A INPUT -p tcp --dport 443 -i eth0 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -o eth0 -j  ACCEPT

iptables -A  OUTPUT -p tcp --sport 10000 -o eth0 -j  ACCEPT
iptables -A INPUT -p tcp --dport 10000 -i eth0 -j ACCEPT


#Permitir la entrada y salida a squid
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3128 -j ACCEPT

#Permitir la entrada y salida a Dansguardian
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8080 -j ACCEPT


#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 3128 -j REDIRECT --to-port                                                                                         8080




#Permitir que la red 191.168.11.0/24 tenga salida al exterior por el interfaz et                                                                                        h0
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.11.0/24 -j MASQUERADE


#Aunque ya está prohibido por defecto, se prohibe que ninguna otra conexión web                                                                                         sea posible a menos que se use proxy
#iptables -A FORWARD -s 192.168.11.0/24 -i eth1 -p tcp --dport 80 -j DROP
#iptables -A FORWARD -s 192.168.11.0/24 -i eth1 -p tcp --dport 443 -j DROP







#Redireccionar los puertos 80 y 443 para Dansguardian (http y https)
#iptables -t nat -A PREROUTING -s 192.168.11.0/24 -p tcp --dport 80 -j REDIRECT                                                                                         --to-port 8080
#iptables -t nat -A PREROUTING -s 192.168.11.0/24 -p tcp --dport 443 -j REDIRECT                                                                                         --to-port 8080




#################ICMP


iptables -A OUTPUT -p icmp -o eth0 -j ACCEPT
iptables -A INPUT -p icmp -i eth0 -j ACCEPT

#RED CLASE

iptables -A OUTPUT -p icmp -o eth1 -j ACCEPT
iptables -A INPUT -p icmp -i eth1 -j ACCEPT

#RED DMZ

iptables -A OUTPUT -p icmp -o eth2 -j ACCEPT
iptables -A INPUT -p icmp -i eth2 -j ACCEPT




#################SSH


iptables -A INPUT -p tcp --dport 22 -i eth0 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -o eth0 -j ACCEPT



#RED CLASE

iptables -A OUTPUT -p tcp --dport 22 -o eth1 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -i eth1 -j ACCEPT

#RED DMZ

iptables -A OUTPUT -p tcp --dport 22 -o eth2 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -i eth2 -j ACCEPT




#################FTP


iptables -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
iptables -A INPUT -p tcp --sport 20:21 -j ACCEPT


#RED CLASE

iptables -A FORWARD  -p tcp --sport 20:21 -j ACCEPT
iptables -A FORWARD  -p tcp --dport 20:21 -j ACCEPT

#iptables -A INPUT -p tcp --sport 20:21 -i eth1 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 20:21 -o eth1 -j ACCEPT


#RED DMZ

iptables -A OUTPUT -p tcp --dport 20:21 -o eth2 -j ACCEPT
iptables -A INPUT -p tcp --sport 20:21 -i eth2 -j ACCEPT