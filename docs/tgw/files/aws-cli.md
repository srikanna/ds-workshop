
aws ec2 describe-addresses --filter "Name=tag:Workshop,Values=TGW" --query 'Addresses[*].[PublicIp]' --output text

cgw_ip=`aws ec2 describe-addresses --filter "Name=tag:Workshop,Values=TGW" --query 'Addresses[*].[PublicIp]' --output text`

aws ec2 create-customer-gateway --bgp-asn 65001 --public-ip $cgw_ip --type ipsec.1

aws ec2 create-tags --resources cgw-0c6abb22f7ecc4540 --tags Key=Workshop,Value=TGW

create vpn attachement
tag vpn connection 

aws ec2 describe-tags --filters "Name=key,Values=Workshop" "Name=value,Values=TGW"

