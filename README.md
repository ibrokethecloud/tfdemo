# TF DEMO
Sample repo to spin up an environment using RANCHER and EC2 (pseudo PAAS)

Please use the makefile available to spin up the infra and deploy the app. I have added 2 demo applications, a web app and lb to route to it.

The stack also creates a ELB and attaches the EC2 instances to it.

The makefile supports the following targets:

### setupenv ###
Will download and unzip the terraform and rancher-compose binaries on your OSX or Linux machines.
Windows is not yet supported.

### setupinfra ###
Will create the Rancher environment, Create EC2 instances and an ELB.
It will register the EC2 instances with the Rancher environment.
The instances are also attached to the ELB.

### destroyinfra ###
Will destroy the EC2 instances, ELB and Rancher environment

### deployweb ###
Will deploy the sample web application. The service is scheduled globally so will scale out as and when the hosts are added / removed to the environment.
As we use the label selector based route discover, the rancher lb will detect the changes and adjust routing accordingly.
This target needs an environment variable VERSION to identify what version of dummy web-app to deploy. Currently only 2 image builds are available. VERSION=1 and VERSION=2.

### deploylb ###
Deploys a software lb to route to the web app container deployed by the **deployweb** target.

The lb and app can be deployed in any order.

### checkvariables ###
This target checks that certain variables referred in the TF build are set.
Following are the mandatory variables:

  AWS_ACCESS_KEY_ID - AWS ACCESS KEY for your AWS ROOT/IAM Account.  
  AWS_SECRET_ACCESS_KEY - AWS SECRET KEY for your AWS ROOT/IAM Account.  
  RANCHER_URL - RANCHER server url where the new environment needs to be created and hosts will register to.  
  RANCHER_ACCESS_KEY - Account API access key  
  RANCHER_SECRET_KEY - Account API secret key  
  ENV - Environment definition file available under infrastructure/env  

**The ENV file needs the following mandatory variables:**
count - Number of instances to be created.
ami_image - Ami to be used for creating the EC2 instances.
instance_type - Instance size
env_desc - Small description for environment for usage within Rancher

To scale up / down and environment please change the count variable in ENV definition file and run the **setupinfra** target

At the end of the **setupinfra** target the build will output the aws ec2 elb dns record for use later to test the application.
