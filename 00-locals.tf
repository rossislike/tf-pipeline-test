resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

locals {
  suffix = random_string.random.result
}