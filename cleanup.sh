############################################ Final working stuff #####################
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
