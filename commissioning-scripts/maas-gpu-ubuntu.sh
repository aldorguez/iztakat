#!/usr/bin/env bash

# sudo vi /etc/ssh/sshd_config

# Update
#sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# NFS
sudo apt install -y nfs-common
#  /share
sudo mkdir /share
sudo bash -c "echo -e '\n10.0.0.254:/share      /share   nfs   auto,nofail,noatime,nolock,intr,tcp,actimeo=1800    0     0\n' >> /etc/fstab"
#  /home
sudo bash -c "echo -e '\n10.0.0.254:/home       /home    nfs   auto,nofail,noatime,nolock,intr,tcp,actimeo=1800    0     0\n' >> /etc/fstab"
sudo mount -a

# NVIDIA GPU
if [ $(lspci | grep NVIDIA) ];
do
    sudo rmmod nouveau 
    sudo apt install build-essential libglvnd-dev pkg-config -y
    sudo apt remove --purge  '^nvidia-.*' -y
    sudo apt remove --purge libdrm-nouveau2 -y
    sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo sh /share/utils/cuda/NVIDIA-Linux-x86_64-510.47.03.run --accept-license --silent --disable-nouveau 
    sudo nvidia-smi 
    /share/apps/nvidia/hpc_sdk/2022/222/Linux_x86_64/22.2/compilers/bin/nvaccelinfo -v
    sudo update-initramfs -u
done

# Modules
sudo ln -s /share/utils/modules/5.0.1/init/profile.sh /etc/profile.d/modules.sh

# Infiniband
sudo apt install -y rdma-core

# SLURM
sudo apt install -y slurm-client slurmd
sudo cp -p /share/conf/slurm/{slurm.conf,cgroup.conf} /etc/slurm-llnl

#  Munge
sudo cp -p /share/conf/munge/munge.key  /etc/munge
