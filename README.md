# Subscription Vending - Root Repository

This repository implements a GitOps-based subscription vending pattern for Zurich North America.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Logic App     │────▶│  This Repo       │────▶│  TFC Workspace  │
│   (HTTP POST)   │     │  (JSON update)   │     │  (terraform)    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                         │
                        ┌────────────────────────────────┼────────────────────────────────┐
                        ▼                                ▼                                ▼
                ┌───────────────┐              ┌─────────────────┐              ┌─────────────────┐
                │ GitHub Repo   │              │ TFC Workspace   │              │ ADO Project     │
                │ (app infra)   │              │ (app infra)     │              │ (pipelines)     │
                └───────────────┘              └─────────────────┘              └─────────────────┘
```

## How It Works

1. A Logic App receives an HTTP POST with subscription request details
2. The Logic App commits a new entry to `main.workspace.json`
3. Terraform Cloud detects the change and runs this workspace
4. For each entry in the JSON, Terraform creates:
   - **GitHub Repository**: `terraform-azure-infra-{app_id}`
   - **TFC Workspace**: `{app_id}n1d01-app-infra`
   - **ADO Project**: `{app_id}n1` with pipeline

## Files

| File | Purpose |
|------|---------|
| `main.workspace.json` | Source of truth - array of subscription requests |
| `providers.tf` | Provider configurations (GitHub, TFC, ADO) |
| `variables.tf` | Input variables |
| `locals.tf` | Reads and transforms JSON data |
| `main.tf` | OAuth client for TFC-GitHub integration |
| `github.tf` | Creates GitHub repositories |
| `tfc.tf` | Creates TFC workspaces |
| `ado.tf` | Creates ADO projects and pipelines |
| `outputs.tf` | Output values |

## JSON Schema

`main.workspace.json` contains an array of subscription requests:

```json
[
  {
    "app_id": "a99999",
    "owner_email": "demo@example.com",
    "cost_center": "12345678",
    "subscription_id": "ead88337-e2b7-44b9-a371-7595a6d5474b",
    "timestamp": "2025-12-10T15:00:00Z"
  }
]
```

## Naming Conventions

| Resource | Pattern | Example |
|----------|---------|---------|
| GitHub Repo | `terraform-azure-infra-{app_id}` | `terraform-azure-infra-a99999` |
| TFC Workspace | `{app_id}n1d01-app-infra` | `a99999n1d01-app-infra` |
| ADO Project | `{app_id}n1` | `a99999n1` |

## Required Variables

Set these in the TFC workspace:

| Variable | Type | Description |
|----------|------|-------------|
| `github_token` | sensitive | GitHub PAT |
| `tfc_token` | sensitive | TFC API token |
| `ado_token` | sensitive | Azure DevOps PAT |
