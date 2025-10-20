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
  default     = "0.0.0.0/0"
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

variable "ai_instance_type_test" {
  description = "AI EC2 instance type for test"
  type        = string
  default     = "c7i.large"
}

variable "ai_instance_type_prod" {
  description = "AI EC2 instance type for production"
  type        = string
  default     = "c7i.xlarge"
}
variable "ai_container_image" {
  description = "Docker image for AI service"
  type        = string
  default     = "sudhaaym/ats-ai-service:latest"
  validation {
    condition     = can(regex("^[\\w./:-]+$", var.ai_container_image))
    error_message = "ai_container_image must look like a valid Docker image reference."
  }
}

variable "ai_container_port" {
  description = "Container port exposed by the AI service"
  type        = number
  default     = 9090
  validation {
    condition     = var.ai_container_port > 0 && var.ai_container_port < 65536
    error_message = "ai_container_port must be between 1 and 65535."
  }
}

variable "health_path" {
  description = "Health check path for the AI service"
  type        = string
  default     = "/healthz"
}