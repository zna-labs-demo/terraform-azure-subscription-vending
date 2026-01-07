# =============================================================================
# GitHub Resources - Template-Based Repository Creation
# =============================================================================
# Creates infrastructure repositories from the template repository.
# Each vended subscription gets a fully configured starting point.
# =============================================================================

# -----------------------------------------------------------------------------
# Application Infrastructure Repositories (From Template)
# -----------------------------------------------------------------------------
resource "github_repository" "app_repo" {
  for_each = local.subscriptions

  name        = "terraform-azure-infra-${each.key}"
  description = "Infrastructure repository for ${each.key} - Owner: ${each.value.owner_email}"
  visibility  = "public"

  # USE THE TEMPLATE REPOSITORY - This gives each repo a complete starting point
  template {
    owner                = var.github_org
    repository           = "terraform-azure-infra-template"
    include_all_branches = false
  }

  has_issues   = true
  has_projects = false
  has_wiki     = false

  # Delete branch on merge for cleaner PRs
  delete_branch_on_merge = true
}

# -----------------------------------------------------------------------------
# Update README with App-Specific Information
# -----------------------------------------------------------------------------
resource "github_repository_file" "app_readme" {
  for_each = local.subscriptions

  repository = github_repository.app_repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content    = <<-EOT
# ${each.key} Infrastructure

This repository manages Azure infrastructure for application **${each.key}**.

> Provisioned automatically by the Subscription Vending process.

## Application Details

| Property | Value |
|----------|-------|
| **App ID** | `${each.key}` |
| **Owner** | ${each.value.owner_email} |
| **Cost Center** | ${each.value.cost_center} |
| **Subscription ID** | `${each.value.subscription_id}` |
| **Created** | ${each.value.timestamp} |

## Quick Links

| Resource | Link |
|----------|------|
| **TFC Workspace** | [${each.key}n1d01-app-infra](https://app.terraform.io/app/zna-labs/workspaces/${each.key}n1d01-app-infra) |
| **ADO Project** | [${each.key}n1](https://dev.azure.com/z-training/${each.key}n1) |
| **GitHub Repo** | [terraform-azure-infra-${each.key}](https://github.com/${var.github_org}/terraform-azure-infra-${each.key}) |

---

## Getting Started

### 1. Clone and Create a Feature Branch

```bash
git clone https://github.com/${var.github_org}/terraform-azure-infra-${each.key}.git
cd terraform-azure-infra-${each.key}
git checkout -b feature/add-my-resource
```

### 2. Make Your Changes

Edit the Terraform files to add your infrastructure. Start with `main.tf`.

### 3. Local Quality Checks

```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

### 4. Commit, Push, and Create PR

```bash
git add .
git commit -m "feat: add <description>"
git push -u origin feature/add-my-resource
```

Then open a Pull Request in GitHub.

---

## Repository Structure

```
.
├── main.tf              # Primary infrastructure (start here)
├── variables.tf         # Input variables
├── locals.tf            # Computed values & naming
├── outputs.tf           # Output definitions
├── providers.tf         # Azure & TFC provider config
├── azure-pipelines.yml  # CI quality gate pipeline
├── .tflint.hcl         # Linting rules
└── README.md           # This file
```

## CI/CD Workflow

```
Feature Branch ──► Pull Request ──► Quality Gates ──► Merge ──► TFC Apply
                        │                 │
                        │                 ├── terraform fmt
                        │                 ├── terraform validate  
                        │                 ├── tflint
                        │                 └── tfsec
                        │
                        └── Requires 1 approval
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `app_id` | Application ID (auto-set) | `${each.key}` |
| `environment` | Environment | `dev` |
| `location` | Azure region | `eastus` |
| `enable_storage_account` | Create storage | `false` |
| `enable_key_vault` | Create Key Vault | `false` |

---

## Need Help?

- [CI/CD Training](https://dev.azure.com/z-training/cicd-training) - Learn pipeline fundamentals
- [Terraform Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) - Azure provider reference
EOT

  commit_message      = "Initialize infrastructure repository for ${each.key}"
  overwrite_on_create = true

  depends_on = [github_repository.app_repo]
}

# -----------------------------------------------------------------------------
# Create terraform.tfvars.example with App-Specific Values
# -----------------------------------------------------------------------------
resource "github_repository_file" "app_tfvars" {
  for_each = local.subscriptions

  repository = github_repository.app_repo[each.key].name
  branch     = "main"
  file       = "terraform.tfvars.example"
  content    = <<-EOT
# =============================================================================
# Terraform Variables for ${each.key}
# =============================================================================
# Copy this file to terraform.tfvars and customize as needed.
# Note: app_id is automatically set via TFC workspace variables.
# =============================================================================

# app_id is set automatically by subscription vending - DO NOT CHANGE
# app_id = "${each.key}"

environment = "dev"
location    = "eastus"

# Enable optional resources
enable_storage_account = false
enable_key_vault       = false

# Additional tags
tags = {
  cost_center = "${each.value.cost_center}"
  owner       = "${each.value.owner_email}"
}
EOT

  commit_message      = "Add terraform.tfvars.example for ${each.key}"
  overwrite_on_create = true

  depends_on = [github_repository_file.app_readme]
}
