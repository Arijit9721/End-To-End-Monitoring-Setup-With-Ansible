data "aws_default_vpc" "default_vpc" {}

# Security Group for all the EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  vpc_id      = data.aws_default_vpc.default_vpc.id

  tags ={
    Name = "ec2-sg"
  }
}

# Allow ssh on port 22
resource "aws_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow http on port 80
resource "aws_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow https on port 443
resource "aws_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow all outbound traffic
resource "aws_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
