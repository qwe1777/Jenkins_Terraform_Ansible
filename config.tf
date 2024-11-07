terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.77.0"
    }
  }
}

provider "yandex" {
  token     = "y0_AgAAAABo35ylAATuwQAAAAEQsN8NAABcigeFbSZKnYJAxKcaa8ecoLeicQ"
  cloud_id  = "b1g47p1ljv9b9kh90sob"
  folder_id = "b1gfqmh6715rdfi6qlkj"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "build" {
  name        = "build-vm"
  hostname    = "build-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"
  scheduling_policy {
    preemptible = true
  }
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20  
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size = "10"
    }
  }
  network_interface {
    subnet_id = "e2ltodi4orsq0b8faat9"
    nat = true
  }

  metadata = {
    user-data = "${file("./user-data.yml")}"
  }

}  
resource "yandex_compute_instance" "prod" {
  name        = "prod-vm"
  hostname    = "prod-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"
  scheduling_policy {
    preemptible = true
  }
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20  
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size = "10"
    }
  }
  network_interface {
    subnet_id = "e2ltodi4orsq0b8faat9"
    nat = true
  }

  metadata = {
    user-data = "${file("./user-data.yml")}"
  }

}  

output "build_ip" {
  value = yandex_compute_instance.build.network_interface[0].nat_ip_address
}
output "prod_ip" {
  value = yandex_compute_instance.prod.network_interface[0].nat_ip_address
}