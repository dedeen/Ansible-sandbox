 #!/bin/bash
###########################
# Simple script to ssh to each Panorama server and perform some basic configuration
splunk_inst_name=Splunk-1

# Get the handle for Splunk instance
instid1=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${splunk_inst_name} "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
# Get the keypair name as we will use in config script to connect via ssh
ws_keypair1=$(aws ec2 describe-instances --instance-ids ${instid1} --query "Reservations[*].Instances[*].KeyName" --output text)
# Get the dyn public IP address 
publicip1=$(aws ec2 describe-instances --instance-ids ${instid1} --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "|   Splunk Server: "${splunk_inst_name} 
echo "!     InstanceId : "${instid1}
echo "|     PublicIP   : "${publicip1}
echo "|     KeyPair    : "${ws_keypair1}
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
echo "Change initial password:"
echo "   http://"${publicip1}":8000"
echo "   install credentials:"
echo "     admin"
echo "     SPLUNK-"${instid1}
###############
