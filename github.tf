# =============================================================================
# GitHub Resources - Template-Based Repository Creation
# =============================================================================
# Creates infrastructure repositories from the template repository.
# Each vended subscription gets a fully configured starting point.
#
# The template repository provides all necessary files (README, tfvars, etc.)
# No files are managed by Terraform after initial creation - changes should
# go through PR process or destroy/recreate from template.
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
# Repository Ruleset for Main Branch
# -----------------------------------------------------------------------------
# Rulesets enforce PR-based workflow for all users, including admins.
# Organization admins can bypass via PR only (not direct push) for emergencies.
# -----------------------------------------------------------------------------
resource "github_repository_ruleset" "main" {
  for_each = local.subscriptions

  name        = "main-branch-protection"
  repository  = github_repository.app_repo[each.key].name
  target      = "branch"
  enforcement = "active"

  # Apply to the default branch (main)
  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # Only org admins can bypass, and only via PR (not direct push)
  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "pull_request"
  }

  rules {
    # Require pull request before merging
    pull_request {
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
    }

    # Require status checks to pass
    required_status_checks {
      strict_required_status_checks_policy = true

      required_check {
        context = "QualityGates / TerraformFormat"
      }
      required_check {
        context = "QualityGates / TerraformValidate"
      }
      required_check {
        context = "QualityGates / TFLint"
      }
    }

    # Prevent force pushes (protects git history)
    non_fast_forward = true

    # Prevent branch deletion
    deletion = true
  }

  depends_on = [github_repository.app_repo]
}
