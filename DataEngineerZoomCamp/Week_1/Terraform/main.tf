terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  #   credentials = "keys/my-creds.json"
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

resource "google_storage_bucket" "demo-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true

  #   lifecycle_rule {
  #     condition {
  #       age = 3
  #     }
  #     action {
  #       type = "Delete"
  #     }
  #   }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

#export GOOGLE_CREDENTIALS='/home/logofios/education/Terraform/keys/my-creds.json'
#unset GOOGLE_CREDENTIAL
#echo $GOOGLE_CREDENTIALS


resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id                  = var.bq_dataset_name
  friendly_name               = "test"
  description                 = "This is a test description"
  location                    = var.location
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}