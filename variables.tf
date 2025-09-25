variable "project_name" {
  type    = string
  default = "rumotas-query"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "rumotas-query"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
