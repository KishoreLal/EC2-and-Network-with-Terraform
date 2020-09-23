variable "aws_region"{
    description = "Default AWS Region for this Pactice"
    default = "us-east-1"
}
variable "aws_amis"{
    type = map
    default = {
        us-east-1 = "ami-0c94855ba95c71c99"
        us-east-2 = "ami-07c8bc5c1ce9598c3"
    }
}
variable "key_name"{
    description = "CTS KeyPair"
}
variable "key_pair_path"{}
variable "AWS_ACCESS_KEY"{}
variable "AWS_SECRET_KEY"{}