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
originalrt[6]=Usr01-VPC-intra
targetrt[6]=Usr1-instances-RT
subnet[6]=usr1-az1-inst
#
originalrt[7]=Usr01-VPC-intra
targetrt[7]=Usr1-instances-RT
subnet[7]=usr1-az2-inst
#
originalrt[8]=Usr02-VPC-intra
targetrt[8]=Usr2-instances-RT
subnet[8]=usr2-az1-inst
#
originalrt[9]=Usr02-VPC-intra
targetrt[9]=Usr2-instances-RT
subnet[9]=usr2-az2-inst
#
originalrt[10]=Mgmt-VPC-intra
targetrt[10]=Mgmt-private-subnets-RT
subnet[10]=mgmt-az1-int
#
originalrt[11]=Mgmt-VPC-intra
targetrt[11]=Mgmt-private-subnets-RT
subnet[11]=mgmt-az2-int
#
originalrt[12]=Mgmt-VPC-intra
targetrt[12]=Mgmt-public-subnets-RT
subnet[12]=mgmt-az1-pub
#
originalrt[13]=Mgmt-VPC-intra
targetrt[13]=Mgmt-public-subnets-RT
subnet[13]=mgmt-az2-pub
#
# Next two are for the web servers for inbound traffic through the firewall
originalrt[14]=WebSrv-VPC-intra
targetrt[14]=WebSrv-subnets-RT
subnet[14]=websrv-az1-inst
#
originalrt[15]=WebSrv-VPC-intra
targetrt[15]=WebSrv-subnets-RT
subnet[15]=websrv-az2-inst
#
# Next two are subnets hosting TGW attachments in security VPC
originalrt[16]=Sec01-VPC-intra
targetrt[16]=TGW-Att-GWLBe-az1-RT
subnet[16]=sec-az1-TGW_Att
#
originalrt[17]=Sec01-VPC-intra
targetrt[17]=TGW-Att-GWLBe-az2-RT
subnet[17]=sec-az2-TGW_Att
#
# Next two are subnets hosting GWLB Endpoints in the security VPC
originalrt[18]=Sec01-VPC-intra
targetrt[18]=GWLBe-TGW-Att-az1-RT
subnet[18]=sec-az1-GWLB_EndPt
#
originalrt[19]=Sec01-VPC-intra
targetrt[19]=GWLBe-TGW-Att-az2-RT
subnet[19]=sec-az2-GWLB_EndPt
#
# Next two are subnets where the GWLB attaches to the VPC+AZ
originalrt[20]=Sec01-VPC-intra
targetrt[20]=GWLB-az1-RT
subnet[20]=sec-az1-GWLB
#
originalrt[21]=Sec01-VPC-intra
targetrt[21]=GWLB-az2-RT
subnet[21]=sec-az2-GWLB
#
# Next two are subnets for vpn connections to Palo Alto firewalls
originalrt[22]=Sec01-VPC-intra
targetrt[22]=Secvpc-vpn-az1-subnet-RT
subnet[22]=sec-az1-vpn
#
# Next two are subnets for vpn connections to Palo Alto firewalls
originalrt[23]=Sec01-VPC-intra
targetrt[23]=Secvpc-vpn-az2-subnet-RT
subnet[23]=sec-az2-vpn


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

