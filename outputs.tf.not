#    Output form vpc creation. datacenter1 and datacenter2 are the VPCs created.
#    Here we get handles to build the rest of the infrastructure. 
#    To do - get clever and loop over the datacenters from the map in vars file. 


output "vpc_dc1-vpc_id" {
  value = module.vpc["datacenter1"].vpc_id
}
output "vpc_dc1-vpc_arn" {
  value = module.vpc["datacenter1"].vpc_arn
}
output "vpc_dc1-vpc_cidr" {
  value = module.vpc["datacenter1"].vpc_cidr_block
}
output "vpc_dc1-vpc_private_snet0" {
  value = module.vpc["datacenter1"].private_subnets[0]
}
output "vpc_dc1-vpc_public_snet0" {
  value = module.vpc["datacenter1"].public_subnets[0]
}
output "vpc_dc1-vpc_intra_snet0" {
  value = module.vpc["datacenter1"].intra_subnets[0]
}
output "vpc_dc1-vpc_natgw_id" {
  value = module.vpc["datacenter1"].natgw_ids
}
output "vpc_dc1-vpc_igw_id" {
  value = module.vpc["datacenter1"].igw_id
}
output "vpc_dc1-vpc_igw_arn" {
  value = module.vpc["datacenter1"].igw_arn
}
output "vpc_dc1-vpc_nat_public_ips" {
  value = module.vpc["datacenter1"].nat_public_ips
}
output "key_pair_file" {
  value = local.keypair_name
}
