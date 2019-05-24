#!/bin/sh
set -e
set -u

source /tmp/variables.txt

service strongswan stop
service bgpd stop
service zebra stop

# these variable names has to match what was used in setparams.sh file.
# essential matching the key names from /tmp/variables.txt
declare -a params=("cgwprivateip" "vgw1outsideip" "vgw2outsideip" "cgw1insideip" 
                    "cgw2insideip" "vgw1insideip" "vgw2insideip" "vgw1psk" "vgw2psk"
                    "vgwas" "cgwas")

declare -a filename=("ipsec.conf" "ipsec-vti.sh" "ipsec.secrets" "bgpd.conf" "zebra.conf") 

cd /tmp/ && rm ipsec* zebra* bgpd* -f

for file in "${filename[@]}"
do
    
    wget https://workshop.awssri.com/tgw/files/$file -q -O /tmp/$file
    echo "downloaded $file from s3..."
    for i in "${params[@]}"
    do
        sed -i "s/$i/${!i}/g" "/tmp/$file"
    done
    
    if [[ $file =~ ^bgpd ]] || [[ $file =~ ^zebra ]]; then 

        echo "copying ${file} configuration"
        /bin/cp /etc/quagga/$file /etc/quagga/$file.bkup 2>/dev/null || :
        /bin/cp -f /tmp/$file /etc/quagga/$file
        
        chown quagga.quagga /etc/quagga/*.conf
        chmod 640 /etc/quagga/*.conf

    else
        
        echo "copying ${file} configuration"
        /bin/cp /etc/strongswan/$file /etc/strongswan/$file.bkup 2>/dev/null || :
        /bin/cp -f /tmp/$file /etc/strongswan/$file

    fi
done
chmod +x /etc/strongswan/ipsec-vti.sh

# start services

service strongswan restart
service zebra restart
service bgpd restart

# set ip tables

# TODO parameterize the VPC CIDRS for spokes below and loop for as many spokes.

# ipset create ipsecvpn hash:net
# ipset add ipsecvpn 10.10.0.0/16
# ipset add ipsecvpn 10.20.0.0/16
# ipset save > /etc/ipset.conf
# iptables -t nat -A POSTROUTING -j MASQUERADE -m set ! --match-set ipsecvpn dst
# iptables-save > /etc/sysconfig/iptables


