#!/usr/bin/env bash
# v0.1
# Copyright 2021-2022 Aldo Rodríguez.
# This software is licensed under the GNU Affero General Public License version 3
# 
# This script is ment to setup a basic MAAS server on a fresh Ubuntu Server 22.04
# installation. 

# Define the setup parameters:
LAUNCHPAD_ID=aldostein
GITUB_ID=aldorguez

MAAS_VERSION=3.1/stable
MAAS_DBUSER=maascli
MAAS_DBPASS=maascli

MAAS_DBNAME=maasclidb
MAAS_MODE=region+rack

MAAS_USER=admin
MAAS_PASS=Password
MAAS_EMAIL=aldo.cnyn@gmail.com

MAAS_IPADDRESS=$(hostname -I | head -1 | awk '{print $1}')
MAAS_PORT=5240
MAAS_URL=http://$MAAS_IPADDRESS:$MAAS_PORT/MAAS

MAAS_SSH_KEY=lp:$LAUNCHPAD_ID
###  Launchpad (lp:user-id) or Github (gh:user-id)

MAAS_IPV4_IF=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
DNS=8.8.8.8

ECHO="echo -e "
DEBUG=true

##====================================[ Start ]=======================================##

# sudo apt update && sudo apt upgrade -y && sudo autoremove -y

sudo snap install --channel=$MAAS_VERSION maas
sudo snap install jq

sudo apt install -y postgresql

PSQL_VERSION=$(psql --version | awk '{ split($3,x,"."); print $3 }' | cut -d. -f1)

if $DEBUG ; then
  $ECHO
  $ECHO sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
  $ECHO "Press anykey to execute the above command..."
  read
fi
sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"

if $DEBUG ; then
  $ECHO
  $ECHO sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
  $ECHO "Press anykey to execute the above command..."
  read
fi
sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"

$ECHO "\nhost    $MAAS_DBNAME       $MAAS_DBUSER         0/0                     md5\n" | \
    sudo tee -a /etc/postgresql/$PSQL_VERSION/main/pg_hba.conf

HOSTNAME=$(hostname)
if $DEBUG ; then $ECHO "HOSTNAME=$HOSTNAME\n"; fi

if $DEBUG ; then
  $ECHO
  $ECHO sudo maas init $MAAS_MODE --maas-url $MAAS_URL \
      --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@localhost/$MAAS_DBNAME"
  $ECHO "Press anykey to execute the above command..."
  read
fi
sudo maas init $MAAS_MODE --maas-url $MAAS_URL \
    --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@localhost/$MAAS_DBNAME"

if $DEBUG ; then
  $ECHO
  $ECHO sudo maas createadmin --username $MAAS_USER --password $MAAS_PASS \
      --email $MAAS_EMAIL --ssh-import $MAAS_SSH_KEY
  $ECHO "Press anykey to execute the above command..."
  read
fi
sudo maas createadmin --username $MAAS_USER --password $MAAS_PASS \
    --email $MAAS_EMAIL --ssh-import $MAAS_SSH_KEY


MAAS_API_KEY=$(sudo maas apikey --username=$MAAS_USER | head -1)

if $DEBUG ; then $ECHO "\nMAAS_API_KEY=$MAAS_API_KEY\n"; fi
if [ -z $MAAS_API_KEY ]
then
    $ECHO "MAAS_API_KEY is empty!"
    exit 0
fi


#############################################################################

###  API key (leave empty for anonymous access):
#$ECHO maas login $MAAS_USER $MAAS_URL/api/2.0/ $MAAS_API_KEY
#maas login $MAAS_USER $MAAS_URL/api/2.0/ $MAAS_API_KEY
if $DEBUG ; then
  $ECHO
  $ECHO maas login $MAAS_USER $MAAS_URL $MAAS_API_KEY
  $ECHO "Press anykey to execute the above command..."
  read
fi
maas login $MAAS_USER $MAAS_URL $MAAS_API_KEY
# sleep 15

source /etc/os-release

ARCH=amd64

if $DEBUG ; then
  $ECHO
  $ECHO maas admin boot-source-selections create 1 \
      os="$ID" release="$VERSION_CODENAME" arches="$ARCH" subarches="*" labels="*"
  $ECHO "Press anykey to execute the above command..."
  read
fi
maas admin boot-source-selections create 1 \
    os="$ID" release="$VERSION_CODENAME" arches="$ARCH" subarches="*" labels="*"

if $DEBUG ; then
  $ECHO
  $ECHO "maas admin boot-resources import"
  $ECHO "Press anykey to execute the above command..."
  read
fi
maas admin boot-resources import


if $DEBUG ; then
  $ECHO
  $ECHO "maas admin maas set-config name=upstream_dns value=$DNS"
  $ECHO "Press anykey to execute the above command..."
  read
fi
maas admin maas set-config name=upstream_dns value=$DNS


# maas admin ipranges create type=dynamic start_ip=10.0.0.10 end_ip=10.0.0.250
MAAS_SUBNET24="$(hostname -I | cut -d" " -f2 | cut -d. -f1,2,3)"
if $DEBUG ; then
  $ECHO
  $ECHO maas admin ipranges create type=dynamic start_ip=$MAAS_SUBNET24.10 end_ip=$MAAS_SUBNET24.250
  $ECHO "Press anykey to execute the above command..."
  read
fi
maas admin ipranges create type=dynamic start_ip=$MAAS_SUBNET24.10 end_ip=$MAAS_SUBNET24.250

# maas admin vlan update 1 untagged dhcp_on=True primary_rack=master
MAAS_SUBNET="$MAAS_SUBNET24".0/24
MAAS_VLAN=$(maas admin subnet read $MAAS_SUBNET | grep fabric_id | \
    cut -d ':' -f 2 | cut -d ',' -f 1)
MAAS_CTRL=$(maas admin rack-controllers read | grep hostname | cut -d '"' -f 4)
if $DEBUG ; then
  $ECHO
  $ECHO "maas admin vlan update $MAAS_VLAN untagged dhcp_on=True primary_rack=$MAAS_CTRL"
  $ECHO "Press anykey to execute the above command..."
  read
fi
maas admin vlan update $MAAS_VLAN untagged dhcp_on=True primary_rack=$MAAS_CTRL
