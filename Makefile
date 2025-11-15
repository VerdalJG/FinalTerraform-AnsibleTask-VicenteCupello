# Makefile

PROJECT_ROOT=/home/vagrant/TerraformAnsibleFinal
TERRAFORM_DIR=$(PROJECT_ROOT)/Terraform
ANSIBLE_DIR=$(PROJECT_ROOT)/Ansible

AWS_SHARED_CREDENTIALS_FILE=/home/vagrant/TerraformAnsibleFinal/Terraform/aws/credentials

export AWS_SHARED_CREDENTIALS_FILE

# Default target
all: deploy

# Deploy definition
deploy: terraform ansible

# Apply Terraform
terraform:
	@echo "Running terraform apply"; \
	cd $(TERRAFORM_DIR); \
	terraform init; \
	terraform apply -auto-approve

# Run ansible after waiting for EC2's to be ready
ansible:
	@echo "Waiting for EC2 instances..."; \
	cd $(ANSIBLE_DIR); \
	ansible all -m wait_for -a "host=0.0.0.0 port=22 timeout=300 state=started"; \
	echo "Running ansible playbook!"; \
	ansible-playbook site.yml


