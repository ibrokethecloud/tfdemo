provider "aws" {
  region = "ap-southeast-2"

}

variable "RANCHER_URL" {}
variable "RANCHER_ACCESS_KEY" {}
variable "RANCHER_SECRET_KEY" {}
variable "count" {}
variable "instance_type" {}
variable "ami_image" {}
variable "env" {}
variable "env_desc" {}

provider "rancher" {
  api_url = "${var.RANCHER_URL}" //
  access_key = "${var.RANCHER_ACCESS_KEY}" //
  secret_key = "${var.RANCHER_SECRET_KEY}"
}

resource "rancher_environment" "demo" {
  name = "${var.env}"
  description = "${var.env_desc}"
  orchestration = "cattle"
}

resource "rancher_registration_token" "demo-token" {
  environment_id = "${rancher_environment.demo.id}"
  name = "demo-token"
  description = "Host registration token for Demo environment"
}

resource "aws_instance" "demo" {
  count         = "${var.count}"
  ami           = "${var.ami_image}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "Demo"
  }
  user_data = <<CLOUDCONFIG
  #cloud-config
hostname: demo-${count.index + 1}
locale: en_AU.UTF-8
write_files:
  - path: /opt/rancher/rancher.sh
    permissions: "0755"
    owner: root
    content: |
        #!/bin/bash
        # Wait for Docker and t'internet
        while [ -e $${OK} ]; do
            ping google.com -c 4 && OK=true && break; sleep 3;
        done
        sudo yum install docker -y
        sudo service docker restart
        ${rancher_registration_token.demo-token.command} -e CATTLE_HOST_LABELS='demo=${count.index + 1}'
runcmd:
  - [ /opt/rancher/rancher.sh ]
CLOUDCONFIG

}

resource "aws_elb" "demo-elb" {
  name               = "demo-elb"
  availability_zones = ["ap-southeast-2a","ap-southeast-2b","ap-southeast-2c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  instances = ["${aws_instance.demo.*.id}"]

  tags {
    Name = "demo-elb"
  }
}

output "elb_dns_name" {
  value = "${aws_elb.demo-elb.dns_name}"
}
