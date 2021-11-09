# Azure function guide

This is the web service based on Azure Function to listen for GitHub webhooks to configure branch protection rules on repositories. 

The main script is located under `branchprotection/run.ps1`

Please refer to [this guide](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-powershell) to deploy Azure function.

2 other repositories have been created to prove the functionality of the Azure Function:

* one repository has been created without any branches: `emptyrepo`
* another has been created with initial README.md file: `repowithreadme`
