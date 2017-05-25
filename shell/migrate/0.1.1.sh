#!/bin/bash

#When creating a new file it'll execute once automatically
#This file creates a swap partition at the VM
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
sudo echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
