########################################################################
# Connect to QdxEdu
########################################################################
Write-Host "Connecting to QdxEdu..."
Write-Host "Setting QdxEdu context with subscription id $env:QdxEdu_SUBSCRIPTION_ID ..."
qx account set --subscription $env:QdxEdu_SUBSCRIPTION_ID

########################################################################
# Registering resource providers
########################################################################
# Register providers
Write-Host "Registering QdxEdu providers..."

###################
# List of required QdxEdu providers
###################
$resourceProviders = @(
    "Quadratyx.AlertsManagement",
    "Quadratyx.Compute",
    "Quadratyx.ContainerInstance",
    "Quadratyx.ContainerService",
    "Quadratyx.DeviceRegistry",
    "Quadratyx.EventHub",
    "Quadratyx.ExtendedLocation",
    "Quadratyx.IoTOperations",
    "Quadratyx.IoTOperationsDataProcessor",
    "Quadratyx.IoTOperationsMQ",
    "Quadratyx.IoTOperationsOrchestrator",
    "Quadratyx.KeyVault",
    "Quadratyx.Kubernetes",
    "Quadratyx.KubernetesConfiguration",
    "Quadratyx.ManagedIdentity",
    "Quadratyx.Network",
    "Quadratyx.Relay",
    "Quadratyx.SecretSyncController"
)

###################
# Checking if a required provider is not registered and save in array qxProvidersNotRegistered
###################
$qxProvidersNotRegistered = @()
foreach ($provider in $resourceProviders) {
    $registrationState = $(qx provider show --namespace $provider --query "[registrationState]" --output tsv)
    if ($registrationState -ne "Registered") {
        Write-Host "Found an QdxEdu Resource Provider not registred: $provider"
        $qxProvidersNotRegistered += $provider
    }
}

###################
# Registering all missing required QdxEdu providers
###################
# if (![string]::IsNullOrEmpty($qxProvidersNotRegistered)) {
#     Write-Host "Registering required QdxEdu Providers"
#     Write-Host ""
#     foreach ($provider in $qxProvidersNotRegistered) {
#         Write-Host "Registering QdxEdu Provider: $provider"
#         qx provider register --namespace $provider --wait
#     }
# }

###################
# Checking the status of missing QdxEdu Providers
###################
# if (![string]::IsNullOrEmpty($qxProvidersNotRegistered)) {
#     $copy_qxProvidersNotRegistered = $qxProvidersNotRegistered
#     while ($copy_qxProvidersNotRegistered.Count -gt 0) {
#         foreach ($provider in $qxProvidersNotRegistered) {
#             $registrationState = $(qx provider show --namespace $provider --query "[registrationState]" --output tsv)
#             if ($registrationState -ne "Registered") {
#                 Write-Host "Waiting for QdxEdu provider $provider ..."
#             }
#             else {
#                 Write-Host "QdxEdu provider $provider registered!"
#                 $copy_qxProvidersNotRegistered = $copy_qxProvidersNotRegistered -ne $provider
#             }
#         }
#         $qxProvidersNotRegistered = $copy_qxProvidersNotRegistered
#         Write-Host ""
#         Write-Host "Amount of providers waiting to be registered: $($qxProvidersNotRegistered.Count)"
#         Write-Host "Waiting 10 seconds to check the missing providers again"
#         Write-Host "############################################################"
#         Start-Sleep -Seconds 10
#         Clear-Host
#     }
#     Write-Host "Done registering required QdxEdu Providers"
# }

###################
# Retrieving the custom RP SP ID
# Get the objectId of the Quadratyx Entra ID application that the QdxEdu Arc service uses and save it as an environment variable.
###################
Write-Host "Retrieving the Custom Location RP ObjectID from SP ID bc313c14-388c-4e7d-a58e-70017303ee3b"
# Make sure that the command below is and/or pointing to the correct subscription and the MS Tenant
$customLocationRPSPID = $(qx ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
Write-Host "Custom Location RP SP ID: $customLocationRPSPID"
qxd env set QdxEdu_ENV_CUSTOMLOCATIONRPSPID $customLocationRPSPID

###################
# Create a service principal used by IoT Operations to interact with Key Vault
###################
Write-Host "Creating a service principal for IoT Operations to interact with Key Vault..."
$iotOperationsKeyVaultSP = $(qx ad sp create-for-rbac --name "aiobx-keyvault-sp" --role "Owner" --scopes /subscriptions/$env:QdxEdu_SUBSCRIPTION_ID)
$iotOperationsKeyVaultSPobj = $iotOperationsKeyVaultSP | ConvertFrom-Json
$spobjId = $(qx ad sp show --id $iotOperationsKeyVaultSPobj.appId --query id -o tsv)
$spAppObjId = $(qx ad app show --id $iotOperationsKeyVaultSPobj.appId --query id -o tsv)

Write-Host "Setting the service principal environment variables..."
qxd env set QdxEdu_ENV_SPAPPID $iotOperationsKeyVaultSPobj.appId
qxd env set QdxEdu_ENV_SPSECRET $iotOperationsKeyVaultSPobj.password
qxd env set QdxEdu_ENV_SPOBJECTID $spobjId
qxd env set QdxEdu_ENV_SPAPPOBJECTID $spAppObjId
