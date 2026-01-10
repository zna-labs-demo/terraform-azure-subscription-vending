locals {
  # Read the subscription requests from JSON file
  workspace_data = jsondecode(file("${path.module}/main.workspace.json"))

  # Transform into a map keyed by app_id for for_each
  subscriptions = {
    for sub in local.workspace_data : sub.app_id => sub
  }

  # Environment configurations for multi-environment workspaces
  environments = {
    dev = {
      tier             = "n"
      environment_code = "d"
      sequence         = "01"
      auto_apply       = false
    }
    qa = {
      tier             = "n"
      environment_code = "q"
      sequence         = "01"
      auto_apply       = false
    }
    prod = {
      tier             = "p"
      environment_code = "p"
      sequence         = "01"
      auto_apply       = false
    }
  }

  # Create a flattened map of all app+environment combinations
  app_environments = {
    for pair in flatten([
      for app_id, app in local.subscriptions : [
        for env_name, env in local.environments : {
          key              = "${app_id}-${env_name}"
          app_id           = app_id
          env_name         = env_name
          tier             = env.tier
          environment_code = env.environment_code
          sequence         = env.sequence
          auto_apply       = env.auto_apply
          subscription_id  = app.subscription_id
          owner_email      = app.owner_email
          workspace_name   = "${app_id}${env.tier}1${env.environment_code}${env.sequence}"
        }
      ]
    ]) : pair.key => pair
  }
}
