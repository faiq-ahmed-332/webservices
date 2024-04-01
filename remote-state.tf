terraform {
  backend "s3" {
    bucket  = "test-state"
    key     = "aws/dev/services/websvr/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

