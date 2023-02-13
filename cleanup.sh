#### This script changes route table associations with multiple subnets. This is done here to work around a terraform limitation on reassigning
#       associations when one already exists. This is a known bug with terraform. 
#
# Here we set up a list of the subnet associations that will need to be changed after all of the terraform scripts have been run. 
#       Using 4 arrays here that are matched in order on index

declare -a originalrt
declare -a targetrt
declare -a subnet 

originalrt[0]=Sec01-VPC-intra
targetrt[0]=Secvpc-public-subnets-RT
subnet[0]=sec-az1-pub
#
originalrt[1]=Sec01-VPC-intra
targetrt[1]=Secvpc-public-subnets-RT
subnet[1]=sec-az2-pub
#
originalrt[2]=Sec01-VPC-intra
targetrt[2]=Secvpc-mgmt-subnets-RT
subnet[2]=sec-az1-mgt
#
originalrt[3]=Sec01-VPC-intra
targetrt[3]=Secvpc-mgmt-subnets-RT
subnet[3]=sec-az2-mgt
#
originalrt[4]=Sec01-VPC-intra
targetrt[4]=Secvpc-private-subnets-RT
subnet[4]=sec-az1-int
#
originalrt[5]=Sec01-VPC-intra
targetrt[5]=Secvpc-private-subnets-RT
subnet[5]=sec-az1-int
#

echo ${originalrt[0]}
echo ${targetrt[0]}
echo ${subnet[0]}

echo ${originalrt[1]}
echo ${targetrt[1]}
echo ${subnet[1]}
exit 0



   # Get subnet-id#
subnet1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=sec-az1-pub" --query "Subnets[*].SubnetId" --output text)

   # Get original route-table-id#
ort1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Sec01-VPC-intra" --query "RouteTables[*].RouteTableId"  --output text)

   # Get new route-table-id#
nrt1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Secvpc-public-subnets-RT" --query "RouteTables[*].RouteTableId"  --output text)

   # Build cmd string - Get current subnet to route-table association
awscmd1="aws ec2 describe-route-tables --route-table-ids ${ort1} --filters \"Name=association.subnet-id,Values=${subnet1}\" --query \"RouteTables[*].Associations[?SubnetId=='${subnet1}']\"  --output text"

   # Run it
res1=$(eval "$awscmd1")

   # Parse the results 
rtbassoc=$(cut -d " " -f 2 <<<$res1)
currrtb=$(cut -d " " -f 3 <<<$res1)
currsubnet=$(cut -d " " -f 4 <<<$res1)

   # Confirm expected results before changing any of the associations 
if [ "$currrtb" == "$ort1" ]; then 
    echo "matched expected 1"
fi 

if [ "$currsubnet" == "$subnet1" ]; then 
    echo "matched expected 2"
fi
