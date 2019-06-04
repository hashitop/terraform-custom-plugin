# Terraform with custom plugins

The project provides a brief sample of how to use custom developed plugin. A Terraform plugin can be developed with **Go** language in accordance to specification which can be found at this [page](https://www.terraform.io/docs/plugins/basics.html). There are two options to implement a Terraform plugin
- Resource Provider
- Resource Provisioner 

This sample demonstrates how resource provider plugin can be built and installed into plugin directory and executed by Terraform HCL.

## Pre-requisites

### Packer

The packer command uses `template.json` to build an image that contains **Go**, **Custom Plugin**, and **Terraform** runtime with the workspace populated with `main.tf` where it makes use of the custom plugin. The command below will generate output and its box file.

> packer build template.json

### Vagrant

The output from Packer build can be imported into Vagrant with following commands

> vagrant box add --name \<**BOX NAME**> packer-go-vbox.box

Then creating `Vagrantfile` and spin up the VM in a directory with the following commands

- > vagrant init -m <**BOX NAME**>
- > vagrant up

## Sample Custom Plugin

Log into the box with `vagrant ssh` command then the source code of the custom plugin will be located at `/home/vagrant/go/src/github.com/petems/terraform-provider-extip` where the `main()` function delegates the work to `extip.Provider` function located at the file `extip/provider.go` in which returns `terraform.ResourceProvider` data type. The entries in the result object `terraform.ResourceProvider` is computed by `datasource` function that is located in `extip/datasource.go` where the external request sent to AWS endpoint to find IP address.

Once this module is built and copied into `.terraform.d`, it then can be discovered automatically by Terraform as shown in `main.tf`

```
data "extip" "external_ip" {
}

output "external_ip" {
  value = "${data.extip.external_ip.ipaddress}"
}
```
## Test with Kitchen and InSpec

Testing requires dependencies which are defined in `Gemfile`. In order to install those dependencies, following command can be used.

> bundle install

Testing will be done inside VM. Packer will create an image that contains all required resources.

- Terraform
- Go runtime
- Custom plugin source code
- Custom plugin binary (installed)
- Test script

The `template.json` will copy `test.sh` into the image which is used to execute steps to perform Terraform workspace clean up and subsequent `init` and `apply`, including `destroy` to ensure all steps are performed without error. The `test.sh` is executed by **InSpec** during verification phase of `kitchen verify` command and look for `external_ip` with **IP** using regular expression. The commands below can be executed to perform tests via **Kitchen CLI**.

- Create test environment
> kitchen converge

- Verify test environment
> kitchen verify

- Destroy test environment
> kitchen destroy

