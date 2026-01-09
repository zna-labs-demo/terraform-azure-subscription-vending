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

# =============================================================================
# Azure Credentials for Workspaces
# =============================================================================

variable "azure_client_id" {
  description = "Azure Service Principal Client ID (App ID)"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant (Directory) ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}
