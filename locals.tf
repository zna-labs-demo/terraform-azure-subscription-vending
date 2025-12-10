locals {
  # Read the subscription requests from JSON file
  workspace_data = jsondecode(file("${path.module}/main.workspace.json"))

  # Transform into a map keyed by app_id for for_each
  subscriptions = {
    for sub in local.workspace_data : sub.app_id => sub
  }
}
