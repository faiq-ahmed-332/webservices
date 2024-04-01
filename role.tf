resource "aws_iam_role" "r_websvr" {
  name               = "r_webserver"
  assume_role_policy = file("r_websvr.json")

}

resource "aws_iam_role_policy" "rp_websvr" {
  name   = "rp_websvr"
  role   = aws_iam_role.r_websvr.id
  policy = file("ec2_pipe_access.json")
}


