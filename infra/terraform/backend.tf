terraform {
  backend "s3" {
    bucket       = "hng-stage6-terraform-state"
    key          = "devops/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
