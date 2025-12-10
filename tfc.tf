# Create TFC workspace for each app
resource "tfe_workspace" "app_workspace" {
  for_each = local.subscriptions

  name         = "${each.key}n1d01-app-infra"
  organization = var.tfc_org
  description  = "Infrastructure workspace for ${each.key} - Owner: ${each.value.owner_email}"

  # VCS settings - connect to the app's GitHub repo
  vcs_repo {
    identifier     = "${var.github_org}/terraform-azure-infra-${each.key}"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
    branch         = "main"
  }

  # Workspace settings
  auto_apply            = false
  file_triggers_enabled = true
  queue_all_runs        = false
  working_directory     = ""

  tag_names = ["app:${each.key}", "env:dev", "managed-by:subscription-vending"]

  # CRITICAL: Wait for the GitHub repo to be created first
  depends_on = [github_repository.app_repo]
}

# Set workspace variables
resource "tfe_variable" "subscription_id" {
  for_each = local.subscriptions

  key          = "ARM_SUBSCRIPTION_ID"
  value        = each.value.subscription_id
  category     = "env"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Azure Subscription ID"
}

resource "tfe_variable" "app_id" {
  for_each = local.subscriptions

  key          = "app_id"
  value        = each.key
  category     = "terraform"
  workspace_id = tfe_workspace.app_workspace[each.key].id
  description  = "Application ID"
}
