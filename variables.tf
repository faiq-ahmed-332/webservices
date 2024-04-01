# VPC
variable "region" { default = "eu-west-2" }

# S3 Bucket Names
variable "s3_bucket_dev_state" { default = "fmk-test-state" }

# ELB
variable "ws_elb_name" { default = "wsInternalELB" }

# ASG
variable "asg_ws_name" { default = "ws-ASG" }
#variable "lc_ws_ami_id" { default = "ami-0c9ff8c9622a1927b" } ami-01a6e31ac994bbc09
#variable "lc_ws_ami_id" { default = "ami-09e474a882eecc426" } 
#variable "lc_ws_ami_id" { default = "ami-0f39d967118db34d9" } 
# variable "lc_ws_ami_id" { default = "ami-04c3ef6e87ddeaf0d" }
variable "lc_ws_ami_id" { default = "ami-0c6410d00051560f7" }
variable "lc_ws_name" { default = "ws-LC" }
