resource "aws_instance" "wordpress" {
  tags = {
    Name = "Wordpress"
  }

  ami = "ami-0a0ff88d0f3f85a14"
  instance_type = "t2.micro"

  key_name = "wordpress"

  vpc_security_group_ids = [ aws_security_group.wordpress.id ]
  subnet_id = aws_subnet.wordpress.id

  associate_public_ip_address = true

  user_data = file("user_data.sh")


}