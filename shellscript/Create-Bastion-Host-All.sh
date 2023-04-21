#### This script will build an EC2 bastion host in a preexisting subnet in the user endpoint VPC. 
#      This will allow us to SSH in from the outside, then ssh to the other EC2s to set up traffic out via the Palo Alto Firewalls. 
#      This is expected to be a temporary setup, and will use a separate AWS keypair for the bastion EC2. The keypair is in this 
#        same directory. 

# Set up some variables (bh == bastion host)
debug_flag=0                  #0: run straight through script, 1: pause and prompt during script run
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
      # Var for bastion 1 (Usr01-VPC)
      bastion_subnet=usr1-az1-bastion
      bh_igw_name=Bastion1-IGW
      bh_rt_name=Bastion-Host1-RT
      bh_ec2_name=Bastion-Host1
      bh_vpc_name=Usr01-VPC-intra         # Actually name of default RT built by terraform
      bh_vpc=Usr01-VPC                    # Name of the VPC that the bastion host will be created in
  fi

if [ $which_bastion_host -eq 2 ]
   then 
      echo "  --> Setting up to build Bastion host 2"
      # Var for bastion 2 (Usr02-VPC)
      bastion_subnet=usr2-az1-bastion
      bh_igw_name=Bastion2-IGW
      bh_rt_name=Bastion-Host2-RT
      bh_ec2_name=Bastion-Host2
      bh_vpc_name=Usr02-VPC-intra        # Actually name of default RT built by terraform
      bh_vpc=Usr02-VPC                   # Name of the VPC that the bastion host will be created in
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
