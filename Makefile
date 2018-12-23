modules = $(shell ls -1 *.tf | xargs -I % dirname % |sort -u)

TERRAFORM_VERSION = "0.9.9"
TERRAFORM_IMAGE = hashicorp/terraform
TERRAFORM_CMD = docker run --rm -w /app -v ${HOME}/.aws:/root/.aws -v `pwd`:/app ${TERRAFORM_IMAGE}:${TERRAFORM_VERSION}

.PHONY: test get

default: test get

get:
	@${TERRAFORM_CMD} get

test:
	@for m in $(modules); do (${TERRAFORM_CMD} validate "$$m" && echo "√ $$m") || exit 1 ; done
	@(${TERRAFORM_CMD} validate . && echo "√ .") || exit 1

plan:	test get
	@${TERRAFORM_CMD} plan -var-file="terraform.auto.tfvars" 

show:
	@${TERRAFORM_CMD} show -var-file="terraform.auto.tfvars" 

apply:  plan
	@${TERRAFORM_CMD} apply 

destroy: 
	@${TERRAFORM_CMD} destroy -force -var-file="terraform.auto.tfvars" 
