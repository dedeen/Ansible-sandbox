### This script will tear down the EC2 bastion host in the App endpoint VPC(s), that was created by the Create-Bastion-Host.sh script in this same repo. 

# Set up some variables (bh == bastion host)
instname=Bastion-Host
igwname=Bastion-IGW

# Terminate the EC2 bastion host
#-->instid=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instname} --query "Reservations[*].Instances[*].InstanceId" --output text)
#-->echo "Terminating ec2 named:"${instname}", InstanceID:"${instid}
#-->aws ec2 terminate-instances --instance-ids ${instid}

# Delete the IGW for the bastion subnet/VPC
igwid=$(aws ec2 describe-internet-gateways --filter Name=tag:Name,Values=${igwname} --query "InternetGateways[*].InternetGatewayId" --output text)
vpcid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].VpcId" --output text)
echo "Detaching IGW:"${igwid}" from VPC:"${vpcid}

#aws ec2 detach-internet-gateway --internet-gateway-id ${igwid} --vpc-id ${vpcid}
#aws ec2 detach-internet-gateway --internet-gateway-id ${igwid} --vpc-id ${vpcid}
exit 0


secgroupid=$(aws ec2 describe-security-groups 
--filters Name=group-name,Values=${open_sec_group} Name=vpc-id,Values=${vpcid} --query "SecurityGroups[*].GroupId" --output text)

# Get some info from AWS for the target subnet
subnetid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].SubnetId" --output text)
vpcid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].VpcId" --output text)
cidr=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].CidrBlock" --output text)
echo "SubnetId:"${subnetid}
echo "VpcId:"${vpcid}
echo "CIDR:"${cidr}
read -p "... " -n1 -s

#Build an IGW so we can access the bastion host from the outside 
igwid=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
echo "IGW:"${igwid}
aws ec2 create-tags --resources $igwid --tags Key=Name,Value="Bastion-IGW"

# Attach the bastion IGW to the bastion subnet's VPC 
aws ec2 attach-internet-gateway --internet-gateway-id ${igwid} --vpc-id ${vpcid}
read -p "... " -n1 -s

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

read -p "... " -n1 -s
# Create a route table for the bastion subnet with a default route to the new IGW
#   This couldn't be created when VPC was built as bastion IGW didn't exist yet 

# Create RT
rtid=$(aws ec2 create-route-table --vpc-id ${vpcid} --query "RouteTable.RouteTableId" --output text)
echo "Route Table for Bastion Subnet:"${rtid}
aws ec2 create-tags --resources $rtid --tags Key=Name,Value=${bh_rt_name}

# Add default route
routesuccess=$(aws ec2 create-route --route-table-id ${rtid} --destination-cidr-block 0.0.0.0/0 --gateway-id ${igwid})
echo "Successfully created route?:"${routesuccess}
read -p "... " -n1 -s

# Associate to bastion subnet 
# Get RT ID for RT currently associated to the bastion subnet
orRT=App01-VPC-intra
targRT=$bh_rt_name
subnet1=$subnetid

rt0=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${orRT}" --query "RouteTables[*].RouteTableId"  --output text)
rt1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${targRT}" --query "RouteTables[*].RouteTableId"  --output text)

# Get association ID for this route table
awscmd1="aws ec2 describe-route-tables --route-table-ids ${rt0} --filters \"Name=association.subnet-id,Values=${subnet1}\" --query \"RouteTables[*].Associations[?SubnetId=='${subnet1}']\"  --output text"
result1=$(eval "$awscmd1")

if [ "$result1" = "" ];
then
   # Empty string returned, so no rt association to change for this row
   result1="Not_Applicable: No_work_to_perform . . . . . "
   # echo "Empty String Returned"
 fi 
    
echo "AWSCLI Query Results->"${result1}
# Store the resource IDs from AWS in 4 arrays, parse them and store into the arrays with sync'ed indices
rtbassoc=$(cut -d " " -f 2 <<<$result1)
currrtb=$(cut -d " " -f 3 <<<$result1)
currsubnet=$(cut -d " " -f 4 <<<$result1)
awsrtnew=$rt1

awsrtcmd="aws ec2 replace-route-table-association --association-id ${rtbassoc} --route-table-id ${awsrtnew} --no-cli-auto-prompt --output text"
echo "... Sending this AWS CLI cmd:"
read -p "... " -n1 -s
echo $awsrtcmd
result2=$(eval "$awsrtcmd")
echo "... Returned results:"$result2

# All done now
echo "#############################################"
echo "# Bastion host has been deployed"
echo "#   - Wait a few minutes for init"
echo "#   - Public IP: " ${publicip}
echo "#   - ssh key:   " ${bh_keypair}
echo "#   #ssh ec2-user@ip -i keypairfilename"
echo "#############################################"
exit 0
