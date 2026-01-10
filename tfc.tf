# =============================================================================
# TFC Workspaces - Multi-Environment (Dev, QA, Prod)
# =============================================================================
# Creates 3 workspaces per app for progressive deployment:
#   - {app_id}n1d01 (dev)
#   - {app_id}n1q01 (qa)
#   - {app_id}p1p01 (prod)
#
# CLI-driven workflow - ADO pipeline triggers runs via terraform CLI
# =============================================================================

# Create TFC workspace for each app+environment combination
resource "tfe_workspace" "app_workspace" {
  for_each = local.app_environments

  name         = each.value.workspace_name
  organization = var.tfc_org
  description  = "Infrastructure workspace for ${each.value.app_id} - ${upper(each.value.env_name)} - Owner: ${each.value.owner_email}"

  # CLI-driven workspace (no VCS connection)
  # Runs are triggered by Azure DevOps pipeline using terraform CLI

  # Workspace settings
  auto_apply        = each.value.auto_apply
  queue_all_runs    = false
  working_directory = ""
  force_delete      = true  # Allow deletion even if workspace has resources

  tag_names = [
    "app:${each.value.app_id}",
    "env:${each.value.env_name}",
    "tier:${each.value.tier}",
    "managed-by:subscription-vending"
  ]

  # CRITICAL: Wait for the GitHub repo to be created first
  depends_on = [github_repository.app_repo]
}

# =============================================================================
# Workspace Variables - Azure Credentials
# =============================================================================

# Azure Client ID (Service Principal App ID)
resource "tfe_variable" "client_id" {
  for_each = local.app_environments

  key          = "ARM_CLIENT_ID"
  value        = var.azure_client_id
  category     = "env"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Azure Service Principal Client ID"
}

# Azure Tenant ID
resource "tfe_variable" "tenant_id" {
  for_each = local.app_environments

  key          = "ARM_TENANT_ID"
  value        = var.azure_tenant_id
  category     = "env"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Azure Tenant ID"
}

# Azure Client Secret (sensitive)
resource "tfe_variable" "client_secret" {
  for_each = local.app_environments

  key          = "ARM_CLIENT_SECRET"
  value        = var.azure_client_secret
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Azure Service Principal Client Secret"
}

# Azure Subscription ID
resource "tfe_variable" "subscription_id" {
  for_each = local.app_environments

  key          = "ARM_SUBSCRIPTION_ID"
  value        = var.azure_subscription_id
  category     = "env"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Azure Subscription ID"
}

# =============================================================================
# Workspace Variables - Terraform Variables
# =============================================================================

# Application ID
resource "tfe_variable" "app_id" {
  for_each = local.app_environments

  key          = "app_id"
  value        = each.value.app_id
  category     = "terraform"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Application ID"
}

# Environment name
resource "tfe_variable" "environment" {
  for_each = local.app_environments

  key          = "environment"
  value        = each.value.env_name
  category     = "terraform"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Environment name"
}

# Tier (n=non-prod, p=prod)
resource "tfe_variable" "tier" {
  for_each = local.app_environments

  key          = "tier"
  value        = each.value.tier
  category     = "terraform"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Tier (n=non-prod, p=prod)"
}

# Environment code (d=dev, q=qa, p=prod)
resource "tfe_variable" "environment_code" {
  for_each = local.app_environments

  key          = "environment_code"
  value        = each.value.environment_code
  category     = "terraform"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Environment code (d=dev, q=qa, p=prod)"
}

# Sequence number
resource "tfe_variable" "sequence" {
  for_each = local.app_environments

  key          = "sequence"
  value        = each.value.sequence
  category     = "terraform"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Sequence number"
}
