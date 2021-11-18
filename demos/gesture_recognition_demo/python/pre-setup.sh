#!/bin/bash

function msg() {
  echo "> $@"
}



function Install_docker() {
  msg "Uninstall docker old versions"
  sudo apt-get remove docker docker-engine docker.io containerd runc
  
  msg "Update the apt package index"
  sudo apt-get update

  msg "Install packages to allow apt to use a repository over HTTPS"
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \

  msg "Add Docker’s official GPG key"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  msg "set up the stable repository"
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  msg "Update the apt package index, and install the latest version of Docker Engine and containerd"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  msg "Docker installation complete"
}



function Configure_Docker_to_start_on_boot() {
  msg "Configure Docker to start on boot"
  sudo systemctl enable docker.service
}



function Manage_Docker_as_non-root_user() {
  msg "Create the docker group"
  sudo groupadd docker
  
  msg "Add the login user to the docker group"
  sudo usermod -aG docker $USER
  
  msg "Logout and login again or reboot to take effect"
}



function Uninstall_Docker() {
  msg "Uninstall the Docker Engine, CLI, and Containerd packages"
  sudo apt-get purge docker-ce docker-ce-cli containerd.io
  
  msg "Delete all images, containers, and volumes"
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
}



Install_docker
Configure_Docker_to_start_on_boot
Manage_Docker_as_non-root_user
#Uninstall_Docker

msg "Done"


