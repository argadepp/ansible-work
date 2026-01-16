FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container docker

RUN apt-get update && \
    apt-get install -y \
    systemd \
    systemd-sysv \
    openssh-server \
    sudo \
    python3 \
    openjdk-17-jdk \
    curl \
    wget \
    tar && \
    mkdir /var/run/sshd

RUN useradd -m ansible && \
    echo "ansible:ansible" | chpasswd && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
