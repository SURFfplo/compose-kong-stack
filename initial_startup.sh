#!/bin/bash

#############################################################################
# COLOURS AND MARKUP
#############################################################################

red='\033[0;31m'            # Red
green='\033[0;49;92m'       # Green
yellow='\033[0;49;93m'      # Yellow
white='\033[1;37m'          # White
grey='\033[1;49;30m'        # Grey
nc='\033[0m'                # No color

clear

echo -e "${yellow}
# Test if machine is running in swarm if not start it 
#############################################################################${nc}"
if docker node ls > /dev/null 2>&1; then
  echo already running in swarm mode 
else
  docker swarm init 
  echo docker was a standalone node now running in swarm 
fi
echo -e "${green}Done....${nc}"



echo -e "${yellow}
# Test if network is running in overlay if not start it
#############################################################################${nc}"
docker network ls|grep appnet > /dev/null || docker network create --driver overlay appnet
sleep 5
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Create secrets for db use 
#############################################################################${nc}"
echo -e "${green}Choose new database dba password: ${nc}"
read dbdbapwd
printf $dbdbapwd | docker secret create kong_db_dba_password -
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Check if kong containter is available and build if needed
#############################################################################${nc}"
DIRECTORY='image-kong'
#if [ ! -d ../"$DIRECTORY" ]; then
#  echo " https://github.com/SURFfplo/"$DIRECTORY".git ../"$DIRECTORY" "
#  git clone https://github.com/SURFfplo/"$DIRECTORY".git ../"$DIRECTORY"
#fi
#docker build ../"$DIRECTORY" -t kong-oidc
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Build kong-db container 
#############################################################################${nc}"
#docker-compose build kong-db
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Build konga container 
#############################################################################${nc}"
DIRECTORY='image-konga'
if [ ! -d ../"$DIRECTORY" ]; then
  echo " https://github.com/SURFfplo/"$DIRECTORY".git ../"$DIRECTORY" "
  git clone https://github.com/SURFfplo/"$DIRECTORY".git ../"$DIRECTORY"
fi
#docker build ../"$DIRECTORY" -t konga
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Create folder structure for psql container
#############################################################################${nc}"
mkdir .data
mkdir .data/kong
mkdir .data/kong/psql 
echo -e "${green}Done....${nc}"

echo -e "${yellow}
# Create the service
#############################################################################${nc}"
docker stack deploy -c docker-compose.yml aai

echo -e "${yellow}
# remove services that will need separate initializing
#############################################################################${nc}"
docker service rm aai_kong-oidc 
docker service rm aai_konga 
echo -e "${green}Done....${nc}"

echo "woit for 30 seconds for kong-db container to fully come up" 
sleep 30

echo -e "${yellow}
# Initialize kong container
#############################################################################${nc}"
containerid="$(docker container ps -q -f 'name=kong')"
echo $containerid
# todo stuff
docker service create --restart-condition=none --detach=true --secret kong_db_dba_password --name kong-temp1 --env KONG_DATABASE=postgres --env KONG_PG_HOST=kong-db --env KONG_PG_PORT=5432 --env KONG_PG_DATABASE=api-gw --env KONG_PG_DB_PASSWORD_FILE=/run/secrets/kong_db_dba_password --network appnet kong-oidc kong migrations bootstrap
echo -e "${green}Done....${nc}"
sleep 10

echo -e "${yellow}
# Initialize konga container
#############################################################################${nc}"
containerid="$(docker container ps -q -f 'name=kong')"
echo $containerid
# todo stuff
docker service create --restart-condition=none --detach=true --secret kong_db_dba_password --name kong-temp2 --env DB_USER=kong --env DB_ADAPTER=postgres --env DB_HOST=kong-db --env DB_PORT=5432 --env DB_DATABASE=konga_database --env DB_PASSWORD_FILE=/run/secrets/kong_db_dba_password --env NODE_ENV=prep --network appnet konga -c prepare_docker_env -a postgres
echo -e "${green}Done....${nc}"
sleep 10

echo -e "${yellow}
# Clean-up stopped containers and initialisation service 
#############################################################################${nc}"
#remove temp service after initial boot
#docker service rm docker-temp1 
#docker service rm docker-temp2 
#docker rm $(docker ps -f "status=exited" -q)
echo -e "${green}Done....${nc}"

echo -e "${yellow}
# Recreate the service
#############################################################################${nc}"
docker stack deploy -c docker-compose.yml aai
echo -e "${green}Done....${nc}"


