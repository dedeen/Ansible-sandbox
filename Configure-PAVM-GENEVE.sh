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
echo "~~~~~~~ Configure Firewall 1 ~~~~~~~~~~~~~~~"
echo "ssh admin@"${PAVM1_publicip}
echo "configure"
echo "run request plugins vm_series aws gwlb overlay-routing enable yes"
echo "run request plugins vm_series aws gwlb inspect enable yes"
echo "run request plugins vm_series aws gwlb associate vpc-endpoint "${VPCe_1}" interface ethernet1/1.1"
echo "run request plugins vm_series aws gwlb associate vpc-endpoint "${VPCe_2}" interface ethernet1/1.1"
echo "run show plugins vm_series aws gwlb"

echo "~~~~~~~ Configure Firewall 2 ~~~~~~~~~~~~~~~"
echo "ssh admin@"${PAVM2_publicip}
echo "configure"
echo "run request plugins vm_series aws gwlb overlay-routing enable yes"
echo "run request plugins vm_series aws gwlb inspect enable yes"
echo "run request plugins vm_series aws gwlb associate vpc-endpoint "${VPCe_1}" interface ethernet1/1.1"
echo "run request plugins vm_series aws gwlb associate vpc-endpoint "${VPCe_2}" interface ethernet1/1.1"
echo "run show plugins vm_series aws gwlb"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

exit 0 
