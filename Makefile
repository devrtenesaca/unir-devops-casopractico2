LOCATION ?= chilecentral
PREFIX ?= unir-caso2
TF_DIR ?= infra
ANSIBLE_DIR := ansible
INVENTORY := inventory.ini
TAG=caso2

infra:
.PHONY: infra
	@echo "Creating infrastructure..."
	@terraform -chdir=infra init
	@terraform -chdir=infra apply -auto-approve -var="location=$(LOCATION)" -var="prefix=$(PREFIX)" -var="tag=$(TAG)"
init:
	@echo "Initializing Terraform..."
	cd infra/$* &&\
	terraform  init -input=false
fmt:
	@echo "Formatting Terraform files..."
	cd infra/$* &&\
	terraform fmt -recursive
validate:
	@echo "Validating Terraform files..."
	cd infra/$* &&\
	terraform validate
apply:
	@echo "Applying Terraform files..."
	cd infra/$* &&\
	terraform apply -auto-approve

destroy:
	@echo "Destroying Terraform files..."
	cd infra/$* &&\
	terraform destroy -auto-approve

ansible_inventory:
	@echo "Generating Ansible inventory..."
	@mkdir -p $(ANSIBLE_DIR)
	@echo "[webserver]" > $(ANSIBLE_DIR)/$(INVENTORY)
	@echo "$$(cd $(TF_DIR) && terraform output -raw vm_public_ip)" \
	ansible_user="opensip" ansible_password="P@ssw0rd1234!" >> $(ANSIBLE_DIR)/$(INVENTORY) \ 
	
	
deploy_caso2:
	@echo "Deploying Caso 2..."
	$(MAKE) init
	$(MAKE) fmt
	$(MAKE) validate
	$(MAKE) apply

#------------------------------------------
#build and push docker image to ACR
#------------------------------------------
build_push_image:
	@echo "Building and pushing Docker image to ACR..."
	@ansible-playbook -i inventory playbook-built.yaml

destroy_caso2:
	@echo "Destroying infra Caso 2..."
	$(MAKE) destroy