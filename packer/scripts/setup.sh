#!/bin/bash

## debug cmd 
# set -x

## User config
sudo groupadd -r newuser
## with password
# sudo useradd -m -s /bin/bash -p "encryptedpassw" "newuser"
## without password
sudo useradd -m -s /bin/bash newuser
sudo usermod -a -G admin newuser
# sudo cp /etc/sudoers /etc/sudoers.orig
# echo "terraform  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/terraform

## Installing SSH key
sudo mkdir -p /home/newuser/.ssh
sudo chmod 700 /home/newuser/.ssh
sudo chmod 600 /home/newuser/.ssh/authorized_keys
sudo chown -R newuser /home/newuser/.ssh
sudo usermod --shell /bin/bash newuser

## Configure ssh client
if [ -f /etc/ssh/sshd_config ]; then
    cp /etc/ssh/sshd_config /var/backups/default/sshd_config
fi

cat > /etc/ssh/sshd_config << EOF
Protocol 2
Port 22

LoginGraceTime 30s
AllowTcpForwarding no
PermitTunnel no
X11Forwarding no
PrintLastLog yes

KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
AuthorizedKeysFile      .ssh/authorized_keys

AuthenticationMethods publickey
PermitEmptyPasswords no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
PermitRootLogin no
PermitUserEnvironment no


EOF

# Configure ip address
if [ -f  /etc/network/interfaces ]; then
    cp  /etc/network/interfaces  /etc/network/interfaces.bak
fi

cat >  /etc/network/interfaces << EOF
auto eth0
iface eth0 inet static
address 192.168.1.2
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 8.8.8.8
EOF

## Install necessary dependencies
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get update
sudo apt-get -y -qq install curl wget apt-transport-https ca-certificates

## Clean
history -c
history -w