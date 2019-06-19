# compose-kong-stack
Compose file that currently allows for the setup of an appnet network and a running kong oidc service. For easy installation run 
`
sh initial_run.sh
`
Running this file will help you through the installation and will provide you with a running docker image of KONG with the Nokia OIDC plugin also installed.

# standard Kong installation with Nokia OIDC plugin added to base install
This Install also has the Nokia OIDC plugin installed:
https://github.com/nokia/kong-oidc

Additional plugins to Kong can be found at: 
https://docs.konghq.com/hub/


# quick use of kong plugins/ let's check if it works
First test if the API servr is up and running 
```
curl -X GET http://localhost:8001/status
```

Create a test URL that is exposed on the standard 8000 port in this case let's expose a posts list API
```
curl -i -X POST http://localhost:8001/services/ \
  --data 'name=ooapi_posts' \
  --data 'url=https://jsonplaceholder.typicode.com/posts' 

curl -i -X POST \
  --url http://localhost:8001/services/ooapi_posts/routes/ \
  --data 'paths[]=/posts'
```
After running the code above we can now use our new endpoint: http://localhost:8000/post 

Important now we need to remember the serviceID that corrseponds with the route so we can setup openid-connect/authorize
```
curl -i -X POST \
  --url http://localhost:8001/services/<serviceID>/plugins/ \
    --data "name=oidc" \
    --data "config.client_id=<myckientID @ well-known>" \
    --data "config.client_secret=<wouldn't you like to know @ well-known>" \
    --data "config.discovery=https%3A%2F%2F<URL of well-known>%2F.well-known%2Fopenid-configuration"
```

# visualising tha admin-api in a web application
The professional version of Kong has it's own web application. In the open source version there is no web front end. 
An open source alternative can be found at: https://github.com/pantsel/konga

This Konga frontend now also comes with this stack

# for local testing
If you'd like to test this API manager and OIDC you need to be able to reach the machine de API is running on from the internet. A paid sollution to do this is ngrok an other sollution that works equally well is https://serveo.net

A sollution to have a test OIDC client can be found online auth0.com

Of course you can also try to run your own OIDC server. A great explanation cn be found at:
https://www.jerney.io/secure-apis-kong-keycloak-1/


