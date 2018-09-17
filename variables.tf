# variables

variable "ec2_keypair" {
  type        = "string"
  description = "Name of EC2 keypair to control SSH access to ECS nodes (must already exist)"
  default     = ""
}

variable "ecs_servers" {
  type    = "string"
  default = 2
}

variable "ecs_min_servers" {
  type    = "string"
  default = 2
}

variable "ecs_instance_type" {
  type    = "string"
  default = "t3.micro"
}

variable "vpc_name" {
  type        = "string"
  description = "Name of VPC to be created (must be DNS-compliant)"
}

variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}
