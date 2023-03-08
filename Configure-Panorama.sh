 #!/bin/bash
###########################
# Simple script to ssh to each Panorama server and perform some basic configuration
pano1_inst_name=Panorama-1
pano2_inst_name=Panorama-2

cmd99=exit

# Get the handle for Panorama
instid1=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${pano1_inst_name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
# Get the keypair name as we will use in config script to connect via ssh
ws_keypair1=$(aws ec2 describe-instances --instance-ids ${instid1} --query "Reservations[*].Instances[*].KeyName" --output text)
# Get the dyn public IP address 
publicip1=$(aws ec2 describe-instances --instance-ids ${instid1} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

# Get the handle for Panorama
instid2=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${pano2_inst_name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
# Get the keypair name as we will use in config script to connect via ssh
ws_keypair2=$(aws ec2 describe-instances --instance-ids ${instid2} --query "Reservations[*].Instances[*].KeyName" --output text)
# Get the dyn public IP address 
publicip2=$(aws ec2 describe-instances --instance-ids ${instid2} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "|   Panorama: "${pano1_inst_name} 
echo "!     InstanceId : "${instid1}
echo "|     PublicIP   : "${publicip1}
echo "|     KeyPair    : "${ws_keypair1}
echo "|  "
echo "|   Panorama: "${pano2_inst_name} 
echo "!     InstanceId : "${instid2}
echo "|     PublicIP   : "${publicip2}
echo "|     KeyPair    : "${ws_keypair2}
echo "|  "

# ssh to server command
login_string1="ssh admin@"${publicip1}" -i "${ws_keypair1}".pem -o StrictHostKeyChecking=no"
login_string2="ssh admin@"${publicip2}" -i "${ws_keypair2}".pem -o StrictHostKeyChecking=no"
echo ">>"${login_string1}
echo ">>"${login_string2}

#echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# Send these to each Panorama System

#configure 
#set mgmt-config users admin password 
# <> send password <>
# 
#set deviceconfig system hostname Panorama-1
#set deviceconfig system motd-and-banner motd-title "Pano1_within_AWS"
#set deviceconfig system motd-and-banner banner-header-color color2
#commit 
#exit
###############
