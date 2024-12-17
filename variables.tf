variable "environment" {
  default     = "dev"
  description = "The environment in which the resources will be created."
  type        = string
}

variable "resource_group_name" {
  default     = "rg-om"
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  default     = "switzerlandnorth"
  description = "The location/region where the resources will be created."
  type        = string
}

variable "aks_name" {
  default     = "aks-om"
  description = "The name of the AKS cluster."
  type        = string
}

variable "k8s_namespace" {
  default     = "openmetadata"
  description = "The name of the Kubernetes namespace."
  type        = string

}

variable "om_mysql_password" {
  description = "The password for the OpenMetadata MySQL database."
  type        = string
  default     = "openmetadata_password"
}

variable "airflow_mysql_password" {
  description = "The password for the Airflow MySQL database."
  type        = string
  default     = "airflow_pass"
}

variable "om_airflow_password" {
  description = "The password for the OpenMetadata Airflow instance."
  type        = string
  default     = "admin"
}
