# End-to-End CICD pipeline to test, deploy and assign scripts to security groups in Microsoft Intune

## Overview

Integrate DevOps principles in endpoint management. Leverages several DevOps tools and Azure services to streamline infrastructure provisioning, configuration management, and script delivery.

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
  Ansible[Ansible (Configuration management)]
  KeyVault[Azure Key Vault]
  ADO[Azure DevOps Pipeline (CI/CD)]
  Intune[Microsoft Intune]
  Group[Azure AD Group]

  Dev --> GitHub --> Actions
  Actions --> Tests
  Actions --> Terraform --> Ansible --> KeyVault
  Actions --> ADO --> Intune --> Group
