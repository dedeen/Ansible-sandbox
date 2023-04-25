#### This script changes route table associations with multiple subnets. This is done here to work around a terraform limitation on reassigning
#       associations when one already exists. This is a known bug with terraform. 
#
# Here we set up a list of the subnet associations that will need to be changed after all of the terraform scripts have been run. 
#       Using 4 arrays here that are matched in order on index

# Note - subnet <> RT associations for the bastion subnets are created and destroyed by the utility scripts (.sh) that create the instances. 

# 3 arrays of input items (subnets and route tables)
declare -a originalrt
declare -a targetrt
declare -a subnet 

# 4 arrays of retrieved AWS identifiers (rtassoc, rt-original, subnet, rt-new)
#   Examples: rtbassoc-0e75d7d78911a038b rtb-02ede393e6ff03c1e subnet-0004d84cfba3089d1 rtb-08c0a06e2eddea97a
declare -a awsrtassoc
declare -a awsrtborig
declare -a awssubnet
declare -a awsrtnew

originalrt[0]=Sec01-VPC-intra
targetrt[0]=RT-mgmt-subnet
subnet[0]=sec-az1-mgmt
#
#originalrt[1]=Sec01-VPC-intra
#targetrt[1]=RT-dmz-subnet
#subnet[1]=sec-az1-dmz
#
#originalrt[2]=Sec01-VPC-intra
#targetrt[2]=RT-mgmt-subnet
#subnet[2]=sec-az1-pub
#
#originalrt[3]=Sec01-VPC-intra
#targetrt[3]=RT-private-subnet
#subnet[3]=sec-az1-priv
#


#count is number of entries in static array above
count="${#originalrt[@]}"   # number of elements in arrays
count=$((count-1))          # indexed starting at zero 
index=0

echo "-------------------------------------------------"
echo "Subnet<->Input Route Table Associations To Change"
echo "-------------------------------------------------"
echo "#    Subnet         Orig-RT           New-RT"
echo "--   ------         -------           ------"
while [ $index -le $count ]; do
    echo $index".   "${subnet[$index]}" : "${originalrt[$index]}" -> "${targetrt[$index]}
    #
    #
    #
    index=$(($index+1))
done
echo "----------------------------------------------"
#exit 0

# Loop through the subnet/route table associations, retrieve keys, verify, change, verify-change
index=0
while [ $index -le $count ]; do
#while [ $index -le 2 ]; do
    # Get subnet-id 
    sNet=${subnet[$index]}
    orRT=${originalrt[$index]}
    targRT=${targetrt[$index]}
           
    subnet1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${sNet}" --query "Subnets[*].SubnetId" --output text)
    rt0=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${orRT}" --query "RouteTables[*].RouteTableId"  --output text)
    rt1=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${targRT}" --query "RouteTables[*].RouteTableId"  --output text)
       
    awscmd1="aws ec2 describe-route-tables --route-table-ids ${rt0} --filters \"Name=association.subnet-id,Values=${subnet1}\" --query \"RouteTables[*].Associations[?SubnetId=='${subnet1}']\"  --output text"
    result1=$(eval "$awscmd1")
        
    if [ "$result1" = "" ];
    then
        # Empty string returned, so no rt association to change for this row
        result1="Not_Applicable: No_work_to_perform . . . . . "
       # echo "Empty String Returned"
    fi 
    
    echo "AWSCLI Query Results->"${result1}
    
    #################
    # Store the resource IDs from AWS in 4 arrays, parse them and store into the arrays with sync'ed indices
    rtbassoc=$(cut -d " " -f 2 <<<$result1)
    awsrtassoc[$index]=$rtbassoc
    currrtb=$(cut -d " " -f 3 <<<$result1)
    awsrtborig[$index]=$currrtb
    currsubnet=$(cut -d " " -f 4 <<<$result1)
    awssubnet[$index]=$currsubnet
    awsrtnew[$index]=$rt1
  
    # Checking that route tables and subnets match expected values 
   # oksofar=true
   # if [ $currsubnet != "$subnet1" ]; then 
   #     oksofar=false
   # fi
   # if [ $currrtb != "$rt0" ]; then 
   #     oksofar=false
   # fi
    
   # if $oksofar
   # then 
   #     : #echo "OK"
   # else
   #     echo "Not OK - Retrieved Values Do Not Match Expected"
   # fi 
    
    # end of loop, update index
    index=$(($index+1))
done   


# Loop through the arrays of AWS resource IDs, print out before changing all of the associations
index=0
echo "----------------------------------------------"
echo "AWS resource IDs retrieved "
echo "------"
echo "     Route Table Association       Orig-RT                  Subnet Working With           New-RT"
echo "     -----------------------       -------                  -------------------           ------"
while [ $index -le $count ]; do
    echo $index".   "${awsrtassoc[$index]}"    "${awsrtborig[$index]}"    "${awssubnet[$index]}"      "${awsrtnew[$index]}

# end of loop, update index
    index=$(($index+1))
done
echo "----------------------------------------------"
#exit 0

# Now that all of the prep work is completed and AWS resource IDs are known, we will loop through them changing subnet to RT associations as needed
index=0
echo "----------------------------------------------"
while [ $index -le $count ]; do
    awsrtcmd="aws ec2 replace-route-table-association --association-id ${awsrtassoc[$index]} --route-table-id ${awsrtnew[$index]} --no-cli-auto-prompt --output text"
    
    if [ ${awsrtassoc[$index]} = "No_work_to_perform" ];
    then 
        echo "No work to perform on this row"
    else        
        echo "... Sending this AWS CLI cmd:"
        echo $awsrtcmd
        result2=$(eval "$awsrtcmd")
        echo "... Returned results:"$result2
    fi

index=$(($index+1))
done
echo "----------------------------------------------"

