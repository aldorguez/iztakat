#!/usr/bin/env bash

# Update
#sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y

# NFS
sudo apt-get install -y nfs-common
#  /share
sudo mkdir /share
sudo bash -c "echo -e '\n10.0.0.254:/share      /share   nfs   auto,nofail,noatime,nolock,intr,tcp,actimeo=1800    0     0\n' >> /etc/fstab"
#  /home
sudo bash -c "echo -e '\n10.0.0.254:/home       /home    nfs   auto,nofail,noatime,nolock,intr,tcp,actimeo=1800    0     0\n' >> /etc/fstab"
sudo mount -a

# Modules
sudo ln -s /share/utils/modules/5.0.1/init/profile.sh /etc/profile.d/modules.sh

# Infiniband
sudo apt-get install -y rdma-core

# SLURM
sudo apt-get install -y slurm-client slurmd
sudo cp -p /share/conf/slurm/{slurm.conf,cgroup.conf} /etc/slurm-llnl
sudo chmod 644 /etc/slurm-llnl/{slurm.conf,cgroup.conf}

#  Munge
sudo cp -p /share/conf/munge/munge.key  /etc/munge
sudo chmod --recursive 700 /etc/munge
sudo chmod 400 /etc/munge/munge.key
sudo chown --recursive munge:munge /etc/munge
