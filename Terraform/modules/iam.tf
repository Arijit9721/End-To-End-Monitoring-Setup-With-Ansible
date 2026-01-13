resource "aws_iam_role" "ansible_ec2_role" {
  name = "ansible-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ansible_ec2_policy" {
  name        = "ansible-ec2-policy"
  path        = "/"
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:*",
          "iam:*",
          "cloudwatch:*"
        ]
        Effect   = "Allow"
        Resource = "*" 
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ansible_ec2_attach" {
  role       = aws_iam_role.ansible_ec2_role.name
  policy_arn = aws_iam_policy.ansible_ec2_policy.arn
}

resource "aws_iam_instance_profile" "ansible_ec2_profile" {
  name = "ansible-ec2-instance-profile"
  role = aws_iam_role.ansible_ec2_role.name
}
