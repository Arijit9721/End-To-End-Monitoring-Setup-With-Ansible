terraform {
  backend "s3" {
    bucket       = "arijit21-s3-backend-terraform"
    key          = "terraform/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}