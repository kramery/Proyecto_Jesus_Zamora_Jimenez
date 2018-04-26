

#Convertir en enrutador
echo 1 > /proc/sys/net/ipv4/ip_forward

#Flush de reglas IPTABLES

iptables -F
iptables -X
iptables -Z
iptables -t nat -F


#Prohibir todo por defecto

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT





######HTTP & HTTPS 


iptables -A OUTPUT -p tcp --dport 80 -o eth0 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -i eth0 -j ACCEPT

iptables -A OUTPUT -p tcp --dport 443 -o eth0 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -i eth0 -j ACCEPT

iptables -A OUTPUT -p tcp --dport 53 -o eth0 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -i eth0 -j ACCEPT

iptables -A OUTPUT -p udp --dport 53 -o eth0 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -i eth0 -j ACCEPT


#Permitir que la red 191.168.11.0/24 tenga salida al exterior por el interfaz eth0
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.11.0/24 -j MASQUERADE

#Redireccionar los puertos 80 y 443 para squid (http y https)
iptables -t nat -A PREROUTING -s 192.168.11.0/24 -p tcp --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -s 192.168.11.0/24 -p tcp --dport 443 -j REDIRECT --to-port 3128

#Permitir la entrada y salida a squid
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3128 -j ACCEPT




