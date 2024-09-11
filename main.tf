# Create VPC
resource "aws_vpc" "jfrog_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "jfrog-vpc"
  }
}

# Create public subnet
resource "aws_subnet" "jfrog_pub_subnet_1" {
  vpc_id            = aws_vpc.jfrog_vpc.id
  cidr_block        = var.public_subnet_1_cidr_block
  availability_zone = var.availability_zone_1
  tags = {
    Name = "jfrog-pub-subnet"
  }
}

# Create private subnet
resource "aws_subnet" "jfrog_priv_subnet_1" {
  vpc_id            = aws_vpc.jfrog_vpc.id
  cidr_block        = var.private_subnet_1_cidr_block
  availability_zone = var.availability_zone_1
  tags = {
    Name = "jfrog-priv-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jfrog_vpc.id
  tags = {
    Name = "jfrog-igw"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "gateway_eip" {
  vpc = true
  tags = {
    Name = "jfrog-gateway-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "gateway" {
  allocation_id = aws_eip.gateway_eip.id
  subnet_id     = aws_subnet.jfrog_pub_subnet_1.id
  tags = {
    Name = "jfrog-nat-gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.jfrog_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jfrog-public-route-table"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.jfrog_pub_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.jfrog_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gateway.id
  }

  tags = {
    Name = "jfrog-private-route-table"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.jfrog_priv_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group for Public Instances (Bastion Host)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion instances"
  vpc_id      = aws_vpc.jfrog_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Private Instances (JFrog)
resource "aws_security_group" "jfrog_sg" {
  name        = "jfrog_sg"
  description = "Security group for JFrog instances"
  vpc_id      = aws_vpc.jfrog_vpc.id

  # Allow SSH access from the Bastion host only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.jfrog_pub_subnet_1.cidr_block]
  }

  # Allow access to JFrog ports (8081, 8082) from the Bastion host
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create public instance (Bastion Host)
resource "aws_instance" "public_instance_1" {
  ami                    = "ami-0a0e5d9c7acc336f1"  # Replace with your AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.jfrog_pub_subnet_1.id
  key_name               = "Terraform_1"  # Replace with your actual key pair name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "JFrog-Public"
  }
}

# Create private instance (JFrog)
resource "aws_instance" "private_instance_1" {
  ami                    = "ami-0a0e5d9c7acc336f1"  # Replace with your AMI ID
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.jfrog_priv_subnet_1.id
  key_name               = "Terraform_1"  # Replace with your actual key pair name
  vpc_security_group_ids = [aws_security_group.jfrog_sg.id]

  tags = {
    Name = "JFrog-Private"
  }
}

