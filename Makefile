#Magic makefile to download build tools and setup an environment #

# Setting up path variable #
SHELL := /bin/bash
export PATH := $(shell pwd)/bin:$(PATH)

## Check if mandatory variables are setup for subsequent target usage ##
## Variables checked are: RANCHER_URL,RANCHER_ACCESS_KEY,RANCHER_SECRET_KEY ##
## AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, ENV ##

checkvariables:
ifndef AWS_ACCESS_KEY_ID
	$(error AWS_ACCESS_KEY_ID is not defined)
endif
ifndef AWS_SECRET_ACCESS_KEY
	$(error AWS_SECRET_ACCESS_KEY is not defined)
endif
ifndef RANCHER_URL
	$(error RANCHER_URL is not defined)
endif
ifndef RANCHER_ACCESS_KEY
	$(error RANCHER_ACCESS_KEY is not defined)
endif
ifndef RANCHER_SECRET_KEY
	$(error RANCHER_SECRET_KEY is not defined)
endif
ifndef ENV
	$(error ENV is not defined)
endif


clean:
	@echo "removing old binaries"
	@rm -rf bin/*

setupenv:
	@echo "Downloading Terraform and rancher compose for your machine"
	@echo "Support only available for Linux and OSX at the moment"
	@sh scripts/setupenv.sh

setupinfra:	checkvariables
	@cd infrastructure && terraform apply -var-file="env/${ENV}.tfvars" -var RANCHER_URL=${RANCHER_URL} -var RANCHER_ACCESS_KEY=${RANCHER_ACCESS_KEY} -var RANCHER_SECRET_KEY=${RANCHER_SECRET_KEY} -var env=${ENV}

destroyinfra:	checkvariables
	@cd infrastructure && terraform destroy -var-file="env/${ENV}.tfvars" -var RANCHER_URL=${RANCHER_URL} -var RANCHER_ACCESS_KEY=${RANCHER_ACCESS_KEY} -var RANCHER_SECRET_KEY=${RANCHER_SECRET_KEY} -var env=${ENV}

deployweb:
ifndef VERSION
	$(error VERSION is not defined)
endif
	@sh scripts/deploy.sh web

deploylb:
	@sh scripts/deploy.sh lb

help:
	@echo "Available targets are clean setupenv setupinfra destroyinfra deployweb deploylb"
	@echo "The following env variables must be available in your session: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, RANCHER_URL, RANCHER_ACCESS_KEY, RANCHER_SECRET_KEY, ENV"
