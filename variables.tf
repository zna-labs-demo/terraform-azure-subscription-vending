variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "zna-labs-demo"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "tfc_org" {
  description = "Terraform Cloud organization name"
  type        = string
  default     = "zna-labs"
}

variable "tfc_token" {
  description = "Terraform Cloud API token"
  type        = string
  sensitive   = true
}

variable "ado_org_url" {
  description = "Azure DevOps organization URL"
  type        = string
  default     = "https://dev.azure.com/z-training"
}

variable "ado_token" {
  description = "Azure DevOps personal access token"
  type        = string
  sensitive   = true
}
