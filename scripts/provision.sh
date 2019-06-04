#!/usr/bin/env bash

# make sure apt database is up-to date
apt-get update

# Add no-password sudo config for vagrant user
echo "%vagrant ALL=NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Add vagrant to sudo group
usermod -a -G sudo vagrant

# Install vagrant key
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Install NFS for Vagrant
apt-get install -y nfs-common
# Without libdbus virtualbox would not start automatically after compile
apt-get -y install --no-install-recommends libdbus-1-3

# Install Linux headers and compiler toolchain
apt-get -y install build-essential linux-headers-$(uname -r)

# install golang-1.10
apt-get install -y golang-1.10

# install git to be able to download source from github
apt-get install -y git

# Set up bash profile of vagrant user to include Go runtime and compiler
grep 'GOPATH|GOROOT' /home/vagrant/.bash_profile &>/dev/null || {
  mkdir -p /home/vagrant/go
  if [ -f "/home/vagrant/.bash_profile" ]; then
    cp /home/vagrant/.bash_profile /home/vagrant/.bash_profile.ori
    grep -v 'GOPATH|GOROOT' /home/vagrant/.bash_profile.ori | tee -a /home/vagrant/.bash_profile
  fi
  echo 'export GOROOT=/usr/lib/go-1.10' | tee -a /home/vagrant/.bash_profile
  echo 'export PATH=$PATH:$GOROOT/bin' | tee -a /home/vagrant/.bash_profile
  echo 'export GOPATH=/home/vagrant/go' | tee -a /home/vagrant/.bash_profile
  chown -R vagrant:  /home/vagrant
}


# Install unzip
which wget unzip &>/dev/null || {
  apt-get install -y wget unzip
}

# Install Terraform
which terraform &>/dev/null || {
  pushd /usr/local/bin
  wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
  unzip terraform_0.11.10_linux_amd64.zip
  rm terraform_0.11.10_linux_amd64.zip
  popd
}

# Refresh environment with the variables previously generated
source ~/.bash_profile

# Get custom plugin source
go get github.com/petems/terraform-provider-extip
cd ~/go/src/github.com/petems/terraform-provider-extip

# Build plugin source code
make build

# Install custom plugin into .terraform.d directory which will be picked up automatically for the user
mkdir -p /home/vagrant/.terraform.d/plugins/linux_amd64
cp ~/go/bin/terraform-provider-extip /home/vagrant/.terraform.d/plugins/linux_amd64/

# Populate Terraform workspace with main.tf
mkdir -p /home/vagrant/tf-workspace
cp /tmp/main.tf /home/vagrant/tf-workspace

# Copy test script into home directory
cp /tmp/test.sh /home/vagrant
chmod a+x /home/vagrant/test.sh

# Ensure all files and folders owned by vagrant user
chown -R vagrant:vagrant /home/vagrant

# Install the VirtualBox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO=/home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop $VBOX_ISO /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt

#Cleanup VirtualBox
rm $VBOX_ISO

apt-get autoremove -y
apt-get clean

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*
