#@ /etc/strongswan/ipsec-vti.sh (Centos) or /etc/strongswan.d/ipsec-vti.sh (Ubuntu)

#!/bin/bash
# AWS VPC Hardware VPN Strongswan updown Script

# Usage Instructions:
# Add "install_routes = no" to /etc/strongswan/strongswan.d/charon.conf or /etc/strongswan.d/charon.conf
# Add "install_virtual_ip = no" to /etc/strongswan/strongswan.d/charon.conf or /etc/strongswan.d/charon.conf
# For Ubuntu: Add "leftupdown=/etc/strongswan.d/ipsec-vti.sh" to /etc/ipsec.conf
# For RHEL/Centos: Add "leftupdown=/etc/strongswan/ipsec-vti.sh" to /etc/strongswan/ipsec.conf
# For RHEL/Centos 6 and below: git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git && cd iproute2 && make && cp ./ip/ip /usr/local/sbin/ip

# Adjust the below according to the Generic Gateway Configuration file provided to you by AWS.
# Sample: http://docs.aws.amazon.com/AmazonVPC/latest/NetworkAdminGuide/GenericConfig.html
# tested on Amazon linux Q2 2019.

IP=$(which ip)
IPTABLES=$(which iptables)

PLUTO_MARK_OUT_ARR=(${PLUTO_MARK_OUT//// })
PLUTO_MARK_IN_ARR=(${PLUTO_MARK_IN//// })
case "$PLUTO_CONNECTION" in
  AWS-VPC-GW1)
    VTI_INTERFACE=vti1
    VTI_LOCALADDR=cgw1insideip/30
    VTI_REMOTEADDR=vgw1insideip/30
    ;;
  AWS-VPC-GW2)
    VTI_INTERFACE=vti2
    VTI_LOCALADDR=cgw2insideip/30
    VTI_REMOTEADDR=vgw2insideip/30
    ;;
esac

case "${PLUTO_VERB}" in
    up-client)
        #$IP tunnel add ${VTI_INTERFACE} mode vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
        $IP link add ${VTI_INTERFACE} type vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
        sysctl -w net.ipv4.conf.${VTI_INTERFACE}.disable_policy=1
        sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=2 || sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=0
        $IP addr add ${VTI_LOCALADDR} remote ${VTI_REMOTEADDR} dev ${VTI_INTERFACE}
        $IP link set ${VTI_INTERFACE} up mtu 1436
	$IPTABLES -t mangle -I FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        $IPTABLES -t mangle -I INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
        $IP route flush table 220
        #/etc/init.d/bgpd reload || /etc/init.d/quagga force-reload bgpd
        ;;
    down-client)
        #$IP tunnel del ${VTI_INTERFACE}
        $IP link del ${VTI_INTERFACE}
	$IPTABLES -t mangle -D FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        $IPTABLES -t mangle -D INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
        ;;
esac

# Enable IPv4 forwarding
# refer 4
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.eth0.disable_xfrm=1
sysctl -w net.ipv4.conf.eth0.disable_policy=1
sysctl -w net.ipv4.conf.vti1.rp_filter=2
sysctl -w net.ipv4.conf.vti2.rp_filter=2
sysctl -w net.ipv4.conf.vti1.disable_policy=1
sysctl -w net.ipv4.conf.vti2.disable_policy=1
# refer 4 and 5
sysctl -w net.ipv4.fib_multipath_hash_policy=1
sysctl -w net.ipv4.fib_multipath_use_neigh=1

ipset create ipsecvpn hash:net
ipset add ipsecvpn 10.10.0.0/16
ipset add ipsecvpn 10.20.0.0/16
ipset save > /etc/ipset.conf
iptables -t nat -A POSTROUTING -j MASQUERADE -m set ! --match-set ipsecvpn dst

iptables-save > /etc/sysconfig/iptables



# References:
# http://docs.aws.amazon.com/AmazonVPC/latest/NetworkAdminGuide/Introduction.html
# http://end.re/2015-01-06_vti-tunnel-interface-with-strongswan.html
# https://www-01.ibm.com/support/knowledgecenter/#!/SST55W_4.3.0/liaca/liaca_cfg_ipsec_vti.html
# refer 4: https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
# refer 5: https://codecave.cc/multipath-routing-in-linux-part-2.html