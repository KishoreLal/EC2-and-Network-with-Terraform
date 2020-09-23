 terraform{
     required_version =">0.12"
 }
 provider "aws"{
     region = var.aws_region
     access_key = var.AWS_ACCESS_KEY
     secret_key = var.AWS_SECRET_KEY
 }
 
resource "aws_instance" "web_server"{
    ami = var.aws_amis[var.aws_region]
    instance_type = "t2.micro"
    iam_instance_profile = "aws_iam_instance_profile.ec2_profile.name"
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