# key to connect to the ec2 instance
resource "tls_private_key" "main_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# key to enable ansible passwordless ssh
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main_key_pair" {
  key_name   = "main-key-pair"
  public_key = tls_private_key.main_key.public_key_openssh
}

resource "aws_key_pair" "ansible_key_pair" {
  key_name   = "ansible-key-pair"
  public_key = tls_private_key.ansible_key.public_key_openssh
}

# The ansible hub node
resource "aws_instance" "ansible_ec2" {
  instance_type = var.ansible_instance_type
  ami           = var.ami
  key_name      = aws_key_pair.main_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ansible_ec2_profile.name
  user_data = base64encode(file("${path.module}/ansible_ec2_data.sh"))
  depends_on = [ aws_key_pair.main_key_pair, aws_key_pair.ansible_key_pair, aws_iam_instance_profile.ansible_ec2_profile ]

  tags = {
    Name = "ansible-ec2"
  }
}

# The spoke nodes
resource "aws_instance" "spoke_ec2" {
  count = var.spoke_count
  instance_type = var.worker_instance_type
  ami           = var.ami
  key_name      = aws_key_pair.main_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = base64encode(file("${path.module}/worker_ec2_data.sh"))
  depends_on = [ aws_key_pair.main_key_pair, aws_key_pair.ansible_key_pair]

  tags = {
    Name = "spoke-ec2-${count.index + 1}"
  }
}