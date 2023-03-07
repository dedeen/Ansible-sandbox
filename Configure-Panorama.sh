###########################
# Simple script to ssh to each Panorama server and perform some basic configuration
pano1_inst_name=Panorama-1
pano2_inst_name=Panorama-2

cmd99=exit

# Get the handle for Panorama
instid=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${pano1_inst_name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
#echo "Panorama Server:"${pano1_inst_name}", InstanceID:"${instid}

# Get the keypair name as we will use in config script to connect via ssh
ws_keypair=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].KeyName" --output text)
#echo "Instance KeyPair:"${ws_keypair}

# Get the dyn public IP address 
publicip=$(aws ec2 describe-instances --instance-ids ${instid} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "|   Panorama: "${pano1_inst_name} 
echo "!     InstanceId : "${instid}
echo "|     PublicIP   : "${publicip}
echo "|     KeyPair    : "${ws_keypair}
echo "|   ... Sending config commands  "

# ssh to server and configure it 
login_string="ssh admin@"${publicip}" -i "${ws_keypair}".pem -o StrictHostKeyChecking=accept-new"
echo ">>"${login_string}

result1=$(eval "$login_string")
echo $result1

result99=$$(eval "$cmd99")
echo $result99


#echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

