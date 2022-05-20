# ----------------------------------------
#            Root module
# ----------------------------------------

# Shared tfstate
terraform {
  backend "s3" {
    region = "eu-north-1"
    key    = "couchbase-talend-migration-tfstate"
    bucket = "a-tfstate-rch"
  }
}

# Provider config
provider "aws" {
  region = var.region_target
}

# Create a key-pair for logging into ec2 instances
resource "aws_key_pair" "this" {
  key_name   = join("-",[var.resource_tags["project"],var.resource_tags["environment"]])
  public_key = file(join("",[var.ssh_keys_path,".pub"]))
  tags = {
    Name        = join("-",["key-pair", var.resource_tags["project"],var.resource_tags["environment"]])
    Project     = var.resource_tags["project"]
    Owner       = var.resource_tags["owner"]
    Environment = var.resource_tags["environment"]
  }
} 

# Call network module
module "network" {
  source                    = "./modules/network"
  resource_tags             = var.resource_tags
  vpc_cidr_block            = "10.0.0.0/28"
  public_subnet_cidr_block  = "10.0.0.0/28"
}

# Call compute module
module "mysql_server" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "mysql"
  instance_ami_id        = "ami-08bdc08970fcbd34a"
  instance_type          = "t3.medium"
  root_volume_size       = 8
  user_data_script_path  = "scripts/mysql-init.sh"
  user_data_args         = var.mysql_configuration
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}

# Call compute module
module "talend_studio" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "ubuntu-18-04"
  instance_ami_id        = "ami-022b0631072a1aefe"
  instance_type          = "t3.2xlarge"
  root_volume_size       = 12
  user_data_script_path  = "scripts/talend-studio-init.sh"
  user_data_args         = {services="data"}
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}

# Call compute module
module "cb_node01" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "cbnode01"
  instance_ami_id        = "ami-08bdc08970fcbd34a"
  instance_type          = "t3.medium"
  root_volume_size       = 8
  user_data_script_path  = "scripts/couchbase-cluster-init.sh"
  user_data_args         = merge(var.couchbase_configuration, {services="data"})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}

# Call compute module
module "cb_node02" {
  source                 = "./modules/compute"
  depends_on             = [module.cb_node01]
  resource_tags          = var.resource_tags
  base_name              = "cbnode02"
  instance_ami_id        = "ami-08bdc08970fcbd34a"
  instance_type          = "t3.medium"
  root_volume_size       = 8
  user_data_script_path  = "scripts/couchbase-server-add.sh"
  user_data_args         = merge(var.couchbase_configuration, {cluster_uri=module.cb_node01.public_dns}, {services="data"})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}

# Call compute module
module "cb_node03" {
  source                 = "./modules/compute"
  depends_on             = [module.cb_node01]
  resource_tags          = var.resource_tags
  base_name              = "cbnode03"
  instance_ami_id        = "ami-08bdc08970fcbd34a"
  instance_type          = "t3.medium"
  root_volume_size       = 8
  user_data_script_path  = "scripts/couchbase-server-add.sh"
  user_data_args         = merge(var.couchbase_configuration, {cluster_uri=module.cb_node01.public_dns}, {services="data"})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}
