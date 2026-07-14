$ErrorActionPreference = "Stop"

$credentialsPath = Join-Path $PSScriptRoot "..\.aws-local\credentials"
$outputPath = Join-Path $PSScriptRoot "..\terraform.tfvars"

if (-not (Test-Path -LiteralPath $credentialsPath)) {
    throw "File .aws-local/credentials was not found."
}

$awsCredentials = Get-Content -LiteralPath $credentialsPath -Raw
$accessKey = [regex]::Match($awsCredentials, '(?m)^aws_access_key_id\s*=\s*(.+)$').Groups[1].Value.Trim()
$secretKey = [regex]::Match($awsCredentials, '(?m)^aws_secret_access_key\s*=\s*(.+)$').Groups[1].Value.Trim()

if (-not $accessKey -or -not $secretKey) {
    throw "AWS access key was not found in .aws-local/credentials."
}

$secureToken = Read-Host "Paste GitHub fine-grained token" -AsSecureString
$tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
try {
    $githubToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
}

if (-not $githubToken) {
    throw "GitHub token cannot be empty."
}

function New-LocalPassword {
    return ([guid]::NewGuid().ToString('N') + [guid]::NewGuid().ToString('N')).Substring(0, 32)
}

$content = @"
aws_region                    = "us-east-1"
cluster_name                  = "final-project-eks-cluster"
ecr_repository_name           = "lesson-5-ecr"
git_repository_url            = "https://github.com/Anastasia-Danyliuk/lesson-5-terraform.git"
git_revision                  = "final-project"
github_username               = "Anastasia-Danyliuk"
github_token                  = "$githubToken"
jenkins_aws_access_key_id     = "$accessKey"
jenkins_aws_secret_access_key = "$secretKey"
db_name                       = "django_db"
db_username                   = "django_user"
db_password                   = "$(New-LocalPassword)"
django_secret_key             = "$(New-LocalPassword)"
grafana_admin_password        = "$(New-LocalPassword)"
"@

Set-Content -LiteralPath $outputPath -Value $content -Encoding utf8
Write-Host "terraform.tfvars was created. The file is ignored by Git."
