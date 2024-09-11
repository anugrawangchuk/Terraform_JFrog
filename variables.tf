variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
}

variable "public_subnet_1_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public Subnet 1 CIDR Block"
}

variable "private_subnet_1_cidr_block" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Private Subnet 1 CIDR Block"
}

variable "availability_zone_1" {
  type        = string
  default     = "us-east-1a"
  description = "Availability Zone 1"
}
variable "instance_type_public" {
  type        = string
  default     = "t2.micro"
  description = "Instance Type for Public Subnet"
}

variable "instance_type_private" {
  type        = string
  default     = "t2.large"
  description = "Instance Type for Private Subnet"
}

variable "os_public" {
  type        = string
  default     = "ubuntu-22.04"
  description = "OS for Public Subnet Instances"
}

variable "os_private" {
  type        = string
  default     = "ubuntu-22.04"
  description = "OS for Private Subnet Instances"
}
