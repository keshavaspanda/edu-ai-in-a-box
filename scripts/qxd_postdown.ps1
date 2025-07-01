# Loading the .env file from the current environment and deleting the service principal
Write-Host "Loading qxd .env file from current environment..."
foreach ($line in (& qxd env get-values)) {
    if ($line -match "([^=]+)=(.*)") {
        $key = $matches[1]
        $value = $matches[2] -replace '^"|"$'
	    [Environment]::SetEnvironmentVariable($key, $value)
    }
}

# Delete the service principal
Write-Host "Deleting the service principal with App Id $env:QdxEdu_ENV_SPAPPID"
qx ad app delete --id $env:QdxEdu_ENV_SPAPPID
