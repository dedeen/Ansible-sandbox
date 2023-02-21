#### This script will build an EC2 bastion host in a preexisting subnet in the App endpoint VPC. 
#      This will allow us to SSH in from the outside, then ssh to the other EC2s to set up traffic out via the Palo Alto Firewalls. 
#      This is expected to be a temporary setup, and will use a separate AWS keypair for the bastion EC2. The keypair is in this 
#        same directory. 

# Set up some variables (bh == bastion host)
bastion_subnet=app1-az1-bastion
bh_AMI=ami-094125af156557ca2
bh_type=t2.micro
bh_keypair=bastion-keypair
open_sec_group=SG-allow_ipv4

# Get some info from AWS for the target subnet
subnetid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].SubnetId" --output text)
vpcid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].VpcId" --output text)
cidr=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].CidrBlock" --output text)
echo "SubnetId:"${subnetid}
echo "VpcId:"${vpcid}
echo "CIDR:"${cidr}

#Build an IGW so we can access the bastion host from the outside 
#dje>igwid=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
#dje>echo "IGW:"${igwid}
#dje>aws ec2 create-tags --resources $igwid --tags Key=Name,Value="Bastion-IGW"

# Attach the bastion IGW to the bastion subnet 
#dje>aws ec2 attach-internet-gateway --internet-gateway-id ${igwid} --vpc-id ${vpcid}

# Get the security group in the target VPC that is wide open for IPv4, name referenced above
secgroupid=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${open_sec_group} Name=vpc-id,Values=${vpcid} --query "SecurityGroups[*].GroupId" --output text)
echo "secgrp:"${secgroupid}

# Launch an EC2 that will be a bastion host into the VPC
instid=$(aws ec2 run-instances --image-id ${bh_AMI} --instance-type ${bh_type} --subnet-id ${subnetid} --key-name ${bh_keypair} --security-group-ids ${secgroupid} --associate-public-ip-address --query "Instances[*].InstanceID" --output text)
echo "InstanceID:"${instid}
exit 0


