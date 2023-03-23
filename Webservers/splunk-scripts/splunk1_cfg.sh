# initial configuration for Splunk server(s)
# copied from S3 to the splunk instances and executed upon launch
#
origpwdfilename=/opt/splunk/etc/passwd 
bypasspwdfilename=/opt/splunk/etc/passwd.bk
sudo chmod 777 "${origpwdfilename}"
sudo touch "${bypasspwdfilename}"
sudo chmod 777 "${bypasspwdfilename}"
sudo mv /opt/splunk/etc/passwd /opt/splunk/etc/passwd.bk

seedfilename=/opt/splunk/etc/system/local/user-seed.conf
inputsfilename=/opt/splunk/etc/system/local/inputs.conf
#
#sudo mv /opt/splunk/etc/passwd /opt/splunk/etc/passwd.bk
#
sudo touch "${seedfilename}"
sudo chmod 755 "${seedfilename}"
echo "[user_info]" >> "${seedfilename}"
echo "PASSWORD=Temp1234" >> "${seedfilename}"
#
sudo touch "${inputsfilename}"
sudo chmod 755 "${inputsfilename}"
echo " " >> "${inputsfilename}"
echo "[udp://5514]" >> "${inputsfilename}"
echo "sourcetype = pan:firewall" >> "${inputsfilename}"
echo "no_appending_timestamp = true" >> "${inputsfilename}"
