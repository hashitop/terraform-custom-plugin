provider "random" {
  
}

resource "random_id" "server" {
  keepers {
    ami_id = "ap-southeast-2"
  }
  byte_length = 8
}

resource "random_pet" "server" {
  keepers {
    ami_id = "abc"
  }
}
data "extip" "external_ip" {
}

output "external_ip" {
  value = "${data.extip.external_ip.ipaddress}"
}

output "random_id" {
  value = "${random_id.server.hex}"
}

output "random_id_ami" {
  value = "${random_id.server.keepers.ami_id}"
}

output "random_pet" {
  value = "${random_pet.server.id}"
}

output "random_pet_ami" {
  value = "${random_pet.server.keepers.ami_id}"
}