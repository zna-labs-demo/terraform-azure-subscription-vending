output "github_repos" {
  description = "Created GitHub repositories"
  value = {
    for app_id, repo in github_repository.app_repo : app_id => {
      name     = repo.name
      url      = repo.html_url
      clone    = repo.http_clone_url
    }
  }
}

output "tfc_workspaces" {
  description = "Created TFC workspaces"
  value = {
    for app_id, ws in tfe_workspace.app_workspace : app_id => {
      name = ws.name
      id   = ws.id
      url  = "https://app.terraform.io/app/${var.tfc_org}/workspaces/${ws.name}"
    }
  }
}

output "ado_projects" {
  description = "Created Azure DevOps projects"
  value = {
    for app_id, proj in azuredevops_project.app_project : app_id => {
      name = proj.name
      id   = proj.id
      url  = "${var.ado_org_url}/${proj.name}"
    }
  }
}

output "subscription_count" {
  description = "Number of subscriptions being managed"
  value       = length(local.subscriptions)
}
