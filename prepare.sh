#!/bin/bash

# clean mounts
rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp/*

# create nfs mount
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/data
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/psql
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp

#
cp -a ./wait-for-it.sh /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp


########
#SECRETS
########
# remove any old secrest and configs
docker secret rm $(docker secret ls -f name=kong -q)

# create secrets for database
# e.g. date |md5sum|awk '{print $1}' | docker secret create my_secret -
# or cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_dba_password -
# or visible printf "pasword"  | docker secret create canvas_db_dba_password -
date |md5sum|awk '{print $1}' | docker secret create kong_db_dba_password -


#############################
#prepare db's with containers
#############################
#create two run once services for initialisation purposes

# prepare kong db
docker stack deploy --with-registry-auth --compose-file docker-compose.init.yml $STACK_SERVICE
sleep 30

# prepare konga db
docker stack deploy --with-registry-auth --compose-file docker-compose.init2.yml $STACK_SERVICE
sleep 30

#docker rm $(docker ps -f "status=exited" -q)
