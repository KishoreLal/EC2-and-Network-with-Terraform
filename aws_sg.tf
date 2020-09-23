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