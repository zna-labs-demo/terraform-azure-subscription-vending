# Create Azure DevOps project for each app
resource "azuredevops_project" "app_project" {
  for_each = local.subscriptions

  name               = each.key
  description        = "DevOps project for ${each.key} - Owner: ${each.value.owner_email}"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    "testplans"    = "disabled"
    "artifacts"    = "enabled"
    "boards"       = "enabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
  }
}

# Create GitHub service connection in ADO
resource "azuredevops_serviceendpoint_github" "github" {
  for_each = local.subscriptions

  project_id            = azuredevops_project.app_project[each.key].id
  service_endpoint_name = "GitHub-${each.key}"
  description           = "GitHub connection for ${each.key}"

  auth_personal {
    personal_access_token = var.github_token
  }
}

# Create a pipeline for each app (connected to their GitHub repo)
resource "azuredevops_build_definition" "app_pipeline" {
  for_each = local.subscriptions

  project_id = azuredevops_project.app_project[each.key].id
  name       = "${each.key}-infra-pipeline"
  path       = "\\"

  ci_trigger {
    use_yaml = true
  }

  # Enable PR triggers for GitHub repos (YAML pr: triggers don't work by default)
  pull_request_trigger {
    use_yaml       = false # Override YAML - use settings defined here
    initial_branch = "main"

    forks {
      enabled       = false
      share_secrets = false
    }

    override {
      auto_cancel = true
      branch_filter {
        include = ["main"]
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.github_org}/terraform-azure-infra-${each.key}"
    branch_name           = "refs/heads/main"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.github[each.key].id
  }
}
