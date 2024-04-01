# Remote State Imports
data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "${var.s3_bucket_dev_state}"
    key    = "aws/fmk/dev/infrastructure/terraform.tfstate"
    region = "eu-west-2"
  }
}

# Set Provider and Region
provider "aws" {
  region = "eu-west-2"
}




resource "aws_lb_listener" "my_alb_listener80" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    order = 1
    type  = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

}

resource "aws_lb_listener" "my_alb_listener443" {
  certificate_arn   = "arn:aws:acm:eu-west-2:255950308419:certificate/9b879609-0a1e-41bd-b2d6-55df42e54de0"
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_lb_target_group.my_alb_tg.arn
    type             = "forward"
  }

  timeouts {}
}



# aws_lb_target_group.my_alb_tg:
resource "aws_lb_target_group" "my_alb_tg" {
  deregistration_delay          = 300
  load_balancing_algorithm_type = "round_robin"
  name                          = "alb-tg"
  port                          = 8080
  protocol                      = "HTTP"
  slow_start                    = 0
  tags                          = {}
  target_type                   = "instance"
  vpc_id                        = data.terraform_remote_state.infrastructure.outputs.vpc_id
  health_check {
    enabled           = true
    healthy_threshold = 5
    interval          = 30
    matcher           = "200-399"
    path              = "/"
    #port                = "8080"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 6
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
}




resource "aws_lb" "my-aws-alb" {
  enable_http2       = true
  idle_timeout       = 60
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "wsInternalELB"
  security_groups    = ["${aws_security_group.sg_public_elb.id}", "${data.terraform_remote_state.infrastructure.outputs.sg_public_pub_inst_id}"]
  subnets            = split(",", data.terraform_remote_state.infrastructure.outputs.public_subnet_ids)

  tags = {
    "Name"  = "wsInternalELB"
    "Owner" = "Terraform"
  }
}

# Create Instance Profile

resource "aws_iam_instance_profile" "instance_profile_ws" {
  name = "instance_profile_ws"
  #roles = ["${aws_iam_role.r_websvr.name}"]
  role = aws_iam_role.r_websvr.name
}

# ws ASG
module "asg_ws" {
  source                        = "../TF_common_modules/tf_aws_asg"
  lc_name                       = var.lc_ws_name
  lc_image_id                   = var.lc_ws_ami_id
  lc_instance_type              = "t2.small"
  lc_security_groups            = data.terraform_remote_state.infrastructure.outputs.sg_public_pub_inst_id
  lc_user_data                  = data.template_file.userdata.rendered
  lc_iam_instance_profile       = aws_iam_instance_profile.instance_profile_ws.id
  asg_health_check_grace_period = 600
  asg_name                      = var.asg_ws_name
  asg_app                       = "ws"
  asg_max_size                  = 1
  asg_min_size                  = 1
  asg_desired_capacity          = 1
  asg_availability_zones        = data.terraform_remote_state.infrastructure.outputs.private_availability_zones
  asg_subnets                   = data.terraform_remote_state.infrastructure.outputs.public_subnet_ids
  asg_load_balancers            = aws_lb_target_group.my_alb_tg.arn

}

data "template_file" "userdata" {
  template = file("ws_userdata.sh")
  vars = {
  }
}





resource "aws_vpc_endpoint" "endpoint" {
  vpc_id              = data.terraform_remote_state.infrastructure.outputs.vpc_id
  service_name        = "com.amazonaws.eu-west-2.email-smtp"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${data.terraform_remote_state.infrastructure.outputs.sg_public_pub_inst_id}"]
  subnet_ids          = split(",", data.terraform_remote_state.infrastructure.outputs.public_subnet_ids)
  private_dns_enabled = true
}
