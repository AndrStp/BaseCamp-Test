terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.3.0"
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
  cidr_block = "172.16.0.0/16"

  tags = merge(
    var.tags,
    { Name = "globa-vpc" },
  )
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-central-1a"

  tags = merge(
    var.tags,
    { Name = "global-subnet" },
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


resource "aws_key_pair" "deployer" {
  key_name   = "depl-key"
  public_key = file(var.public_key)

  tags = merge(
    var.tags,
    { Name = "global-key" },
  )
}

resource "aws_instance" "my_ec2" {
  count         = var.ec2_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type

  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  key_name = aws_key_pair.deployer.key_name

  tags = merge(
    var.tags,
    { Name = "node-${count.index}" },
  )

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key)
  }

  provisioner "remote-exec" {
    inline = ["echo Ready to go!"]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.private_key} ${path.root}/../ansible/harden.yaml"
  }
}

resource "local_file" "ansible_inventory" {
    content = templatefile("${path.root}/../ansible/inventory.tmpl",
      {nodes = tomap(
        { for ec2 in aws_instance.my_ec2:
          ec2.tags["Name"] => ec2.public_ip
        }
      )}
    )

    filename = "../ansible/hosts.ini"
}