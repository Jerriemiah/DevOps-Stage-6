resource "aws_key_pair" "hng_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0009374626bb2af70" # Ubuntu 24.04 in us-east-1
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  key_name               = aws_key_pair.hng_key.key_name

  tags = {
    Name = "HNG-Stage6-Server"
  }

  root_block_device {
    volume_size = 30
  }
}
