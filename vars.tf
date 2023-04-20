/*  Terraform variables defined here. 
      Dan Edeen, dan@dsblue.net, 2023 
*/

# VPC parms, can build mutiple by passing in via this map 
variable "app_vpcs" {
	description = "VPC Variables"
	type		= map(any)

	default = {
		secvpc = {		
			map_key			= 	"secvpc"
			region_dc		= 	"Sec01-VPC"
			cidr			= 	"10.100.0.0/16"
			az_list			= 	["us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2b","us-west-2b","us-west-2b","us-west-2b","us-west-2b","us-west-2b","us-west-2a","us-west-2b"]
			vpc_subnets		= 	["10.100.0.0/24","10.100.1.0/24","10.100.2.0/24","10.100.3.0/24","10.100.4.0/24","10.100.5.0/24","10.100.64.0/24","10.100.65.0/24","10.100.66.0/24","10.100.67.0/24","10.100.68.0/24","10.100.69.0/24","10.100.6.0/24","10.100.70.0/24"]
			subnet_names	= 		["sec-az1-mgt","sec-az1-int","sec-az1-pub","sec-az1-TGW_Att","sec-az1-GWLB_EndPt","sec-az1-GWLB","sec-az2-mgt","sec-az2-int","sec-az2-pub","sec-az2-TGW_Att","sec-az2-GWLB_EndPt","sec-az2-GWLB","sec-az1-vpn","sec-az2-vpn"]
		
		}
		
	}   
}

