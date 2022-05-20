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
  new_root_pass    = "Route66!"
  client_username  = "mcfly"
  client_password  = "Zak3306!"
  client_cidr      = "91.175.201.225"
}