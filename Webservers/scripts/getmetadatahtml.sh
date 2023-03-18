filename=/var/www/html/instance_meta_data.html
sudo touch "${filename}"
sudo chmod 755 "${filename}"
echo "<body>" >> "${filename}"
echo "<font color=white>" >> "${filename}"
echo "===============================" >> "${filename}"
echo "Instance MetaData" >> "${filename}"
echo -n "Private IP:    " >> "${filename}"
sudo curl http://169.254.169.254/latest/meta-data/local-ipv4 >> "${filename}"
echo "<br>" >> "${filename}"
#
echo -n "Instance Id:   " >> "${filename}"
sudo curl http://169.254.169.254/latest/meta-data/instance-id >> "${filename}"
echo "<br>" >> "${filename}"
#
echo -n "Instance Type: " >> "${filename}"
sudo curl http://169.254.169.254/latest/meta-data/instance-type >> "${filename}"
echo "<br>" >> "${filename}"
#
echo -n "Avail Zone:    " >> "${filename}"
sudo curl http://169.254.169.254/latest/meta-data/placement/availability-zone >> "${filename}"
echo "<br>" >> "${filename}"
echo "===============================" >> "${filename}"
