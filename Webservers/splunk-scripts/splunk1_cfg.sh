# initial configuration for Splunk server(s)
#   This script is copied from S3 to the splunk instances and executed upon launch.
#   This script is run by cloud init, and as on the fly we need to wait until the files and directories exist before modifying them.
#        useful tip to debug: cloud init logs are at /var/log/cloud-init.log, /var/log/cloud-init-output.log
#
origpwdfilename=/opt/splunk/etc/passwd 
bypasspwdfilename=/opt/splunk/etc/passwd.bk
# Need to wait until this file exists on the EC2 instance 
until [ -f /opt/splunk/etc/passwd ]
do 
    sleep 15
    echo "."
done
echo "Default password file found"
sudo mv /opt/splunk/etc/passwd /opt/splunk/etc/passwd.bk

# Need to wait until this path exists on the EC2 instance 
until [ -d /opt/splunk/etc/system/local/ ]
do 
    sleep 15
done
sudo touch /opt/splunk/etc/system/local/user-seed.conf
sudo chmod 755 /opt/splunk/etc/system/local/user-seed.conf
echo "[user_info]" >> /opt/splunk/etc/system/local/user-seed.conf
echo "PASSWORD=Temp1234" >> /opt/splunk/etc/system/local/user-seed.conf

# Same path so no need to wait for this file change 
sudo touch /opt/splunk/etc/system/local/inputs.conf
sudo chmod 755 /opt/splunk/etc/system/local/inputs.conf
echo " " >> /opt/splunk/etc/system/local/inputs.conf
echo "[udp://5514]" >> /opt/splunk/etc/system/local/inputs.conf
echo "sourcetype = pan:firewall" >> /opt/splunk/etc/system/local/inputs.conf
echo "no_appending_timestamp = true" >> /opt/splunk/etc/system/local/inputs.conf


#sudo chmod 777 "${origpwdfilename}"
#sudo touch "${bypasspwdfilename}"
#sudo chmod 777 "${bypasspwdfilename}"
#sudo mv /opt/splunk/etc/passwd /opt/splunk/etc/passwd.bk

#seedfilename=/opt/splunk/etc/system/local/user-seed.conf
#inputsfilename=/opt/splunk/etc/system/local/inputs.conf
#
#sudo mv /opt/splunk/etc/passwd /opt/splunk/etc/passwd.bk
#
#sudo touch "${seedfilename}"
#sudo chmod 755 "${seedfilename}"
#echo "[user_info]" >> "${seedfilename}"
#echo "PASSWORD=Temp1234" >> "${seedfilename}"
#
#sudo touch "${inputsfilename}"
#sudo chmod 755 "${inputsfilename}"
#echo " " >> "${inputsfilename}"
#echo "[udp://5514]" >> "${inputsfilename}"
#echo "sourcetype = pan:firewall" >> "${inputsfilename}"
#echo "no_appending_timestamp = true" >> "${inputsfilename}"
