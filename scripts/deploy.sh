#!/bin/bsh
# deployment wrapper to create a temp key pair and deploy the stack #
echo "Checking if basic packages are present"
if [ ! -x "$(command -v jq)" ]
then
  echo "Please install jq on your host to allow this script to work"
  exit 1
fi

SERVICE=$1
#Create a temp key pair to deploy #
API_URL=$(curl -s -u ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} "${RANCHER_URL}/v1/projects" | jq -r --arg env "${ENV}" '.data[] | select (.name==$env) | .links.apiKeys')
read ENV_ACCESS_KEY ENV_SECRET_KEY ACTIONS_DEACTIVATE ACTIONS_REMOVE <<< $(curl -s -u ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} -X POST -d {name:"demo"} "${API_URL}" | jq -r '.| .publicValue +" "+.secretValue+" "+.actions.deactivate+" "+.actions.remove '); \
  export ENV_ACCESS_KEY ENV_SECRET_KEY ACTIONS_DEACTIVATE ACTIONS_REMOVE

## Now that all settings are available use RANCHER_COMPOSE to deploy stack ##
rancher-compose -p ${SERVICE} --url ${RANCHER_URL} --access-key ${ENV_ACCESS_KEY} --secret-key ${ENV_SECRET_KEY} -f ./deployment/${SERVICE}/docker-compose.yml -r ./deployment/${SERVICE}/rancher-compose.yml up --force-upgrade -c -p -d

## Remove temporary key pair now that deployment is complete ##
echo "removing temp keys"
curl -s -u  ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} -X POST ${ACTIONS_DEACTIVATE} -o /dev/null
curl -s -u  ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} -X POST ${ACTIONS_REMOVE} -o /dev/null
