# Azure function guide

This is the web service based on Azure Function (PowerShell) to listen for GitHub webhooks to configure branch protection rules on repositories for **main** branch only and to create issue inside repository with short description about applied rules.

If new repository created empty, dummy commit is triggered to create main branch inclduing README.md file with short description.

Following rules are being applied to new created repositories:

* Required number of approvals before merging: 1
* All configured restrictions applicable for administrators as well
* All conversations on code must be resolved before a pull request can be merged into a main branch

Inside repository issue is created with description about what rules have been applied.

The main script you will find under `branchprotection/run.ps1`

Please refer to [this guide](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-powershell) to deploy Azure function and test functinality if needed.

2 other repositories have been created under the same organization to prove the functionality of the Azure Function:

* one repository has been created without any branches: `emptyrepo`
* another has been created with initial README.md file: `repowithreadme`
