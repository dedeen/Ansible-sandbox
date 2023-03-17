#### Simple script to rename ec2 building name.tf files from .tf.not to .tf so they can be run. Running this script and 
#        the subsequent 'terraform -apply' will create numerous EC2 instances in your environment. 
#
#mv main_ec2s.tf.not main_ec2s.tf
mv main_pa-vm1.tf.not main_pa-vm1.tf
mv main_pa-vm2.tf.not main_pa-vm2.tf
#mv main_panorama.tf.not main_panorama.tf
#mv main_webservers.tf.not main_webservers.tf
mv main_tgw_attachments.tf.not main_tgw_attachments.tf
mv main_webservers.tf.not main_webservers.tf
mv main_alb-inside.tf.not main_alb-inside.tf
mv main_alb-outside.tf.not main_alb-outside.tf

