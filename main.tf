locals {
    query = csvdecode(file("./sharedvpc.csv"))

}

variable "project" {
  default = "premium-sum-375108"
}


variable "service_projects" {
    type = list
    default = [ "infatuation-casserole", "wutang-development"]

}

#[START create a custom VPC]
resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
}

#[START create subnet for the above custom VPC]
resource "google_compute_subnetwork" "subnet1" {

for_each = { for query in local.query : query.subnet => query }
  name          = each.value.subnet
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = each.value.secondarycidr
  }
}




# [START vpc_shared_vpc_host_project_enable]
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.project # Replace this with your host project ID in quotes
}
# [END vpc_shared_vpc_host_project_enable]

# [START vpc_shared_vpc_service_project_attach]
resource "google_compute_shared_vpc_service_project" "service1" {
  count = 2
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = element(var.service_projects, count.index)# Replace this with your service project ID in quotes
}
# [END vpc_shared_vpc_service_project_attach]




# [START compute_shared_data_network]
data "google_compute_network" "network" {
  name    = google_compute_network.custom-test.name
  project = var.project
}
# [END compute_shared_data_network]

# [START compute_shared_data_subnet]
data "google_compute_subnetwork" "subnet" {

for_each = { for query in local.query : query.subnet => query }

  name = each.value.subnet
  project = var.project
  region  = each.value.region
}
