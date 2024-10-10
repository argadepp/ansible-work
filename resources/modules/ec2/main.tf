# Generate SSH key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to a local file
resource "local_file" "private_key" {
  filename = var.filepath
  content  = tls_private_key.example.private_key_pem
}

# Create EC2 Key Pair
resource "aws_key_pair" "generated_key" {
  key_name   = var.keyname
  public_key = tls_private_key.example.public_key_openssh
}

# Create EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami           = var.ami # Change to your desired AMI (Ubuntu/Debian/CentOS)
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  iam_instance_profile = var.aws_ssm_profile

  root_block_device {
    volume_size = 20

  }
  #User data script to configure the server post-creation
  user_data = <<-EOF
    #!/bin/bash
    # Allow password authentication
    sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl reload sshd

    # Create a new user and set password
    sudo useradd -m -s /bin/bash pratik
    echo "pratik:pratik" | sudo chpasswd

    # Add user to sudoers file with NOPASSWD
    echo "newuser ALL=(ALL) NOPASSWD:ALL" >> sudo etc/sudoers
  EOF

  tags = merge({Name= var.name},var.tags)
}

output "private_key_path" {
  value = local_file.private_key.filename
}
