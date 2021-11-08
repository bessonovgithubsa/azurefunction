using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$Request = $Request.Body
$action = $Request.action
Write-Host "Action Type:" $Request.action
Write-Host "Repository Name:" $Request.repository.name
Write-Host "Private Repository:" $Request.repository.private

# Header for GitHub API
$ghToken = $env:ghToken
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/vnd.github.v3+json")
$headers.Add("Authorization", "Basic $ghToken")
$headers.Add("Content-Type", "application/json")

$ghRepoName = $Request.repository.name

function ConfigureBranchProtection {
    $bodyConfigureProtection = "{`"required_status_checks`":null,`"required_conversation_resolution`":true,`"enforce_admins`":true,`"required_pull_request_reviews`":{`"dismissal_restrictions`":{},`"dismiss_stale_reviews`":false,`"require_code_owner_reviews`":false,`"required_approving_review_count`":1},`"restrictions`":null}"

    $response = Invoke-RestMethod "https://api.github.com/repos/bessonovgithubsa/$ghRepoName/branches/main/protection" -Method 'PUT' -Headers $headers -Body $bodyConfigureProtection
    $response | ConvertTo-Json
}
 
function CreateIssueForNewRepo {
    $bodyissue = "{`"title`":`"WARNING: Please check default branch protection rules`", `"body`": `"The following rules have been applied to **main** branch: \n\n- Required number of approvals before merging: 1 \n- All configured restrictions applicable for administrators as well \n- All conversations on code must be resolved before a pull request can be merged into a main branch \n\n @brsrom`"}"

    $response = Invoke-RestMethod "https://api.github.com/repos/bessonovgithubsa/$ghRepoName/issues" -Method 'POST' -Headers $headers -Body $bodyissue
    $response | ConvertTo-Json
}

function DummyCommit {
    $bodyDummyCommit = "{
    `n  `"branch`": `"main`",
    `n  `"message`": `"Initial commit to create main branch`",
    `n  `"content`": `"VGhpcyBlbXB0eSBSRUFETUUubWQgZmlsZSBoYXMgYmVlbiBjcmVhdGVkIGZvciBpbml0aWFsIGNvbW1pdCB0byBjcmVhdGUgbWFpbiBicmFuY2ggYW5kIGRlZmF1bHQgcHJvdGVjdGluZyBydWxlcy4gUGxlYXNlIHVwZGF0ZSBpdCBhcyBuZWVkZWQuCg==`"
    `n}"

    $response = Invoke-RestMethod "https://api.github.com/repos/bessonovgithubsa/$ghRepoName/contents/README.md" -Method 'PUT' -Headers $headers -Body $bodyDummyCommit
    $response | ConvertTo-Json
}

if ($action -eq "created") {
    try {
        Write-Host Configuring branch protection
        ConfigureBranchProtection
        Write-Host "Creating issue for new repository: $ghRepoName"
        CreateIssueForNewRepo
    }
    catch {
        Write-Host No branches exist, creating dummy commit to initialize branch.
        DummyCommit
        Write-Host Configuring branch protection
        ConfigureBranchProtection
        Write-Host "Creating issue for new repository: $ghRepoName"
        CreateIssueForNewRepo
    }
    finally {
        Write-Host Branch protection configured and issue created
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Request
    })