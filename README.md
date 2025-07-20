# End-to-End CICD pipeline to test, deploy and assign scripts to security groups in Microsoft Intune

## Overview

This project provides a complete CI/CD pipeline that automates testing, provisioning, configuration management, and deployment of PowerShell scripts to Microsoft Intune. It leverages multiple DevOps tools including GitHub Actions, Azure DevOps Pipelines, Terraform, Ansible, and Azure services like Key Vault and Intune.

The solution enables:
- Infrastructure provisioning with Terraform + GitActions (Workflow)
- Configuration management with Ansible + GitActions (Workflow)
- Automated linting and unit testing of scripts
- CI/CD with Azure DevOps on self-hosted Azure DevOps agents
- Secure secret handling with Azure Key Vault and GitHub Secrets
- Script deployment and assignment in Intune via Microsoft Graph API
- Notification via webhooks (Slack and Microsoft Teams)

---

## Architecture

  GitHub[GitHub Repo]
  Actions[GitHub Actions]
  Tests[Pester & PSScriptAnalyzer]
  Terraform[Terraform (Provision Infra)]
  Ansible[Ansible (Configure Agent)]
  KeyVault[Azure Key Vault]
  ADO[Azure DevOps Pipeline (CI/CD)]
  Intune[Microsoft Intune]
  Group[Azure AD Group]

  Dev --> GitHub --> Actions
  Actions --> Tests
  Actions --> Terraform --> Ansible --> KeyVault
  Actions --> ADO --> Intune --> Group
