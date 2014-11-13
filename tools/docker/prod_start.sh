#!/bin/bash

set -e

ME=$(basename $0)

# Sanity checks
JQ=$(which jq)
if [ ! -x $JQ ]; then
    echo "*** ERROR: $ME requires jq. Something like"
    echo "  apt-get install jq"
    echo "  or "
    echo "  yum install jq"
    echo "Should help"
    exit 1
fi
JQ="$JQ --monochrome-output --raw-output"

if [ -z "$1" ]; then
    echo "*** ERROR: $ME requires a name"
    echo "Usage: $ME my_tuleap"
    echo "Will spawn a new server named my_tuleap"
    exit 1
fi
TULEAP_NAME=$1

CURRENT_USER=$(whoami)
HOSTNAME=$(hostname)
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

# Find where the sources are
CURRENT_DIR=$(cd $(dirname $0); pwd)
if [ ! -x "$CURRENT_DIR/$ME" ]; then
    echo "*** ERROR: unable to find myself in this rough world :'("
    exit 1
fi
SRC_DIR=$(cd $CURRENT_DIR/../..; pwd)

VHOST=$TULEAP_NAME

#docker run -d \
#    --name $TULEAP_NAME \
#    -v /srv/docker/$TULEAP_NAME:/data \
#    -v $SRC_DIR:/usr/share/tuleap \
#    -e VIRTUAL_HOST=$VHOST \
#    -e UID=$(id -u $CURRENT_USER) \
#    -e GID=$(id -g $CURRENT_USER) \
#    -e SSH_KEY="$SSH_KEY" \
#    -p 443:443 -p 80:80 -p 2022:22 \
#    enalean/tuleap-aio

docker run -d \
    --name $TULEAP_NAME \
    -v /srv/docker/$TULEAP_NAME:/data \
    -e VIRTUAL_HOST=$VHOST \
    -p 443:443 -p 80:80 -p 2022:22 \
    cbayle/docker-tuleap-aio
#    enalean/tuleap-aio

IP_ADDRESS=$(docker inspect $TULEAP_NAME |  $JQ '.[].NetworkSettings.IPAddress')

cat <<EOF
Your container will be up in a couple of seconds at $IP_ADDRESS
Check the status with
$> docker logs $TULEAP_NAME
(If you see a couple of INFO success that's a good sign)

You can add the following lines to /etc/hosts:
$IP_ADDRESS     $VHOST

Your ssh key was deployed so you can also run
$> ssh root@$IP_ADDRESS
EOF
sudo cat /srv/docker/$TULEAP_NAME/root/.tuleap_passwd
