# =============================================================================
# TFC Workspaces - Multi-Environment (Dev, QA, Prod)
# =============================================================================
# Creates 3 workspaces per app for progressive deployment:
#   - {app_id}n1d01-app-infra (dev)
#   - {app_id}n1q01-app-infra (qa)
#   - {app_id}p1p01-app-infra (prod)
# =============================================================================

# Create TFC workspace for each app+environment combination
resource "tfe_workspace" "app_workspace" {
  for_each = local.app_environments

  name         = each.value.workspace_name
  organization = var.tfc_org
  description  = "Infrastructure workspace for ${each.value.app_id} - ${upper(each.value.env_name)} - Owner: ${each.value.owner_email}"

  # VCS settings - connect to the app's GitHub repo
  vcs_repo {
    identifier     = "${var.github_org}/terraform-azure-infra-${each.value.app_id}"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
    branch         = "main"
  }

  # Workspace settings
  auto_apply            = each.value.auto_apply
  file_triggers_enabled = true
  queue_all_runs        = false
  working_directory     = ""

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
# Workspace Variables
# =============================================================================

# Azure Subscription ID (same for all environments of an app)
resource "tfe_variable" "subscription_id" {
  for_each = local.app_environments

  key          = "ARM_SUBSCRIPTION_ID"
  value        = each.value.subscription_id
  category     = "env"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Azure Subscription ID"
}

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
  value        = each.value.env_name == "qa" ? "staging" : each.value.env_name
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
