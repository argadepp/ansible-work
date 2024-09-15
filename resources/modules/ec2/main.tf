# Generate SSH key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to a local file
resource "local_file" "private_key" {
  filename = "/home/pratik/.ssh/ansible"
  content  = tls_private_key.example.private_key_pem
}

# Create EC2 Key Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Create EC2 Instance
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id # Change to your desired AMI (Ubuntu/Debian/CentOS)
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  # User data script to configure the server post-creation
  # user_data = <<-EOF
  #   #!/bin/bash
  #   # Update the package repository and install required packages
  #   yum update -y  # For Amazon Linux
  #   apt-get update -y  # For Ubuntu

  #   # Set 'PasswordAuthentication yes' in the SSH config file
  #   if grep -q "^PasswordAuthentication" /etc/ssh/sshd_config; then
  #       sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  #   else
  #       echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
  #   fi

  #   # Reload the SSH daemon to apply the changes
  #   systemctl restart sshd

  #   # Create a user with a password
  #   USERNAME="pratik"
  #   PASSWORD="pratik"
  #   useradd $USERNAME
  #   echo "$USERNAME:$PASSWORD" | chpasswd

  #   # Ensure the user can use sudo without a password
  #   echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

  #   # Reload sshd again after sudo and user changes
  #   systemctl restart sshd
  # EOF

  tags = merge({Name= var.name},var.tags)
}

output "private_key_path" {
  value = local_file.private_key.filename
}
