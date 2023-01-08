terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = merge(
    var.tags,
    { Name = "global-vpc" },
  )
}

resource "aws_subnet" "grafana_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.10.1.0/24"

  tags = merge(
    var.tags,
    { ame = "global-sub" },
  )
}

resource "aws_internet_gateway" "global_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    var.tags,
    { Name = "global-gw" },
  )
}

resource "aws_route" "my_route" {
  route_table_id         = aws_vpc.my_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.global_gw.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = "global-ssh" },
  )
}

resource "aws_security_group" "allow_grafana" {
  name        = "allow_grafana"
  description = "Allow grafana traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = "global-grafana" },
  )
}

resource "aws_key_pair" "deployer" {
  key_name   = "depl-key"
  public_key = file(var.public_key)

  tags = merge(
    var.tags,
    { Name = "global-key" },
  )
}

resource "aws_instance" "grafana" {
  count = var.ec2_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.grafana_subnet.id

  security_groups = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_grafana.id,
  ]

  key_name  = aws_key_pair.deployer.key_name
  user_data = file("./data/grafana.sh")

  tags = merge(
    var.tags,
    { Name = "global-grafana" },
  )
}
