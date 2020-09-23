resource "aws_key_pair" "server"{
    key_name = "cts_key"
    public_key = file("I:/Terraform/Practice/cts_key_public.pem")
}
resource "aws_iam_role" "ec2_role" {
    name = "ec2_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
tags = {
      Name = "ec2_role"
  }
}
resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_role.name
}
resource "aws_iam_role_policy" "ssm_policy"{
    name = "ssm_policy"
    role = aws_iam_role.ec2_role.name
    policy = file("I:/Terraform/Practice/ssm_role_policy.json")
}
