# initial configuration for Splunk server(s)
#   This script is copied from S3 to the splunk instances and executed upon launch.
#   This script is run by cloud init, and as on the fly we need to wait until the files and directories exist before modifying them.
#        useful tip to debug: cloud init logs are at /var/log/cloud-init.log, /var/log/cloud-init-output.log
#
#        #origpwdfilename=/opt/splunk/etc/passwd 
#        #bypasspwdfilename=/opt/splunk/etc/passwd.bk

# Big sleep here for Splunk install, driven by cloud init, as the install will create 
#   a default password file: /opt/splunk/etc/passwd and we want to get rid of it (-> .bak)
#   and create a seed file with our desired admin password in it. 
#   Then when we restart Splunk at the end of this script our admin password 
#   will be configured as we wish. This is tested and works well. 
#
#   Important note - this script is called via user data on creation of the instances. This call needs to 
#     be run in background '&' or else the sleeps here will hold up the splunk install and deadlock waiting 
#     on the splunk files to exist. 

sleep 200 

# Checking that this file exists on the EC2 instance 
until [ -f /opt/splunk/etc/passwd ]
do 
    sleep 15
    echo "."
done
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

sudo touch /opt/splunk/etc/system/local/global-banner.conf
sudo chmod 755 /opt/splunk/etc/system/local/global-banner.conf
echo " " >> /opt/splunk/etc/system/local/global-banner.conf
echo "[BANNER_MESSAGE_SINGLETON]" >> /opt/splunk/etc/system/local/global-banner.conf
echo "global_banner.message = Splunk-2" >> /opt/splunk/etc/system/local/global-banner.conf
echo "global_banner.visible = 1" >> /opt/splunk/etc/system/local/global-banner.conf
echo "global_banner.background_color = orange" >> /opt/splunk/etc/system/local/global-banner.conf


# all config is complete, restart Splunk and we should be all set
sudo /opt/splunk/bin/splunk restart

# that's it
