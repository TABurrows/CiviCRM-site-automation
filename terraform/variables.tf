# ###################################
#  Terraform variables
# ###################################
variable "access_key" {}

variable "secret_key" {}

variable "client_short_name" {}

variable "client_desc" {}

variable "ami_id" {}

variable "region_name" {}

variable "key_name" {}

variable "private_key" {}

variable "public_key_path" {}

variable "exec_path" {}

variable "instance_type" {
    default = "t2.micro"
}

variable "ansible_playbook" {
    default = "ansible/civicrm.aws.yml"
}

variable "vpc_subnet_range" {
    description = "Subnet block for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_range" {
    description = "Subnet block for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_range" {
    description = "Subnet block for the Private Subnet"
    default = "10.0.10.0/24"
}