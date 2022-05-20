# ---------------------------------------------
#    Root Module Output return variables
# ---------------------------------------------

output "mysql-ssh" {
  value = join("",["ssh -i ", var.ssh_keys_path, " ec2-user@", module.node01.public_ip])
}