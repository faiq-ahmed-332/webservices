# VPC
variable "region" { default = "eu-west-2" }

# S3 Bucket Names
variable "s3_bucket_dev_state" { default = "test-state" }

# ELB
variable "ws_elb_name" { default = "wsInternalELB" }

# ASG
variable "asg_ws_name" { default = "ws-ASG" }
variable "lc_ws_ami_id" { default = "" }
variable "lc_ws_name" { default = "ws-LC" }
