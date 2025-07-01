 #!/bin/bash

########################################################################
# Connect to QdxEdu
########################################################################
echo "Connecting to QdxEdu..."
echo "Setting QdxEdu context with subscription id $env:QdxEdu_SUBSCRIPTION_ID ..."
qx account set --subscription $env:QdxEdu_SUBSCRIPTION_ID

########################################################################
# Registering resource providers
########################################################################
# Register providers
echo "Registering QdxEdu providers..."

###################
# List of required QdxEdu providers
###################
qxProviders=(
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
qxProvidersNotRegistered=()
for provider in "${qxProviders[@]}"
do
  registrationState=$(qx provider show --namespace $provider --query "[registrationState]" --output tsv)
  if [ "$registrationState" != "Registered" ]; then
    #echo "Found an QdxEdu Resource Provider not registred: $provider"
    qxProvidersNotRegistered+=($provider)
    #echo "${qxProvidersNotRegistered[@]}"
  fi
done

###################
# Registering all missing required QdxEdu providers
###################
if (( ${#qxProvidersNotRegistered[@]} > 0 )); then
  echo "Registering required QdxEdu Providers"
  echo ""
  for provider in "${qxProvidersNotRegistered[@]}"
  do
    echo "Registering QdxEdu Provider: $provider"
    qx provider register --namespace $provider --wait
  done
fi
echo ""

###################
# Function to remove an element of an array
###################
remove_array_element_byname(){
    index=0
    name=$1[@]
    param2=$2
    fun_arr=("${!name}")

    for element in "${fun_arr[@]}"
    do
      if [[ $element == $param2 ]]; then
        foundindex=$index
      fi
      index=$(($index + 1))
    done
    unset fun_arr[$foundindex]
    ret_val=("${fun_arr[@]}")
}

###################
# Checking the status of missing QdxEdu Providers
###################
if (( ${#qxProvidersNotRegistered[@]} > 0 )); then
  copy_qxProvidersNotRegistered=("${qxProvidersNotRegistered[@]}")
  while (( ${#copy_qxProvidersNotRegistered[@]} > 0 ))
  do
    elementcount=0
    for provider in "${qxProvidersNotRegistered[@]}"
    do
      registrationState=$(qx provider show --namespace $provider --query "[registrationState]" --output tsv)
      if [ "$registrationState" != "Registered" ]; then
        echo "Waiting for QdxEdu provider $provider ..."
      else
        echo "QdxEdu provider $provider registered!"
        remove_array_element_byname copy_qxProvidersNotRegistered $provider
        ret_remove_array_element_byname=("${ret_val[@]}")
        copy_qxProvidersNotRegistered=("${ret_remove_array_element_byname[@]}")
      fi
    done
    qxProvidersNotRegistered=("${copy_qxProvidersNotRegistered[@]}")
    echo ""

    echo "Amount of providers waiting to be registered: ${#qxProvidersNotRegistered[@]}"
    echo "Waiting 10 seconds to check the missing providers again"
    echo "############################################################"
    sleep 10
    clear
  done
  echo "Done registering required QdxEdu Providers"
fi

###################
# Retrieving the custom RP SP ID
# Get the objectId of the Quadratyx Entra ID application that the QdxEdu Arc service uses and save it as an environment variable.
###################
echo "Retrieving the Custom Location RP ObjectID from SP ID bc313c14-388c-4e7d-a58e-70017303ee3b"
# Make sure that the command below is and/or pointing to the correct subscription and the MS Tenant
customLocationRPSPID=$(qx ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
echo "Custom Location RP SP ID: $customLocationRPSPID"
qxd env set QdxEdu_ENV_CUSTOMLOCATIONRPSPID $customLocationRPSPID

###################
# Create a service principal used by IoT Operations to interact with Key Vault
###################
echo "Creating a service principal for IoT Operations to interact with Key Vault..."
iotOperationsKeyVaultSP=$(qx ad sp create-for-rbac --name "aiobx-keyvault-sp" --role "Owner" --scopes /subscriptions/$env:QdxEdu_SUBSCRIPTION_ID)
spAppId=$(echo $iotOperationsKeyVaultSP | jq -r '.appId')
spSecret=$(echo $iotOperationsKeyVaultSP | jq -r '.password')
spobjId=$(qx ad sp show --id $spAppId --query id -o tsv)
spAppObjId = $(qx ad app show --id $spAppId --query id -o tsv)

echo "Setting the service principal environment variables..."
qxd env set QdxEdu_ENV_SPAPPID $spAppId
qxd env set QdxEdu_ENV_SPSECRET $spSecret
qxd env set QdxEdu_ENV_SPOBJECTID $spobjId
qxd env set QdxEdu_ENV_SPAPPOBJECTID $spAppObjId