/*variable "profile"{
default = aws
type = string
description = "profile for my project"
}
variable "acess_key"{
aws__access_key = "AKIAXJ63MHKTESRZY3GV"
type = string
}
variable "secret_key"{
aws_secret_key = "eGzo0Ye91hvK41FwVCKasnNoCxwPhwEus/pBJSm7"
type = string
}*/
variable "region" {
default = "us-east-1"
type = string
description = "region for my vpc"
}
variable "vpc_cidr" {
default = "172.32.0.0/16"
type = string
description = "cidr block for my vpc"
}
variable "public_subnets" {
default = ["172.32.1.0/24","172.32.2.0/24","172.32.3.0/24","172.32.4.0/24"]
type = list
description = "cidr for public subnets"
}
variable "private_subnets" {
default = ["172.32.5.0/24", "172.32.6.0/24","172.32.7.0/24"]
type = list
description = "cidr for private subnets"
}
variable "az_list" {
default = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d"]
type = list 
description = "az list"
}
