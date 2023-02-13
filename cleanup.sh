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
subnet[5]=sec-az2-int
#
originalrt[6]=App01-VPC-intra
targetrt[6]=App1-instances-RT
subnet[6]=app1-az1-inst
#
originalrt[7]=App01-VPC-intra
targetrt[7]=App1-instances-RT
subnet[7]=app1-az2-inst
#
originalrt[8]=App02-VPC-intra
targetrt[8]=App2-instances-RT
subnet[8]=app2-az1-inst
#
originalrt[9]=App02-VPC-intra
targetrt[9]=App2-instances-RT
subnet[9]=app2-az2-inst
#
originalrt[10]=Mgmt-VPC-intra
targetrt[10]=Mgmt-instances-RT
subnet[10]=mgmt-az1-inst
#
originalrt[11]=Mgmt-VPC-intra
targetrt[11]=Mgmt-instances-RT
subnet[11]=mgmt-az2-inst

#count=11
count="${#originalrt[@]}"   # number of elements in arrays
count=$((count-1))          # indexed starting at zero 
index=0

echo "-----------------------------"
echo "Subnet associations to change"
echo "----------------------------------------------"
echo "Subnet             Orig-RT              New-RT"
echo "------             -------              ------"
while [ $index -le $count ]; do
    echo ${subnet[$index]}" : "${originalrt[$index]}" -> "${targetrt[$index]}
    #
    #
    #
    index=$(($index+1))
done
echo "----------------------------------------------"
#exit 0

# Loop through the subnet/route table associations, retrieve keys, verify, change, verify-change
index=0
#while [ $index -le $count ]; do
while [ $index -le 2 ]; do
    # Get subnet-id 
    sNet=${subnet[$index]}
    orRT=${originalrt[$index]}
    targRT=${targetrt[$index]}
    echo "~"${sNet}"~~"${orRT}"~~~"${targRT}
   # echo "~~"${orRT}
   # echo "~~~"${targRT}
        
    subnet1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${sNet}" --query "Subnets[*].SubnetId" --output text)
    rt0=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${orRT}" --query "RouteTables[*].RouteTableId"  --output text)
    rt1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${targRT}" --query "RouteTables[*].RouteTableId"  --output text)
    
    awscmd1="aws ec2 describe-route-tables --route-table-ids ${rt0} --filters \"Name=association.subnet-id,Values=${subnet1}\" --query \"RouteTables[*].Associations[?SubnetId=='${subnet1}']\"  --output text"
    result1=$(eval "$awscmd1")
    #exit 0
    echo "."${subnet1}".."${rt0}"..."${rt1}
    echo "....."${result1}
    
    ###########################
    # Now we have the AWS associations and resource IDs, will do some logging and check for expected values. If as expected, will change the 
    #   association between route table and subnet to what is needed for the Palo Alto Firewall environment. 
    #####
    # Parse out the values returned and check for expected values. 
    rtbassoc=$(cut -d " " -f 2 <<<$result1)
    currrtb=$(cut -d " " -f 3 <<<$result1)
    currsubnet=$(cut -d " " -f 4 <<<$result1)
    echo ">"$rtbassoc" "$currrtb" "$currsubnet
    echo "<"$subnet1"  "$rt0
    
  
    oksofar=true
    if [ "$currsubnet" != "$subnet1" ]; then 
    oksofar=false
    fi
    if [ "$currrtb" != "$rt0" ]; then 
    oksofar=false
    fi
    
    if (($oksofar))
    then 
        echo "OK"
    else
        echo "Not OK"
    fi 
    
    # end of loop, update index
    index=$(($index+1))
done   
exit 0 
    #nrt1=
   # Get subnet-id#
#subnet1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=sec-az1-pub" --query "Subnets[*].SubnetId" --output text)

   # Get original route-table-id#
#ort1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Sec01-VPC-intra" --query "RouteTables[*].RouteTableId"  --output text)

   # Get new route-table-id#
#nrt1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Secvpc-public-subnets-RT" --query "RouteTables[*].RouteTableId"  --output text)

   # Build cmd string - Get current subnet to route-table association
#awscmd1="aws ec2 describe-route-tables --route-table-ids ${ort1} --filters \"Name=association.subnet-id,Values=${subnet1}\" --query \"RouteTables[*].Associations[?SubnetId=='${subnet1}']\"  --output text"

   # Run it
#res1=$(eval "$awscmd1")

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
