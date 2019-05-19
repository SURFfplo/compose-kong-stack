#!/bin/bash

# create nfs mount
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/data
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/psql


# remove any old secrest and configs
#docker secret rm $(docker secret ls -f name=kong -q)

# create secrets for database
# e.g. date |md5sum|awk '{print $1}' | docker secret create my_secret -
# or cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_dba_password -
# or visible printf "pasword"  | docker secret create canvas_db_dba_password -
date |md5sum|awk '{print $1}' | docker secret create kong_db_dba_password -


#create two run once services for initialisation purposes
docker stack deploy --compose-file docker-compose.init.yml $STACK_SERVICE
sleep 200
docker stack deploy --compose-file docker-compose.init2.yml $STACK_SERVICE
sleep 200

docker rm $(docker ps -f "status=exited" -q)

#docker stack deploy -c docker-compose.yml $STACK_SERVICE


# alternative sollutions
# to do remover services taht we will not use for initial
# docker stack deploy --compose-file docker-compose.yml -c docker-compose.prod.yml $STACK_SERVICE
# docker service rm $STACK_SERVICE_konga 
#"woit for 30 seconds for kong-db container to fully come up" 

# Initialize kong container
#temp_service < docker service create --restart-condition=none --detach=true --secret kong_db_dba_password --name kong-temp1 --env KONG_DATABASE=postgres --env KONG_PG_HOST=kong-db --env KONG_PG_PORT=5432 --env KONG_PG_DATABASE=api-gw --env KONG_PG_DB_PASSWORD_FILE=/run/secrets/kong_db_dba_password --network appnet kong-oidc kong migrations bootstrap
# docker stack rm $temp_service 
