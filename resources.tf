//Provision AWS Key Pair for SSH into Instance
resource "aws_key_pair" "server"{
    key_name = "cts_key"
    public_key = file("I:/Terraform/Practice/cts_key_public.pem")
}
//Provision IAM Role for EC2
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
//Configure IAM Intance profile connecting with IAM role 
resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_role.name
}
resource "aws_iam_role_policy" "ssm_policy"{
    name = "ssm_policy"
    role = aws_iam_role.ec2_role.name
    policy = file("I:/Terraform/Practice/ssm_role_policy.json")
}

//Creating an Instance for Web server
resource "aws_instance" "web_server"{
    ami = var.aws_amis[var.aws_region]
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    key_name = "cts_key"
    vpc_security_group_ids = [aws_security_group.terraform_sg.id]
    subnet_id = aws_subnet.public_subnet.id 
    //associate_public_ip_address = true 
    tags = {
        Name = "Terraform Instance"
    }
    connection {
        type = "ssh"
        user = "ec2-user"
        password = ""
        private_key = file(var.key_pair_path)
        host = self.public_ip
    } 
    provisioner "remote-exec" {
        inline = [
        "sudo yum install httpd -y",
        "sudo service httpd start",
        "cd /var/www/html",
        "echo 'Hello Welcome' >> index.html",
        "cd /tmp",
        "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm",
        /*"sudo systemctl enable amazon-ssm-agent",
        "sudo systemctl start amazon-ssm-agent"
        "cd ..",
        "sudo su",
        "yum install httpd -y",
        "sudo service httpd start",
        "nano 'Hello!!! Welcome' >> /var/www/html/index.html"*/
        ]
    }
}
//Creating AWS Security group to allow SSH and HTTP traffic.
resource "aws_security_group" "terraform_sg"{
    name = "TCP SSH Security Group"
    description = "Allow SSH Access to the instance"
    vpc_id = aws_vpc.main_vpc.id 
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["42.109.137.23/32"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["42.109.137.23/32"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

//Creating AWS VPC
resource "aws_vpc" "main_vpc"{
     cidr_block = "10.0.0.0/16"
     tags = {
         Name = "Terraform VPC"
     }
 }
 //Creating Internet Gateway to allow Internet access
 resource "aws_internet_gateway" "main_gw"{
     vpc_id = aws_vpc.main_vpc.id
     tags = {
         Name = "Main IG"
     }
 }
 //Creating AWS Publc Subnet
 resource "aws_subnet" "public_subnet"{
     vpc_id = aws_vpc.main_vpc.id 
     cidr_block = "10.0.0.0/24"
     map_public_ip_on_launch = "true"
     tags = {
         Name = "Public Subnet"
     }
 }
 //Creating AWS Private Subnet
 resource "aws_subnet" "private_subnet"{
     vpc_id = aws_vpc.main_vpc.id 
     cidr_block = "10.0.1.0/24"
     tags = {
         Name = "Private Subnet"
     }
 }
 //Configure Route Table to allow Outside traffic 
 resource "aws_route_table" "Main_route"{
     vpc_id = aws_vpc.main_vpc.id 
     route {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.main_gw.id
     }
     tags = {
         Name = "Terraform_Route"
     }
 }
resource "aws_route_table_association" "rt_associate"{
    route_table_id = aws_route_table.Main_route.id
    subnet_id = aws_subnet.public_subnet.id
}

