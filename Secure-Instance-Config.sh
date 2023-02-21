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
igwid=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
echo "IGW:"${igwid}
aws ec2 create-tags --resources $igwid --tags Key=Name,Value="Bastion-IGW"

# Attach the bastion IGW to the bastion subnet 
aws ec2 attach-internet-gateway --internet-gateway-id ${igwid} --vpc-id ${vpcid}

# Get the security group in the target VPC that is wide open for IPv4, name referenced above
secgroupid=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${open_sec_group} Name=vpc-id,Values=${vpcid} --query "SecurityGroups[*].GroupId" --output text)
echo "secgrp:"${secgroupid}

# Launch an EC2 that will be a bastion host into the VPC
instid=$(aws ec2 run-instances --image-id ${bh_AMI} --instance-type ${bh_type} --subnet-id ${subnetid} --key-name ${bh_keypair} --security-group-ids ${secgroupid} --associate-public-ip-address --query "Instances[*].InstanceId" --output text)
echo "InstanceID:"${instid}
aws ec2 create-tags --resources $instid --tags Key=Name,Value="Bastion-Host"

# Get the public IP of the bastion host
publicip=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
echo "PublicIP:"${publicip}

# Create a route table for the bastion subnet with a default route to the new IGW
#   This couldn't be created when VPC was built as bastion IGW didn't exist yet 

# Create RT
rtid=$(aws ec2 create-route-table --vpc-id ${vpcid} --query "RouteTable.RouteTableId" --output text)
echo "Route Table for Bastion Subnet:"${rtid}
aws ec2 create-tags --resources $rtid --tags Key=Name,Value="Bastion-Host-RT"

# Add default route
routesuccess=$(aws ec2 create-route --route-table-id ${rtid} --destination-cidr-block 0.0.0.0/0 --gateway-id ${igwid})
echo "Successfully created route?:"${routesuccess}

# Associate to bastion subnet 
#   First need the RT currently associated to the bastion subnet
rtinit=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${orRT}" --query "RouteTables[*].RouteTableId"  --output text)


assocrtsn=$(aws ec2 associate-route-table --route-table-id ${rtid} --subnet-id ${subnetid})

###################
echo "#############################################"
echo "# Bastion host has been deployed"
echo "#   - Wait a few minutes for init"
echo "#   - Public IP: " ${publicip}
echo "#   - ssh key:   " ${bh_keypair}
echo "#   #ssh ec2-user@ip -i keypairfilename"
echo "#############################################"
exit 0


