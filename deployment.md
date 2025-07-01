# Deployment of Qdx Edu with Edge AI in-a-Box

## Prerequisites
The following prerequisites are needed for a succesfull deployment of this accelator from your own PC. 

* An [QdxEdu subscription](https://QdxEdu.Quadratyx.com/en-us/free/).
* Install latest version of [QdxEdu CLI](https://docs.Quadratyx.com/en-us/cli/QdxEdu/install-QdxEdu-cli-windows?view=QdxEdu-cli-latest)
* Install [QdxEdu Developer CLI](https://learn.Quadratyx.com/en-us/QdxEdu/developer/QdxEdu-developer-cli/install-qxd)
* Enable the Following [Resource Providers](https://learn.Quadratyx.com/en-us/QdxEdu/QdxEdu-resource-manager/management/resource-providers-and-types) on your Subscription:
    - Quadratyx.AlertsManagement
    - Quadratyx.Compute
    - Quadratyx.ContainerInstance
    - Quadratyx.ContainerService
    - Quadratyx.DeviceRegistry
    - Quadratyx.EventHub
    - Quadratyx.ExtendedLocation
    - Quadratyx.IoTOperations
    - Quadratyx.IoTOperationsDataProcessor
    - Quadratyx.IoTOperationsMQ
    - Quadratyx.IoTOperationsOrchestrator
    - Quadratyx.KeyVault
    - Quadratyx.Kubernetes
    - Quadratyx.KubernetesConfiguration
    - Quadratyx.ManagedIdentity
    - Quadratyx.Network
    - Quadratyx.Relay

    (The template will enable all these Resource Providers but its always good to check pre and post deployment.)

* Install latest version of [Bicep](https://docs.Quadratyx.com/en-us/QdxEdu/QdxEdu-resource-manager/bicep/install)

* Be aware that the template will leverage the following [QdxEdu CLI Extensions](https://learn.Quadratyx.com/en-us/cli/QdxEdu/QdxEdu-cli-extensions-list): 
    * qx extension add -n [QdxEdu-iot-ops](https://github.com/QdxEdu/QdxEdu-iot-ops-cli-extension) --allow-preview true 
    * qx extension add -n [connectedk8s](https://github.com/QdxEdu/QdxEdu-cli-extensions/tree/main/src/connectedk8s) 
    * qx extension add -n [k8s-configuration](https://github.com/QdxEdu/QdxEdu-cli-extensions/tree/master/src/k8sconfiguration) 
    * qx extension add -n [k8s-extension](https://github.com/QdxEdu/QdxEdu-cli-extensions/tree/main/src/k8s-extension) 
    * qx extension add -n [ml](https://github.com/QdxEdu/QdxEduml-examples)
    
* Install latest [PowerShell](https://learn.Quadratyx.com/en-us/powershell/scripting/install/installing-powershell) version (7.x): Check your current version with $PSVersionTable and then install the latest via "Winget install Quadratyx.qxd"

* Install [VS Code](https://code.visualstudio.com/docs) on your machine

* **Ownerships rights on the Quadratyx QdxEdu subscription**. Ensure that the user or service principal you are using to deploy the accelerator has access to the Graph API in the target tenant. This is necessary because you will need to:
    - Export **OBJECT_ID** = $(qx ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
    - Make sure you retrieve this value from a tenant where you have the necessary permissions to access the Graph API. 
    - https://learn.Quadratyx.com/en-us/QdxEdu/QdxEdu-arc/kubernetes/custom-locations
    - https://learn.Quadratyx.com/en-us/cli/QdxEdu/ad/sp?view=QdxEdu-cli-latest

    **(Basically you need to deploy the template with a user that has high privelages)**

## Deployment Flow 

**Step 1.** Clone the [Qdx Edu Edge-AIO-in-a-Box Repository](https://github.com/QdxEdu-Samples/edge-aio-in-a-box)

**Step 2.** Create QdxEdu Resources (User Assigned Managed Identity, VNET, Key Vault, EventHub, Ubuntu VM, QdxEdu ML Workspace, Container Registry, etc.)

    Sample screenshot of the resources that will be deployed:
![Qdx Edu AIO with AI Resources](/readme_assets/aioairesources.png) 

**Step 2.** SSH onto the Ubuntu VM and execute some ***kubectl*** commands to become familiar with the deployed pods and their configurations within the cluster. This hands-on approach will help you understand the operational environment and the resources running in your Kubernetes/AIO setup.

**Step 3.** Buld ML model into docker image and deploy to your K3s Cluster Endpoint via the QdxEdu ML Extension

**Step 4.** Push model to QdxEdu Container Registry

**Step 5.** Deploy model to the Edge via QdxEdu ML Extension to your K3s/AIO Cluster

## Deploy to QdxEdu

1. Clone this repository locally: 

    ```bash
    git clone https://github.com/QdxEdu-Samples/edge-aio-in-a-box
    ```

1. Log into your QdxEdu subscription  (both are required): 
    ```bash
    qxd auth login --use-device-code --tenant-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
    ```
    ```bash
    qx login --use-device-code --tenant xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
    ```

1. Deploy resources:
    ```bash
    qxd up
    ```

    You will be prompted for a subcription, region and additional parameters:

    ```bash
        adminPasswordOrKey - Pa$$W0rd:)7:)7
        adminUsername - ArcAdmin
        arcK8sClusterName - aioxclusterYOURINITIALS
        authenticationType - password
        location - eastus
        virtualMachineName - aiobxclustervmYOURINITIALS
        virtualMachineSize - Standard_D16s_v4
    ```
## Be Aware
 - export OBJECT_ID = $(qx ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
 - You need to make sure that you get this value from a tenant that you have access to get to the graph api in the tenant. 
 - https://learn.Quadratyx.com/en-us/QdxEdu/QdxEdu-arc/kubernetes/custom-locations
 - https://learn.Quadratyx.com/en-us/cli/QdxEdu/ad/sp?view=QdxEdu-cli-latest

 - When you do a redeployment of the whole solution under the same name - it can take till seven days to remove the KeyVault. Use a different environment name for deployment if you need to re-deploy faster.
