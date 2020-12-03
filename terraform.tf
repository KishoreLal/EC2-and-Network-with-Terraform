 terraform{
     required_version =">0.12"
 }
 provider "aws"{
     region = var.aws_region
     access_key = var.AWS_ACCESS_KEY
     secret_key = var.AWS_SECRET_KEY
 }
