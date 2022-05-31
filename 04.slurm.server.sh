#!/usr/bin/env bash

sudo apt-get install -y munge slurmdbd slurmctld slurm-wlm-basic-plugins sview 

sudo mkdir -p /share/conf/munge
sudo mkdir /share/conf/slurm

sudo cp /etc/munge/munge.key /share/conf/munge

sudo cp slurm/slurm.conf /etc/slurm-llnl
sudo cp slurm/cgroup.conf /etc/slurm-llnl
sudo chown --recursive root:root /etc/slurm-llnl
sudo chmod 644 /etc/slurm-llnl/*.conf
sudo mkdir /var/spool/slurmctld
sudo chown --recursive slurm:slurm /var/spool/slurmctld

sudo systemctl restart slurmctld.service

sudo cp -p /etc/slurm-llnl/*.conf /share/conf/slurm

sudo chown --recursive root:root /share/conf
sudo chmod --recursive 400 /share/conf
