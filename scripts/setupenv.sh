#!/bin/sh
# Simple script to setup your local environment directory #

echo "Checking if basic packages are present"
if [ ! -x "$(command -v tar)" ]
then
  exit 1
fi
if [ ! -x "$(command -v unzip)" ]
then
  exit 1
fi

OS=$(uname)
STATE=0
TF_URL=""
RC_URL=""

case "${OS}" in
  "Darwin") echo "Detected OS as ${OS}. Downloading binaries"
    TF_URL="https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_darwin_amd64.zip"
    RC_URL="https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-darwin-amd64-v0.12.5.tar.gz"
  ;;
  "Linux")  echo "Detected OS as ${OS}. Downloading binaries"
    TF_URL="https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip"
    RC_URL="https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-linux-amd64-v0.12.5.tar.gz"
  ;;
  "*")  echo "OS not yet supported"
    exit 1
  ;;
esac

mkdir -p ./bin/
curl -kL ${TF_URL} -o ./bin/terraform.zip
STATE=$(( ${STATE} + $# ))
curl -kL ${RC_URL} -o ./bin/rancher-compose.tar.gz
STATE=$(( ${STATE} + $# ))
unzip ./bin/terraform.zip -d ./bin/
tar -xf ./bin/rancher-compose.tar.gz -C ./bin/ --strip=2
chmod -R +x ./bin/

exit ${STATE}
