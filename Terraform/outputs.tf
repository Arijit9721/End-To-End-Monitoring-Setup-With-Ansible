output "ansible_hub_public_ip" {
  description = "Public IP address of the Ansible Hub EC2 instance"
  value       = module.main.ansible_ec2_public_ip
}

output "spoke_instances_public_ips" {
  description = "Public IP addresses of all spoke EC2 instances"
  value       = module.main.spoke_ec2_public_ips
}
