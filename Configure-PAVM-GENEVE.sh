#### This script will retrieve the VPCe endpoint identifiers from AWS, then ssh to the PA-VMs and configure the following: 
#       - overlay-routing
#       - GENEVE inspection
#       - associate the subinterface ethernet1/1.1 with both VPCe
#       - retrieve and verify the aws gwlb configuration of the PA-VM AWS plugin
#

# Set up some variables
PAVM1name=PA-VM-1
PAVM2name=PA-VM-2
VPCe1_id=PAVM_VPCe_az1
VPCe2_id=PAVM_VPCe_az2


# Get the handles for the firewalls - filter on running to avoid picking up previously terminated instances with same name
inst_id1=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${PAVM1name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
inst_id2=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${PAVM2name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)

# Get the public IPs of the firewalls
PAVM1_publicip=$(aws ec2 describe-instances --instance-ids ${inst_id1} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
PAVM2_publicip=$(aws ec2 describe-instances --instance-ids ${inst_id2} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

# Get the keypair names used when launching the EC2s
PAVM1_keypair=$(aws ec2 describe-instances --instance-ids ${inst_id1} --query "Reservations[*].Instances[*].KeyName" --output text)
PAVM2_keypair=$(aws ec2 describe-instances --instance-ids ${inst_id2} --query "Reservations[*].Instances[*].KeyName" --output text)

echo " "
echo "Firewall # 1  ->"${PAVM1name}" : " ${inst_id1}" : "${PAVM1_publicip}" : key:"${PAVM1_keypair}
echo "Firewall # 2  ->"${PAVM2name}" : " ${inst_id2}" : "${PAVM2_publicip}" : key:"${PAVM2_keypair}
echo " "

# Get the VPCe IDs"
VPCe_1=$(aws ec2 describe-vpc-endpoints --filters Name=tag:Name,Values=${VPCe1_id} --query "VpcEndpoints[*].VpcEndpointId" --output text)
VPCe_2=$(aws ec2 describe-vpc-endpoints --filters Name=tag:Name,Values=${VPCe2_id} --query "VpcEndpoints[*].VpcEndpointId" --output text)

echo "GWLB VPC Endpoint 1:"${VPCe_1}
echo "GWLB VPC Endpoint 2:"${VPCe_2}

# Configure the firewalls for GWLB Enpoints, GENEVE, Overlay Routing 
echo " "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~ Firewall 1: ~~~~~~~~~~~~~"
echo "ssh admin@"${PAVM1_publicip}
echo "configure"
echo "run request plugins vm_series aws gwlb overlay-routing enable yes"
echo "run request plugins vm_series aws gwlb inspect enable yes"
echo "run request plugins vm_series aws gwlb associate vpc-endpoint "${VPCe_1}
echo "run request plugins vm_series aws gwlb associate vpc-endpoint "${VPCe_2}  
echo "run show plugins vm_series aws gwlb"

exit 0 

echo "Firewall 1:"${PAVM1name}", InstanceID:"${instid1}
echo "    -> PublicIP:
instid2=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${PAVM2name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
echo "Firewall 2:"${PAVM2name}", InstanceID:"${instid2}

exit 0

# Get the public IPs of the firewalls
PAVM1publicip=$(aws ec2 describe-instances --instance-ids ${PAVM1name} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
echo "PA-VM-1 PublicIP:"${PAVM1publicip}

PAVM1publicip=$(aws ec2 describe-instances --instance-ids ${PAVM1name} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
echo "PA-VM-2 PublicIP:"${PAVM1publicip}

exit 0 


privateip=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
echo "PrivateIP:"${privateip}

# Get info for the Palo Alto Firewalls (PA-VMs)


build an EC2 bastion host in a preexisting subnet in the App endpoint VPC. 
#      This will allow us to SSH in from the outside, then ssh to the other EC2s to set up traffic out via the Palo Alto Firewalls. 
#      This is expected to be a temporary setup, and will use a separate AWS keypair for the bastion EC2. The keypair is in this 
#        same directory. 

# Set up some variables (bh == bastion host)
debug_flag=1                  #0: run straight through script, 1: pause and prompt during script run
which_bastion_host=1          # 1: build bastion 1 with the local vars listed just below
#which_bastion_host=2         # 2: build bastion 2 with the local vars listed just below

#Common vars 
bh_AMI=ami-094125af156557ca2
bh_type=t2.micro
bh_keypair=bastion-keypair
open_sec_group=SG-allow_ipv4

if [ $which_bastion_host -eq 1 ]
   then 
      echo "  --> Setting up to build Bastion host 1"
      # Var for bastion 1 (App01-VPC)
      bastion_subnet=app1-az1-bastion
      bh_igw_name=Bastion1-IGW
      bh_rt_name=Bastion-Host1-RT
      bh_ec2_name=Bastion-Host1
      bh_vpc_name=App01-VPC-intra         # Actually name of default RT built by terraform
      bh_vpc=App01-VPC                    # Name of the VPC that the bastion host will be created in
  fi

if [ $which_bastion_host -eq 2 ]
   then 
      echo "  --> Setting up to build Bastion host 2"
      # Var for bastion 2 (App02-VPC)
      bastion_subnet=app2-az1-bastion
      bh_igw_name=Bastion2-IGW
      bh_rt_name=Bastion-Host2-RT
      bh_ec2_name=Bastion-Host2
      bh_vpc_name=App02-VPC-intra        # Actually name of default RT built by terraform
      bh_vpc=App02-VPC                   # Name of the VPC that the bastion host will be created in
  fi 

# Get some info from AWS for the target subnet
subnetid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].SubnetId" --output text)
vpcid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].VpcId" --output text)
cidr=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].CidrBlock" --output text)
echo "SubnetId:"${subnetid}
echo "VpcId:"${vpcid}
echo "CIDR:"${cidr}

      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~

#Build an IGW so we can access the bastion host from the outside 
igwid=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
echo "IGW:"${igwid}
#aws ec2 create-tags --resources $igwid --tags Key=Name,Value="Bastion-IGW"
aws ec2 create-tags --resources $igwid --tags Key=Name,Value=${bh_igw_name}

# Attach the bastion IGW to the bastion subnet's VPC 
aws ec2 attach-internet-gateway --internet-gateway-id ${igwid} --vpc-id ${vpcid}

      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~

# Get the security group in the target VPC that is wide open for IPv4, name referenced above
secgroupid=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${open_sec_group} Name=vpc-id,Values=${vpcid} --query "SecurityGroups[*].GroupId" --output text)
echo "secgrp:"${secgroupid}

# Launch an EC2 that will be a bastion host into the VPC
instid=$(aws ec2 run-instances --image-id ${bh_AMI} --instance-type ${bh_type} --subnet-id ${subnetid} --key-name ${bh_keypair} --security-group-ids ${secgroupid} --associate-public-ip-address --query "Instances[*].InstanceId" --output text)
echo "InstanceID:"${instid}
aws ec2 create-tags --resources $instid --tags Key=Name,Value=${bh_ec2_name}

# Get the public & private IPs of the bastion host
publicip=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
echo "PublicIP:"${publicip}
privateip=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
echo "PrivateIP:"${privateip}

      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~
      
# Create a route table for the bastion subnet with a default route to the new IGW
#   This couldn't be created when VPC was built as bastion IGW didn't exist yet 

# Create RT
rtid=$(aws ec2 create-route-table --vpc-id ${vpcid} --query "RouteTable.RouteTableId" --output text)
echo "Route Table for Bastion Subnet:"${rtid}
aws ec2 create-tags --resources $rtid --tags Key=Name,Value=${bh_rt_name}

# Add default route
routesuccess=$(aws ec2 create-route --route-table-id ${rtid} --destination-cidr-block 0.0.0.0/0 --gateway-id ${igwid})
echo "Successfully created route?:"${routesuccess}

      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~

# Associate to bastion subnet 
# Get RT ID for RT currently associated to the bastion subnet
orRT=$bh_vpc_name
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
echo $awsrtcmd

      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~

result2=$(eval "$awsrtcmd")
echo "... Returned results:"$result2

# All done now
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "| Bastion host deployed, IGW & routes added"
echo "|     Public IP: " ${publicip}
echo "|     Private IP: " ${privateip}
echo "|     ssh key:   " ${bh_keypair}".pem"
echo "| Wait a few minutes for EC2 to initialize"
echo "|     ssh ec2-user@"${publicip}" -i "${bh_keypair}".pem"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
exit 0
