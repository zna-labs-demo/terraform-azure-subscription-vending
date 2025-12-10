terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "zna-labs"
    workspaces {
      name = "subscription-vending-root"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}

provider "tfe" {
  token = var.tfc_token
}

provider "azuredevops" {
  org_service_url       = var.ado_org_url
  personal_access_token = var.ado_token
}
