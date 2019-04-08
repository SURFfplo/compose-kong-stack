# compose-aai-stack
Compose file that currently allows for the setup of an appnet network and a running kong oidc service

# Standard Kong installation with Nokia OIDC plugin added to base install
This Install also has the Nokia OIDC plugin installed:
https://github.com/nokia/kong-oidc

Additional plugins to Kong can be found at: 
https://docs.konghq.com/hub/


# Quick use of kong plugins:
# lets check if it works
curl -X GET http://localhost:8001/status

#test url 
curl -i -X POST http://localhost:8001/services/ \
  --data 'name=ooapi_posts' \
  --data 'url=https://jsonplaceholder.typicode.com/posts' 

curl -i -X POST \
  --url http://localhost:8001/services/ooapi_posts/routes/ \
  --data 'paths[]=/posts'\

Important now we need to remember the serviceID that corrseponds with the route

# setup openid-connect/authorize
curl -i -X POST \
  --url http://localhost:8001/services/<serviceID>/plugins/ \
    --data "name=oidc" \
    --data "config.client_id=<myckientID @ well-known>" \
    --data "config.client_secret=<wouldn't you lie to know @ well-known>" \
    --data "config.discovery=https%3A%2F%2F<URL of well-known>%2F.well-known%2Fopenid-configuration"

# for local testing
If you'd like to test this API manager and OIDC you need to be able to reach the machine de API is running on from the internet. A paid sollution to do this is ngrok an other sollution that works equally well is https://serveo.net

A sollution to have a test OIDC client can be found online auth0.com

Of course you can also try to run your own OIDC server. A great explanation cn be found at:
https://www.jerney.io/secure-apis-kong-keycloak-1/
