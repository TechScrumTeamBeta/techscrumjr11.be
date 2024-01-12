region                  = "ap-southeast-2"
projectName             = "techscrum"
vpc_cidr                = "10.0.0.0/16"
public_subnet_cidrs     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
route_table_cidr_block  = "0.0.0.0/0"
aws_availabbility_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
environment             = "uat"
instance_types          = "t3.small"
cluster_version         = "1.28"
k8s_cluster_name        = "techscrum-prod"
hosted_zone_name        = "techscrum11.com"
# alb_zone_id             = "Z1GM3OXH4ZPM65"

#node peak time ,node。  pod --hpa node 减少增加。
# eksctl node  ec2 关闭，白天。 eks。  tigger lambda  scale up in  node.
