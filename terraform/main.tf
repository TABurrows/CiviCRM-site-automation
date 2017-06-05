###############################################
# Terraform Build Script
###############################################


# ===================================================================================
# Specify the provider with frontend
# ===================================================================================
provider "aws" {
  #access_key                = "${var.access_key}"
  #secret_key                = "${var.secret_key}"
  region                    = "${var.region_name}"
}

# ===================================================================================
# Upload the key to AWS
# ===================================================================================
resource "aws_key_pair" "clientkey" {
    key_name                = "${var.key_name}"
    public_key              = "${file(var.public_key_path)}"
}


# ===================================================================================
# Build the main VPC
# ===================================================================================
resource "aws_vpc" "main" {
  cidr_block                = "${var.vpc_subnet_range}"
  enable_dns_hostnames      = true
  enable_dns_support        = true
  tags {
    Name                    = "${var.client_short_name}-VPC"
    Group                   = "${var.client_short_name}"
  }
}


# ===================================================================================
# Specify the main VPC's Internet Gateway
# ===================================================================================
resource "aws_internet_gateway" "main" {
  vpc_id                    = "${aws_vpc.main.id}"
  tags {
    Name                    = "${var.client_short_name}-MAIN-INTERNET-GATEWAY"
    Group                   = "${var.client_short_name}"
  }
}


# ===================================================================================
# Specify an internet access route
# ===================================================================================
resource "aws_route" "internet_access" {
    route_table_id          = "${aws_vpc.main.main_route_table_id}"
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = "${aws_internet_gateway.main.id}"
}



# ===================================================================================
# Define a public subnet for launching load balancers
# ===================================================================================
resource "aws_subnet" "public" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "${var.public_subnet_range}"
    map_public_ip_on_launch = true
    tags {
        Name                = "${var.client_short_name}-PUBLIC-SUBNET"
        Group               = "${var.client_short_name}"
    }
}


# ===================================================================================
# Build the Security group
# ===================================================================================
resource "aws_security_group" "default" {
    name            = "sec_group_default"
    description     = "Security group for default access to the subnets"
    vpc_id          = "${aws_vpc.main.id}"

    # SSH access from anywhere
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTPS access from anywhere
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow outbound internet access
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        Name                    = "${var.client_short_name}-SECURITY-GROUP"
        Group                   = "${var.client_short_name}"
    }
  }


# ===================================================================================
# Create instance
# ===================================================================================
resource "aws_instance" "www" {
  associate_public_ip_address   = true
  key_name                  = "${aws_key_pair.clientkey.key_name}"
  instance_type             = "${var.instance_type}"
  ami                       = "${var.ami_id}"
  vpc_security_group_ids    = ["${aws_security_group.default.id}"]
  subnet_id                 = "${aws_subnet.public.id}"
  connection {
    user            = "centos"
    key_name        = "${aws_key_pair.clientkey.key_name}"
    private_key     = "${file(var.private_key)}"
  }
  tags {
    Name                    = "${var.client_short_name}-WEBSERVER"
    Group                   = "${var.client_short_name}"
  }
   provisioner "remote-exec" {
    inline = [
      "sudo yum -y update"
    ]
  }
    provisioner "local-exec" {
        command = "cp ${var.exec_path}/ansible/hosts ${var.exec_path}/hosts.aws"
    }
    provisioner "local-exec" {
        command = "sed -i 's/AWS_PUBLIC_IP/${aws_instance.www.public_ip}/g' ${var.exec_path}/hosts.aws"
    }
    provisioner "local-exec" {
          command = "ssh -i ${var.private_key} -o StrictHostKeyChecking=no centos@${aws_instance.www.public_ip} uptime" 
    }
    provisioner "remote-exec" {
        inline = [
            "echo '#!/bin/bash' > /tmp/public_ip_address.sh",
            "echo 'export PUBLIC_IP_ADDRESS=${aws_instance.www.public_ip}'>>/tmp/public_ip_address.sh",
            "chmod a+x /tmp/public_ip_address.sh",
            "sudo mv /tmp/public_ip_address.sh /etc/profile.d/public_ip_address.sh",
        ]
    }
    provisioner "local-exec" {
        command = "sleep 30 && ansible-playbook -u centos -i ${var.exec_path}/hosts.aws --private-key ${var.private_key}  -s ${var.exec_path}/${var.ansible_playbook} -T 300",
    }
    provisioner "remote-exec" {
        inline = [
            "sudo shutdown -r now"
        ]
    }
}

