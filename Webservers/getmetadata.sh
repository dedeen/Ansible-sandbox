# This script is run to set up the metadata on an EC2 instance that is running an Apache web server. 
#   This will allow the index.html to publish some info about the instance serving the page, 
#   as through several layers of NAT and proxying via ALB, the URL in the browser from the Internet 
#   will not show the correct destination IP address. 
#      dan@dsbluenet, 2023 
#
touch /usr/tmp/instancemetadata
chmod 777 /usr/tmp/instancemetadata
echo "Instance Meta-Data" >> /usr/tmp/instancemetadata
echo -n "Private IP:" >> /usr/tmp/instancemetadata
curl http://169.254.169.254/latest/meta-data/local-ipv4 >>/usr/tmp/instancemetadata
echo "" >> /usr/tmp/instancemetadata
echo -n "Public IP:" >> /usr/tmp/instancemetadata
curl http://169.254.169.254/latest/meta-data/public-ipv4 >>/usr/tmp/instancemetadata
echo "" >> /usr/tmp/instancemetadata
echo -n "Instance ID:" >> /usr/tmp/instancemetadata
curl http://169.254.169.254/latest/meta-data/instance-id >>/usr/tmp/instancemetadata
echo "" >> /usr/tmp/instancemetadata
echo -n "Instance Type:" >> /usr/tmp/instancemetadata
curl http://169.254.169.254/latest/meta-data/instance-type >>/usr/tmp/instancemetadata
echo "" >> /usr/tmp/instancemetadata
