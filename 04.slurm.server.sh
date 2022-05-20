#!/usr/bin/env bash

sudo apt install -y munge slurmdbd slurmctld slurm-wlm-basic-plugins sview 

sudo mkdir -p /share/conf/{munge,slurm}

sudo cp -p /etc/munge/munge.key /share/conf/munge

cd slurm
sudo cp slurm.conf cgroup.conf /etc/slurm-llnl
sudo chown --recursive root:root /etc/slurm-llnl
sudo chmod --recursive 644 /etc/slurm-llnl

sudo cp -p /etc/slurm-llnl/{slurm.conf,cgroup.conf} /share/conf/slurm

