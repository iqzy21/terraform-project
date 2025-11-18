resource "aws_security_group" "wordpress" {
  name        = "wordpressSG"
  description = "Allow EC2 wordpress inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.wordpress.id
  tags = {
    Name = "wordpressSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.wordpress.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "inbound_http" {
  security_group_id = aws_security_group.wordpress.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "outbound_all" {
  security_group_id = aws_security_group.wordpress.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}