### This script will tear down the EC2 bastion host in the App endpoint VPC(s), that was created by the Create-Bastion-Host.sh script in this same repo. 

# Set up some variables (bh == bastion host)
#debug_flag=0  #0: run straight through script 
debug_flag=1   #1: pause and prompt during script run

instname=Bastion-Host
igwname=Bastion-IGW
vpcname=App01-VPC
bh_rt_name=Bastion-Host-RT
bastion_subnet=app1-az1-bastion

# Terminate the EC2 bastion host
#-->instid=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instname} --query "Reservations[*].Instances[*].InstanceId" --output text)
#-->echo "Terminating ec2 named:"${instname}", InstanceID:"${instid}
#-->aws ec2 terminate-instances --instance-ids ${instid}

# Delete the IGW for the bastion subnet/VPC
igwid=$(aws ec2 describe-internet-gateways --filter Name=tag:Name,Values=${igwname} --query "InternetGateways[*].InternetGatewayId" --output text)
vpcid=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=${vpcname} --query "Vpcs[*].VpcId" --output text)

echo "Detaching IGW:"${igwid}" from VPC:"${vpcid}
      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~
 aws ec2 detach-internet-gateway --vpc-id ${vpcid} --internet-gateway-id ${igwid}
      
echo "Deleting IGW:"${igwid}
      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~
aws ec2 delete-internet-gateway --internet-gateway-id ${igwid}
echo "IGW Deleted"

      #~~~
      if [ $debug_flag -eq 1 ]
         then read -p "___Paused, enter to proceed___"
      fi
      #~~~

# Remove the association between the RT for the bastion host/subnet and the VPC
#    We do this by finding the association VPC<->RT, and changing the association
#    This is not strictly necessary, as the RT will now be a blackhole to the deleted IGW, but it is cleaner if we put back the original assoc to subnet.

# Dis-associate RT from  bastion subnet 
# Get RT ID for RT currently associated to the bastion subnet
subnetid=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${bastion_subnet}" --query "Subnets[*].SubnetId" --output text)
#orRT=App01-VPC-intra
#targRT=$bh_rt_name
targRT=App01-VPC-intra
orRT=$bh_rt_name
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
exit 0
