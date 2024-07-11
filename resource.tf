resource "aws_default_vpc" "default" {}

resource "aws_instance" "terransible" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
}


resource "null_resource" "install_ansible" {

  count = var.instance_count

  # ssh into EC2 instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./mtc-terransible.pem")
    host        = aws_instance.terransible[count.index].public_ip
  }

  # copy the install_ansible.sh file from our computer to the EC2 instance
  provisioner "file" {
    source      = "./install_ansible.sh"
    destination = "/tmp/install_ansible.sh"

  }

  # set permission & run the install_ansible.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_ansible.sh",
      "sudo sh /tmp/install_ansible.sh",
    ]
  }

  wait for ec2 to be created
  depends_on = [aws_instance.terransible]
}



resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg"
  description = "Allow inbound traffic on port 22, 80 & 8080"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

