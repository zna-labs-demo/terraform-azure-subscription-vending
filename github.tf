# Create GitHub repository for each app
resource "github_repository" "app_repo" {
  for_each = local.subscriptions

  name        = "terraform-azure-infra-${each.key}"
  description = "Infrastructure repository for ${each.key} - Owner: ${each.value.owner_email}"
  visibility  = "public"
  auto_init   = true

  # Enable features
  has_issues   = true
  has_projects = false
  has_wiki     = false
}

# Add a README to each app repo
resource "github_repository_file" "app_readme" {
  for_each = local.subscriptions

  repository = github_repository.app_repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content    = <<-EOT
    # ${each.key} Infrastructure

    This repository manages infrastructure for application ${each.key}.

    ## Details
    - **App ID**: ${each.key}
    - **Owner**: ${each.value.owner_email}
    - **Cost Center**: ${each.value.cost_center}
    - **Subscription ID**: ${each.value.subscription_id}
    - **Created**: ${each.value.timestamp}

    ## Workspace
    - **TFC Workspace**: ${each.key}n1d01-app-infra
    - **ADO Project**: ${each.key}n1
  EOT

  commit_message      = "Initialize infrastructure repository"
  overwrite_on_create = true
}
