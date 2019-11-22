#!/bin/bash
case $1 in
	start)
		echo '--------------Starting this sheeet!----------------'
		ip=${2:-192.168.0.1}
		apInterface=${3:-wlan0}
		outInterface=${4:-eth0}
		echo 'IP set as:' $ip
		echo 'AP interface set as:' $apInterface
		echo 'Output interface set as:' $outInterface
		echo 'Killing network manager'
		airmon-ng check kill
		echo 'Configuring the AP interface'
		ifconfig $apInterface up
		ifconfig $apInterface $ip
		ifconfig $apInterface
		echo 'Reconfiguring iptables'
		iptables -t nat -F
		iptables -F
		iptables -t nat -A POSTROUTING -o $outInterface -j MASQUERADE
		iptables -A FORWARD -i $apInterface -o $outInterface -j ACCEPT
		iptables -L
		iptables -t nat -L
		echo 'Enable IP forwarding'
		echo '1' > /proc/sys/net/ipv4/ip_forward
		echo 'Starting Dnsmasq service'
		systemctl start dnsmasq
		echo 'Starting Hostapd service'
		systemctl start hostapd
		echo '----------All Bases r loaded and ready to go---------'
		;;
	stop)
		echo '--------Stopping that sheet!----------'
		echo 'Stopping services'
		systemctl stop hostapd
		systemctl stop dnsmasq
		echo 'Disable IP forwarding'
		echo '0' > /proc/sys/net/ipv4/ip_forward
		echo 'Flushing iptables'
		iptables -t nat -F
		iptables -F
		echo 'Restarting network-manager'
		systemctl restart network-manager
		echo '---------See ya space cowboy----------'
		;;
	*)
		echo 'Monkey man use: '$0' [start,stop] <ip> <AP interface> <output interface>'
		;;
esac
