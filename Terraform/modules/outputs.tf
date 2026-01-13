output "ansible_ec2_public_ip" {
  description = "Public IP of the Ansible Hub EC2 instance"
  value       = aws_instance.ansible_ec2.public_ip
}

output "spoke_ec2_public_ips" {
  description = "Public IPs of all spoke EC2 instances"
  value       = aws_instance.spoke_ec2[*].public_ip
}
