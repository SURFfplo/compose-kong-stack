#!/bin/bash

# defaults
SERVICE=DEVkong
VERSION=0.1
NETWORK=dev-net
PORT=57020

# input with four arguments: go.sh SERVICE VERSION NETWORK PORT
if [ "$1" != "" ]; then
        SERVICE=$1
fi
if [ "$2" != "" ]; then
        VERSION=$2
fi
if [ "$3" != "" ]; then
        NETWORK=$3
fi
if [ "$4" != "" ]; then
        PORT=$4
fi

# reuse input
export STACK_SERVICE=$SERVICE
export STACK_VERSION=$VERSION
export STACK_NETWORK=$NETWORK
export STACK_PORT=$PORT

if [ $NETWORK == "dev-net" ]; then
        export STACK_PORT_ADMIN=8001
        export STACK_PORT_ADMIN2=1337
fi
if [ $NETWORK == "test-net" ]; then
        export STACK_PORT_ADMIN=8002
        export STACK_PORT_ADMIN2=1338
fi
if [ $NETWORK == "exp-net" ]; then
        export STACK_PORT_ADMIN=8003
        export STACK_PORT_ADMIN2=1339
fi

# delete previous version
# note: geen rollback!
docker stack rm $STACK_SERVICE

# prepare
./prepare.sh

# go
docker stack deploy --with-registry-auth -c docker-compose.yml $STACK_SERVICE
