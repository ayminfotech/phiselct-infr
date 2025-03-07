variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment, e.g. test or prod"
  type        = string
  default     = "test"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (bastion)"
  type        = string
  default     = "106.51.165.20/32"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "phi"
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
  default     = "Z08261293CYIT8T9GXXEY"
}