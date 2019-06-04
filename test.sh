#!/usr/bin/env bash

FLAG_FILE=/home/vagrant/tested.flag
WORKSPACE=/home/vagrant/tf-workspace

cleanup_tfworkspace() {
        # Clean up workspace
        rm -rf ${WORKSPACE}/.terraform
        rm -f ${WORKSPACE}/terraform.tfstate*
}

# Clean up flag file
rm -f ${FLAG_FILE}

# Clean up Terraform workspace
cleanup_tfworkspace

# Navigate to Terraform workspace directory
cd /home/vagrant/tf-workspace

# Perform Terraform actions
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve

# Create flag file when test completed
touch ${FLAG_FILE}

# Clean up Terraform workspace
cleanup_tfworkspace
