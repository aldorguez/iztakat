#!/usr/bin/env bash
# v0.1
# Copyright 2021-2022 Aldo Rodríguez.
# This software is licensed under the GNU Affero General Public License version 3
# 
# This script is ment to setup a basic MAAS server on a fresh Ubuntu Server 20.04.4
# installation. 

##============================[ MAAS Setup Parameters ]================================##

MAAS_VERSION=3.1/stable
MAAS_DBUSER=maascli
MAAS_DBPASS=maascli

MAAS_DBNAME=maasclidb
MAAS_MODE=region+rack

MAAS_USER=admin
MAAS_PASS=Password
MAAS_EMAIL=aldo.cnyn@gmail.com

MAAS_SSH_KEY=lp:aldostein
###  Launchpad (lp:user-id) or Github (gh:user-id)
DNS=8.8.8.8

##==================================[ Parameters ]=====================================##

ECHO="echo -e"
READ="read -n 1 -s -r -p"
DEBUG=false

##====================================[ Start ]=======================================##

# sudo apt update && sudo apt upgrade -y && sudo autoremove -y

sudo snap install --channel=$MAAS_VERSION maas
sudo snap install jq

MAAS_INTERFACE=$(ip -j -4 route show default | jq -r '.[].dev')

MAAS_IPADDRESS=$(ip -j -4 addr show dev $MAAS_INTERFACE | jq -r '.[].addr_info[].local')
MAAS_PORT=5240
MAAS_URL=http://$MAAS_IPADDRESS:$MAAS_PORT/MAAS

sudo apt install -y postgresql

PSQL_VERSION=$(psql --version | awk '{ split($3,x,"."); print $3 }' | cut -d. -f1)

if $DEBUG ; then
  $ECHO
  $ECHO sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
  $READ "Press anykey to execute the above command..."
fi
sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"

if $DEBUG ; then
  $ECHO
  $ECHO sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
  $READ "Press anykey to execute the above command..."
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
  $READ "Press anykey to execute the above command..."
fi
sudo maas init $MAAS_MODE --maas-url $MAAS_URL \
    --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@localhost/$MAAS_DBNAME"
sleep 15

if $DEBUG ; then
  $ECHO
  $ECHO sudo maas createadmin --username $MAAS_USER --password $MAAS_PASS \
      --email $MAAS_EMAIL --ssh-import $MAAS_SSH_KEY
  $READ "Press anykey to execute the above command..."
fi
sudo maas createadmin --username $MAAS_USER --password $MAAS_PASS \
    --email $MAAS_EMAIL --ssh-import $MAAS_SSH_KEY


MAAS_API_KEY=$(sudo maas apikey --username=$MAAS_USER | head -1)

if [ -z $MAAS_API_KEY ]
then
    $ECHO "MAAS_API_KEY is empty!"
    exit 0
fi

###  API key (leave empty for anonymous access):
#$ECHO maas login $MAAS_USER $MAAS_URL/api/2.0/ $MAAS_API_KEY
#maas login $MAAS_USER $MAAS_URL/api/2.0/ $MAAS_API_KEY
if $DEBUG ; then
  $ECHO
  $ECHO maas login $MAAS_USER $MAAS_URL $MAAS_API_KEY
  $READ "Press anykey to execute the above command..."
fi
maas login $MAAS_USER $MAAS_URL $MAAS_API_KEY

if $DEBUG ; then
  $ECHO
  $ECHO "maas admin maas set-config name=upstream_dns value=$DNS"
  $READ "Press anykey to execute the above command..."
fi
maas admin maas set-config name=upstream_dns value=$DNS


# maas admin ipranges create type=dynamic start_ip=10.0.0.10 end_ip=10.0.0.250
MAAS_SUBNET24="$(hostname -I | cut -d" " -f2 | cut -d. -f1,2,3)"
if $DEBUG ; then
  $ECHO
  $ECHO maas admin ipranges create type=dynamic start_ip=$MAAS_SUBNET24.10 end_ip=$MAAS_SUBNET24.250
  $READ "Press anykey to execute the above command..."
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
  $READ "Press anykey to execute the above command..."
fi
maas admin vlan update $MAAS_VLAN untagged dhcp_on=True primary_rack=$MAAS_CTRL
