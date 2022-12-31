/*  Terraform variables defined here. 
      Dan Edeen, dan@dsblue.net, 2022 
*/

# VPC parms, can build mutiple by passing in via this map 
variable "new_vpcs" {
	description = "DC parms for Oregon VPCs"
	type		= map(any)

	default = {
		datacenter1 = {
			region_dc		= 	"oregon-dc1"
			cidr			= 	"192.168.0.0/16"
			az_list			= 	["us-west-2a","us-west-2b"]
			edge_subnet		= 	"192.168.1.0/24"
			server_subnet		= 	"192.168.2.0/24" 
			public_subnet		= 	"192.168.3.0/24"     
		}  
/*a		},   
		datacenter2 = {
			region_dc		= 	"oregon-dc2"
			cidr			= 	"192.168.0.0/16"
			az_list			= 	["us-west-2a","us-west-2b"]
			publ_subnet		= 	"192.168.7.0/24"
			priv_subnet		= 	"192.168.8.0/24"       
			intra_subnet 		= 	"192.168.9.0/24"       
		}   a*/	
	}   
}
##



