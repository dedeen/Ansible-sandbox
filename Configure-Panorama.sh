###########################
# Simple script to ssh to each Panorama server and perform some basic configuration
pano1_inst_name=Panorama-1
pano2_inst_name=Panorama-2


# Get the handle for Panorama
instid=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${pano1_inst_name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
echo "Panorama Server:"${pano1_inst_name}", InstanceID:"${instid}

# Get the keypair name as we will use in config script to connect via ssh
ws_keypair=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].KeyName" --output text)
echo "Instance KeyPair:"${ws_keypair}

# Get the dyn public IP address 
publicip=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "|   Panorama: "${pano1_inst_name} "Remapped to IGW for sw install"
echo "|   PublicIP :"${publicip}
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

