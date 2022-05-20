# ----------------------------------------
#    Default main config - Staging env
# ----------------------------------------

region_target = "eu-north-1"

resource_tags = {
  project     = "couchbase-talend-migration"
  environment = "staging-rch"
  owner       = "raphael.chir@couchbase.com"
}

ssh_keys_path = "/sandbox/tf-playground/.ssh/zkey"

mysql_configuration = {
  new_root_pass               = "Route66!"
  client_username             = "mcfly"
  client_password             = "Zak3306!"
  client_cidr                 = "91.175.201.225"
  private_net_client_username = "talend"
  private_net_client_password = "Talend2022!"
  private_net_client_cidr     = "10.0.0.0/28"
}

couchbase_configuration = {
  cluster_name    = "terracluster-playgound"
  cluster_username  = "admin"
  cluster_password  = "111111"
}