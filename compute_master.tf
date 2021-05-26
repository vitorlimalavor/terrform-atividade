variable "network_name" {
   default = "mysql"
}
resource "google_compute_network" "default"{
  name = "${var.network_name}"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "us-central1"
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "dasa-ssh"
  network = "${var.network_name}"

allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [ "0.0.0.0/0"] 
  source_tags = ["ssh"]
}
resource "google_compute_address" "static" {
  name = "ipv4-address"
}
resource "google_compute_instance" "default"{
     name         = "vm-mysql"
     machine_type = "f1-micro"
     zone         = "us-central1-a"
    boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-bionic-v20210514"
    }
  }

network_interface {
     network = "${google_compute_subnetwork.default.name}"
     subnetwork = "${google_compute_subnetwork.default.name}" 
     access_config {
        nat_ip = "${google_compute_address.static.address}"
    }
}
metadata = {
   ssh-keys = "vitorllavor:${file("/var/root/.ssh/id_rsa.pub")}"
}

provisioner "file" {
      source      = "files/install_master.sh"
      destination = "install_master.sh"
      connection {
         type = "ssh"
         user = "vitorllavor"
         host = "${google_compute_address.static.address}"
         private_key = "${file("/var/root/.ssh/id_rsa")}"
         agent = false
      }  
  }

provisioner "file" {
      source      = "files/users.sql"
      destination = "users.sql"
      connection {
         type = "ssh"
         user = "vitorllavor"
         host = "${google_compute_address.static.address}"
         private_key = "${file("/var/root/.ssh/id_rsa")}"
         agent = false
      }  
  }
provisioner "file" {
      source      = "files/mysqld.conf"
      destination = "mysqld.conf"
      connection {
         type = "ssh"
         user = "vitorllavor"
         host = "${google_compute_address.static.address}"
         private_key = "${file("/var/root/.ssh/id_rsa")}"
         agent = false
      }  
  }

provisioner "remote-exec" {
      connection {
         type = "ssh"
         user = "vitorllavor"
         host = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
         private_key = "${file("/var/root/.ssh/id_rsa")}"
         agent = false
      } 

      inline = [
      "sudo chmod +x install_master.sh",
      "sudo ./install_master.sh",
      ]

   }


}
output "ip-master" {
  value = "${google_compute_address.static.address}"
}

