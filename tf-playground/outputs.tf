# ---------------------------------------------
#    Root Module Output return variables
# ---------------------------------------------

output "mysql-ssh" {
  value = join("",["ssh -i ", var.ssh_keys_path, " ec2-user@", module.mysql_server.public_ip])
}

output "talend-studio-ssh" {
  value = join("",["ssh -i ", var.ssh_keys_path, " ubuntu@", module.talend_studio.public_ip])
}

output "talend-studio-public-dns" {
  value = module.talend_studio.public_dns
}

output "node01_public_ip" {
  value = join("",["ssh -i ", var.ssh_keys_path," ec2-user@", module.cb_node01.public_ip])
}

output "node01_public_dns" {
  value = join("",["http://",module.cb_node01.public_dns,":8091"])
}

output "node02_public_ip" {
  value = join("",["ssh -i ", var.ssh_keys_path," ec2-user@", module.cb_node02.public_ip])
}

output "node02_public_dns" {
  value = join("",["http://",module.cb_node02.public_dns,":8091"])
}

output "node03_public_ip" {
  value = join("",["ssh -i ", var.ssh_keys_path," ec2-user@", module.cb_node03.public_ip])
}

output "node03_public_dns" {
  value = join("",["http://",module.cb_node03.public_dns,":8091"])
}