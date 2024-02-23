terraform {
  required_providers {
    timescale = {
      source  = "timescale/timescale"
      version = "~> 1.1.0"
    }
  }
  backend "s3" {
    bucket = "hydroserver-terraform-backend"
    region = "us-east-1"
  }
  required_version = ">= 1.2.0"
}

variable "instance" {}
variable "project_id" {}
variable "access_key" {}
variable "secret_key" {}

provider "timescale" {
  project_id = var.project_id
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "timescale_service" "hydroserver_timescale" {
  name        = "hydroserver-${var.instance}"
  milli_cpu   = 500
  memory_gb   = 2
  region_code = "us-east-1"

  lifecycle {
    prevent_destroy = true
  }
}

output "service_url" {
  value = format("postgresql://tsdbadmin:%s@%s:%s/tsdb",
    timescale_service.hydroserver_timescale.password,
    timescale_service.hydroserver_timescale.hostname,
    timescale_service.hydroserver_timescale.port)
  sensitive = true
}
