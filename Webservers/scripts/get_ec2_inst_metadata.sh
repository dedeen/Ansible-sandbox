# This script is run to set up the metadata on an EC2 instance that is running an Apache web server. 
#   This will allow the index.html to publish some info about the instance serving the page, 
#   as through several layers of NAT and proxying via ALB, the URL in the browser from the Internet 
#   will not show the correct destination IP address. 
#      dan@dsbluenet, 2023 
#
meta_data_file="/var/www.html/instance_meta_data.txt"
sudo touch ${meta_data_file}
sudo chmod 755 ${meta_data_file}
echo "test file" >> ${meta_data_file}
