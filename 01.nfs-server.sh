#!/usr/bin/env bash

sudo apt-get install -y nfs-common nfs-kernel-server

sudo mkdir /share
sudo mkdir /scratch

echo "
/share 10.0.0.254(ro,sync,no_root_squash,no_subtree_check) 10.0.0.0/24(ro,async,no_subtree_check)
/home  10.0.0.254(rw,async,no_root_squash) 10.0.0.0/24(rw,async,no_root_squash,no_subtree_check)
/scratch  10.0.0.254(rw,async,no_root_squash) 10.0.0.0/24(rw,async,no_root_squash,no_subtree_check)
" | \
    sudo tee -a /etc/exports

sudo systemctl restart nfs-server
