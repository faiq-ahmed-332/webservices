# ws instance SG used by launch configuration
resource "aws_security_group" "sg_appdata_ws" {
    name = "sg_appdata_ws"
    vpc_id = "${data.terraform_remote_state.infrastructure.outputs.vpc_id}"
    description = "Workspace private Security Group for the ws Instance"
    tags = {
        Name = "sg_appdata_ws"
        Owner = "terraform"
    }

}

resource "aws_security_group_rule" "sg_appdata_ws_ingress_sg_public_elb_ssh" {
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  security_group_id = "${aws_security_group.sg_appdata_ws.id}"
  cidr_blocks = ["${data.terraform_remote_state.infrastructure.outputs.vpc_cidr}"]
}
resource "aws_security_group_rule" "sg_appdata_ws_ingress_sg_public_elb_http" {
  type = "ingress"
  from_port = "8080"
  to_port = "8080"
  protocol = "tcp"
  security_group_id = "${aws_security_group.sg_appdata_ws.id}"
  cidr_blocks = ["${data.terraform_remote_state.infrastructure.outputs.vpc_cidr}"]
}

resource "aws_security_group_rule" "sg_appdata_ws_egress" {
  type = "egress"
  from_port = "0"
  to_port = "0"
  protocol = "-1"
  security_group_id = "${aws_security_group.sg_appdata_ws.id}"
  cidr_blocks = ["${data.terraform_remote_state.infrastructure.outputs.vpc_cidr}"]
}

## ws ELB Security Groups

resource "aws_security_group" "sg_public_elb" {
    name = "sg_public_elb"
    vpc_id = "${data.terraform_remote_state.infrastructure.outputs.vpc_id}"
    description = "security Group for the ws External ELB"
    tags = {
        Name = "sg_public_elb"
        Owner = "terraform"
    }

}

//resource "aws_security_group_rule" "sg_public_elb_ingress_sg_appdata_ws_1" {
//  type = "ingress"
//  from_port = "22"
//  to_port = "22"
//  protocol = "tcp"
//  security_group_id = "${aws_security_group.sg_public_elb.id}"
//  cidr_blocks = ["0.0.0.0/0"]
//}

//resource "aws_security_group_rule" "sg_public_elb_ingress_sg_appdata_ws_http" {
//  type = "ingress"
//  from_port = "8080"
//  to_port = "8080"
//  protocol = "tcp"
//  security_group_id = "${aws_security_group.sg_public_elb.id}"
//  cidr_blocks = ["0.0.0.0/0"]
//}

resource "aws_security_group_rule" "sg_public_elb_ingress_sg_appdata_ws_https" {
  type = "ingress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  security_group_id = "${aws_security_group.sg_public_elb.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_public_elb_egress" {
  type = "egress"
  from_port = "0"
  to_port = "0"
  protocol = "-1"
  security_group_id = "${aws_security_group.sg_public_elb.id}"
  cidr_blocks = ["0.0.0.0/0"]
}


