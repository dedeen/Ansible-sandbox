#### Simple script to rename ec2 building .tf files from .tf.not to .tf so they can be run. 
#      This is used primarily to build and tear down infrastructure without building the EC2s (minimize costs for routing / subnetting, TGW, work. 
#
# Here we set up a list of the subnet associations that will need to be changed after all of the terraform scripts have been run. 
#       Using 4 arrays here that are matched in order on index

mv main_ec2s.tf.not main_ec2s.tf
mv main_pa-vms.tf.not main_pa-vms.tf
mv main_panorama.tf.not main_panorama.tf
