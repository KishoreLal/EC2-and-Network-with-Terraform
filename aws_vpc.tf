resource "aws_vpc" "main_vpc"{
     cidr_block = "10.0.0.0/16"
     tags = {
         Name = "Terraform VPC"
     }
 }
 resource "aws_internet_gateway" "main_gw"{
     vpc_id = aws_vpc.main_vpc.id
     tags = {
         Name = "Main IG"
     }
 }
 resource "aws_subnet" "public_subnet"{
     vpc_id = aws_vpc.main_vpc.id 
     cidr_block = "10.0.0.0/24"
     map_public_ip_on_launch = "true"
     tags = {
         Name = "Public Subnet"
     }
 }
 resource "aws_subnet" "private_subnet"{
     vpc_id = aws_vpc.main_vpc.id 
     cidr_block = "10.0.1.0/24"
     tags = {
         Name = "Private Subnet"
     }
 }
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
