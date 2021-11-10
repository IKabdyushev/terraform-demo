terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
        region = "eu-north-1"
        shared_credentials_file = "~/.aws/credentials"
}

resource "aws_vpc" "main" {
  cidr_block = "10.8.0.0/16"
}

resource "aws_subnet" "new-private-01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.0.0/18"

  tags = {
    Name = "new-private-01"
  }
}

resource "aws_subnet" "new-private-02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.64.0/18"

  tags = {
    Name = "new-private-02"
  }
}

resource "aws_subnet" "new-public-01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.128.0/18"
  map_public_ip_on_launch = true

  tags = {
    Name = "new-public-01"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "default_rt" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myigw.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]

  tags = {
    Name = "myroutetable"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.default_rt.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "SSH from World"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]


  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2"
  public_key = file("~/.ssh/ec2.pub")}

resource "aws_instance" "test_instance" {
  ami           = "ami-0bd9c26722573e69b"
  instance_type = "t3.micro"
  key_name  = aws_key_pair.ec2.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.new-public-01.id
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "HelloWorld"
  }
}

output "instance_ip" {
  value = aws_instance.test_instance.*.public_ip
}