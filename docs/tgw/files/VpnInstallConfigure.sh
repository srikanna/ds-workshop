#!/bin/sh
set -e
set -u
action="configure"
vpnId="vpn-0997191e32c935830"
awsRegion="us-east-1"
if [ "${action}" = 'configure' ]; then
     action='fetch-config'
elif [ "${action}" = 'configure (append)' ]; then
     action='append-config'
fi
if [ "${action}" = 'fetch-config' ] || [ "${action}" = 'append-config' ]; then
    cmd="aws ec2 describe-vpn-connections --vpn-connection-ids ${vpnId} --query VpnConnections[*].CustomerGatewayConfiguration[] --region ${awsRegion} --output text"
    ${cmd} >/tmp/vpn.xml
    wget https://workshop.awssri.com/tgw/files/install.sh -O /tmp/install.sh
    wget https://workshop.awssri.com/tgw/files/setparams.sh -O /tmp/setparams.sh
    wget https://workshop.awssri.com/tgw/files/configure.sh -O /tmp/configure.sh
    chmod +x *.sh
    (exec "/tmp/install.sh")
    (exec "/tmp/setparams.sh")
    (exec "/tmp/configure.sh")
fi

