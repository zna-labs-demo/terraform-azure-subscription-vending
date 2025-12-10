# OAuth client for connecting TFC to GitHub
# This needs to be created once and reused for all workspaces
resource "tfe_oauth_client" "github" {
  name             = "github-zna-labs-demo"
  organization     = var.tfc_org
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}
