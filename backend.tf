terraform {
  backend "s3" {
    bucket         = "kc-aws-governance-tfstate"
    key            = "aws-governance/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
