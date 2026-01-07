FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server sudo python3 && \
    mkdir /var/run/sshd

RUN useradd -m ansible && \
    echo "ansible:ansible" | chpasswd && \
    usermod -aG sudo ansible

RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
