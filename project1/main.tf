# Requirements: key pair, VPC & security group, ec2 instance

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# key pair
resource "aws_key_pair" "my_key" {
    key_name = "terra-key"
    public_key = file("terra-key.pub")
}

# vpc & security group
resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "my_security_group" {
    name = "automate-sg"
    description = "This will add an TF generated security group"
    vpc_id = aws_default_vpc.default.id   # interpolation
    # inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH open"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP open"
    }
    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Flask app"
    }
    # outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "all access open"
    }


        tags = {
            Name = "automate-sg"
        }
}

# ec2 instance
resource "aws_instance" "my-test" {
    for_each = tomap ({
        Test-master-ubuntu = "ami-0279a86684f669718"
        Test-slave1-aws = "ami-09739caf42748cab9"
        Test-slave2-rhel = "ami-02010f4ba46655bb2"
    }) # meta argument

    depends_on = [aws_security_group.my_security_group, aws_key_pair.my_key]

    key_name = aws_key_pair.my_key.key_name
    vpc_security_group_ids = [aws_security_group.my_security_group.id]
    instance_type = var.ec2_instance_type
    ami = each.value  
    subnet_id = data.aws_subnets.default.ids[0]   # Specify subnet explicitly
    associate_public_ip_address = true
    # user_data = file("install_nginx.sh")
    root_block_device {
        volume_size = var.env == "prd" ? 20 : var.ec2_default_root_storage_size    # if env is prd then 20GiB otherwise default root storage
        volume_type = "gp3"
    }
    tags = {
        Name = each.key
        Environment = var.env
    }
}


# To import existing server into terraform, use terraform import command and below code
# resource "aws_instance" "manual_instance" {
#     ami = "unknown"
#     instance_type = "unknown"
# }

