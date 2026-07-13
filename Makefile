LOCATION ?= chilecentral
PREFIX ?= unir-caso2
TF_DIR ?= infra
ANSIBLE_DIR := ansible
INVENTORY := inventory.ini
TAG=casopractico2
SSH_KEY_DIR = ~/.ssh
SSH_KEY_NAME = id_rsa
SSH_PUB_KEY = $(SSH_KEY_DIR)/$(SSH_KEY_NAME).pub
SSH_PRIV_KEY = $(SSH_KEY_DIR)/$(SSH_KEY_NAME)


.PHONY: infra_init infra_fmt infra_validate infra_apply infra_destroy ansible_inventory build_push_image deploy_ansible deploy_caso2 destroy_caso2 check_ssh_keys

check_ssh_keys:
	@echo "Verificando llaves SSH para acceso a la VM..."
	@if [ ! -f $(SSH_PRIV_KEY) ]; then \
		echo "Llave SSH no encontrada. Por favor, genera una nueva."; \
		exit 1; \
	else \
		echo "Llave SSH detectada: $(SSH_PRIV_KEY)"; \
	fi

infra_init:
	@echo "Initializing Terraform..."
	cd infra/$* &&\
	terraform  init -input=false
infra_fmt:
	@echo "Formatting Terraform files..."
	cd infra/$* &&\
	terraform fmt -recursive
infra_validate:
	@echo "Validating Terraform files..."
	cd infra/$* &&\
	terraform validate
infra_apply: check_ssh_keys
	@echo "Applying Terraform files..."
	cd infra/$* &&\
	terraform apply -auto-approve

infra_destroy:
	@echo "Destroying Terraform files..."
	cd infra/$* &&\
	terraform destroy -auto-approve

ansible_inventory:
	@echo "Generating Ansible inventory..."
	@mkdir -p $(ANSIBLE_DIR)
	@echo "[webserver]" > $(ANSIBLE_DIR)/$(INVENTORY)
	@echo "$$(cd $(TF_DIR) && terraform output -raw vm_public_ip)" \
	ansible_user="adminuser"  >> $(ANSIBLE_DIR)/$(INVENTORY) \ 

#------------------------------------------
#build and push docker image to ACR
#------------------------------------------
ansible_build_push_image:
	@echo "Building and pushing Docker image to ACR..."
	cd $(ANSIBLE_DIR) &&\
	ansible-playbook -i inventory playbook-built.yaml	
	
#------------------------------------------
#deploy with ansible
#------------------------------------------
ansible_deploy:
	@echo "Deploying with Ansible..."
	cd $(ANSIBLE_DIR) &&\
	ansible-playbook  playbook_deploy.yaml -i inventory.ini


deploy_caso2:
	@echo "Deploying Caso 2..."
	$(MAKE) infra_init
	$(MAKE) infra_fmt
	$(MAKE) infra_validate
	$(MAKE) check_ssh_keys
	$(MAKE) infra_apply
	$(MAKE) ansible_inventory
	$(MAKE) ansible_build_push_image
	$(MAKE) ansible_deploy



destroy_caso2:
	@echo "Destroying infra Caso 2..."
	$(MAKE) infra_destroy