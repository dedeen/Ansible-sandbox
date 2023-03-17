# This script is run to set up the metadata on an EC2 instance that is running an Apache web server. 
#   This will allow the index.html to publish some info about the instance serving the page, 
#   as through several layers of NAT and proxying via ALB, the URL in the browser from the Internet 
#   will not show the correct destination IP address. 
#      dan@dsbluenet, 2023 
#
meta_data_file=/var/www/html/instance_meta_data.txt
sudo touch "${meta_data_file}"
sudo chmod 777 "${meta_data_file}"
#
echo ". . . . . . . . . . . . " >> "${meta_data_file}"
echo "Instance Meta-Data" >> "${meta_data_file}"
echo -n "Private IP:" >> "${meta_data_file}"
sudo curl http://169.254.169.254/latest/meta-data/local-ipv4 >> "${meta_data_file}"
echo "" >> "${meta_data_file}"
#
echo -n "Public IP:" >> "${meta_data_file}"
sudo curl http://169.254.169.254/latest/meta-data/public-ipv4 >> "${meta_data_file}"
echo "" >> "${meta_data_file}"
#
echo -n "Instance ID:" >> "${meta_data_file}"
sudo curl http://169.254.169.254/latest/meta-data/instance-id >> "${meta_data_file}"
echo "" >> "${meta_data_file}"
#
echo -n "Instance Type:" >> "${meta_data_file}"
sudo curl http://169.254.169.254/latest/meta-data/instance-type >> "${meta_data_file}"
echo " " >> "${meta_data_file}"
echo ". . . . . . . . . . . . " >> "${meta_data_file}"
#
###
Get PAN logo 
sudo touch /var/www/html/panlogo.png
sudo chmod 777 /var/www/html/panlogo.png
sudo curl https://www.paloaltonetworks.com/content/dam/pan/en_US/images/logos/brand/primary-company-logo-color-white/PANW_Parent_Brand_Primary_Logo_RGB_Red_White.png?imbypass=on >
panlogo.png
