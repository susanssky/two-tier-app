# resource "tls_private_key" "key-pair-for-ec2" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "ssh_key" {
#   key_name   = "tf-aws-ec2-key"
#   public_key = tls_private_key.key-pair-for-ec2.public_key_openssh

#   # provisioner "local-exec" { # Create a .pem to your computer
#   #   command = "echo '${tls_private_key.key-pair-for-ec2.private_key_pem}' > ./${aws_key_pair.ssh_key.key_name}.pem"
#   # }
# }
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  depends_on = [aws_iam_role_policy_attachment.attach]
  name       = "ec2_ssm"
  role       = aws_iam_role.ssm.name
}
resource "aws_instance" "backend" {
  ami                  = "ami-07c1b39b7b3d2525d" //hard code because "data" can not filter free tier ami Ubuntu Server 24.04 LTS (HVM), SSD Volume Type (64-bit (x86))
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  # key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  availability_zone           = aws_subnet.public[0].availability_zone
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo snap install amazon-ssm-agent --classic
sudo snap list amazon-ssm-agent
sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent
sudo apt update
sudo apt install postgresql -y
sudo apt install stress -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod 666 /var/run/docker.sock
EOF



  tags = {
    Name = "original-${local.project_name}-ec2"
  }
}

