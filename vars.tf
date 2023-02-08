/*  Terraform variables defined here. 
      Dan Edeen, dan@dsblue.net, 2022 
*/

# VPC parms, can build mutiple by passing in via this map 
variable "app_vpcs" {
	description = "VPC Variables"
	type		= map(any)

	default = {
		app1vpc = {
			map_key			= 	"app1vpc"	# Easy way to dereference map elements, must match var name to work
			region_dc		= 	"App01-VPC"
			cidr			= 	"10.104.0.0/16"
			az_list			= 	["us-west-2a","us-west-2a","us-west-2b","us-west-2b"]
			vpc_subnets		= 	["10.104.0.0/24","10.104.1.0/24","10.104.128.0/24","10.104.129.0/24"]
			subnet_names		= 	["app1-az1-inst","app1-az1-TGW", "app1-az2-inst","app1-az2-TGW"]
		},
		app2vpc = {
			map_key			= 	"app2vpc"
			region_dc		= 	"App02-VPC"
			cidr			= 	"10.105.0.0/16"
			az_list			= 	["us-west-2a","us-west-2a","us-west-2b","us-west-2b"]
			vpc_subnets		= 	["10.105.0.0/24","10.105.1.0/24","10.105.128.0/24","10.105.129.0/24"]
			subnet_names		= 	["app2-az1-inst","app2-az1-TGW", "app2-az2-inst","app1-az2-TGW"]
		},  
		mgmtvpc = {
			map_key			= 	"mgmtvpc"
			region_dc		= 	"Mgmt-VPC"
			cidr			= 	"10.255.0.0/16"
			az_list			= 	["us-west-2a","us-west-2a","us-west-2b","us-west-2b"]
			vpc_subnets		= 	["10.255.0.0/24","10.255.1.0/24","10.255.128.0/24","10.255.129.0/24"]
			subnet_names		= 	["mgmt-az1-inst","mgmt-az1-TGW","mgmt-az2-inst","mgmt-az2-TGW"]
		}  
		onpremvpc = {
			map_key			= 	"onpremvpc"
			region_dc		= 	"On-Prem-DC"
			cidr			= 	"10.5.0.0/16"
			az_list			= 	["us-west-2a"]
			vpc_subnets		= 	["10.5.0.0/18"]
			subnet_names		= 	["On-Prem-subnet"]
		}  
		secvpc = {		
			map_key			= 	"secvpc"
			region_dc		= 	"Sec01-VPC"
			cidr			= 	"10.100.0.0/16"
			az_list			= 	["us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2b","us-west-2b","us-west-2b","us-west-2b","us-west-2b","us-west-2b"]
			vpc_subnets		= 	["10.100.0.0/24","10.100.1.0/24","10.100.2.0/24","10.100.3.0/24","10.100.4.0/24","10.100.5.0/24","10.100.64.0/24","10.100.65.0/24","10.100.66.0/24","10.100.67.0/24","10.100.68.0/24","10.100.69.0/24"]
			subnet_names	= 		["sec-az1-mgt","sec-az1-int","sec-az1-pub","sec-az1-TGW_Att","sec-az1-GWLB_EndPt","sec-az1-GWLB","sec-az2-mgt","sec-az2-int","sec-az2-pub","sec-az2-TGW_Att","sec-az2-GWLB_EndPt","sec-az2-GWLB"]
		
		}
	}   
}
##
