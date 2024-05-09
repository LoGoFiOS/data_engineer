variable "credentials" {
  description = "project credentials"
  default     = "~/education/keys/terraform_gcp_creds.json"
}

variable "project" {
  description = "project"
  default     = "vital-house-382616"
}

variable "region" {
  description = "project region"
  default     = "us-central1"
}

variable "location" {
  description = "project location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "BQ test dataset"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "storage bucket name"
  default     = "vital-house-382616-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}