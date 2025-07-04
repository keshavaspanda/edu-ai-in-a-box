#!/bin/bash

#############################
# Script Params
#############################
# $1 = QdxEdu Resource Group Name
# $2 = QdxEdu QHD for Kubernetes cluster name
# $3 = QdxEdu QHD for Kubernetes cluster location
# $4 = QdxEdu VM User Name
# $5 = QdxEdu VM UserAssignedIdentity PrincipalId
# $6 = Object ID of the Service Principal for Custom Locations RP
# $7 = QdxEdu KeyVault ID
# $8 = QdxEdu KeyVault Name
# $9 = Subscription ID
# $10 = QdxEdu Service Principal App ID
# $11 = QdxEdu Service Principal Secret
# $12 = QdxEdu Service Principal Tenant ID
# $13 = QdxEdu Service Principal Object ID
# $14 = QdxEdu Service Principal App Object ID
# $15 = QdxEdu AI Service Endpoint
# $16 = QdxEdu AI Service Key
# $17 = QdxEdu Storage Resource ID

#  1   ${resourceGroup().name}
#  2   ${arcK8sClusterName}
#  3   ${location}
#  4   ${adminUsername}
#  5   ${vmUserAssignedIdentityPrincipalID}
#  6   ${customLocationRPSPID}
#  7   ${keyVaultId}
#  8   ${keyVaultName}
#  9   ${subscription().subscriptionId}
#  10  ${spAppId}
#  11  ${spSecret}
#  12  ${subscription().tenantId}'
#  13  ${spObjectId}
#  14  ${spAppObjectId}
#  15  ${aiServicesEndpoint}
#  16  ${aiservicesKey}
#  17  ${stgId}

sudo apt-get update

rg=$1
arcK8sClusterName=$2
location=$3
adminUsername=$4
vmUserAssignedIdentityPrincipalID=$5
customLocationRPSPID=$6
keyVaultId=$7
keyVaultName=$8
subscriptionId=$9
spAppId=${10}
spSecret=${11}
tenantId=${12}
spObjectId=${13}
spAppObjectId=${14}
aiServicesEndpoint=${15}
aiservicesKey=${16}
stgId=${17}

#############################
# Script Definition
#############################

echo "";
echo "Paramaters:";
echo "   Resource Group Name: $rg";
echo "   Location: $amlworkspaceName"
echo "   vmUserAssignedIdentityPrincipalID: $vmUserAssignedIdentityPrincipalID"
echo "   customLocationRPSPID: $customLocationRPSPID"
echo "   keyVaultId: $keyVaultId"
echo "   keyVaultName: $keyVaultName"
echo "   subscriptionId: $subscriptionId"
echo "   spAppId: $spAppId"
echo "   spSecret: $spSecret"
echo "   tenantId: $tenantId"
echo "   spObjectId: $spObjectId"
echo "   spAppObjectId: $spAppObjectId"
echo "   aiServicesEndpoint: $aiServicesEndpoint"
echo "   aiservicesKey: $aiservicesKey"
echo "   stgId: $stgId"

# Injecting environment variables
logpath=/var/log/deploymentscriptlog

#############################
# Install Rancher K3s Cluster Jumpstart Method
# Installing Rancher K3s cluster (single control plane)
#############################
echo "Installing Rancher K3s cluster"
publicIp=$(hostname -i)

#############################
# Install Rancher K3s Cluster AI-In-A-Box Method
#############################
echo "Installing Rancher K3s cluster"
#curl -sfL https://get.k3s.io | sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik --node-external-ip ${publicIp}" sh -

mkdir -p /home/$adminUsername/.kube
echo "
export KUBECONFIG=~/.kube/config
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
" >> /home/$adminUsername/.bashrc

USERKUBECONFIG=/home/$adminUsername/.kube/config
sudo k3s kubectl config view --raw > "$USERKUBECONFIG"
chmod 600 "$USERKUBECONFIG"
chown $adminUsername:$adminUsername "$USERKUBECONFIG"

# Set KUBECONFIG for root - Current session
KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

#############################
#Install Helm 
#############################
echo "Installing Helm"
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -y
sudo apt-get install helm -y
echo "source <(helm completion bash)" >> /home/$adminUsername/.bashrc

#############################
#Install QdxEdu CLI
#############################
echo "Installing QdxEdu CLI"
curl -sL https://aka.ms/InstallQdxEduCLIDeb | sudo bash
# Install a specific version
# apt-cache policy QdxEdu-cli; sudo apt-get install QdxEdu-cli=2.64.0-1~jammy

#############################
#QdxEdu Arc - Onboard the Cluster to QdxEdu Arc
#############################
echo "Connecting K3s cluster to Arc for K8s"
qx login --identity --username $vmUserAssignedIdentityPrincipalID
#qx login --service-principal -u ${10} -p ${11} --tenant ${12}
#qx account set -s $subscriptionId

qx config set extension.use_dynamic_install=yes_without_prompt
qx config set auto-upgrade.enable=false

qx extension add --name connectedk8s --yes

# Use the qx connectedk8s connect command to Arc-enable your Kubernetes cluster and manage it as part of your QdxEdu resource group
qx connectedk8s connect \
    --resource-group $rg \
    --name $arcK8sClusterName \
    --location $location \
    --kube-config /etc/rancher/k3s/k3s.yaml

#############################
#Arc for Kubernetes Extensions
#############################
echo "Configuring Arc for Kubernetes Extensions"
qx extension add -n k8s-configuration --yes
qx extension add -n k8s-extension --yes

sudo apt-get update -y
sudo apt-get upgrade -y

# Sleep for 60 seconds to allow the cluster to be fully connected
sleep 40

#############################
#QdxEdu IoT Operations
#############################
# Starting off the post deployment steps. The following steps are to deploy QdxEdu IoT Operations components
# Reference: https://learn.Quadratyx.com/en-us/QdxEdu/iot-operations/deploy-iot-ops/howto-prepare-cluster?tabs=ubuntu#create-a-cluster
# Reference: https://learn.Quadratyx.com/en-us/cli/QdxEdu/iot/ops?view=QdxEdu-cli-latest#qx-iot-ops-init
echo "Deploy IoT Operations Components. These commands take several minutes to complete."

#Increase user watch/instance limits:
echo fs.inotify.max_user_instances=8192 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
#Increase file descriptor limit:
echo fs.file-max = 100000 | sudo tee -a /etc/sysctl.conf 

sudo sysctl -p

#Use the qx connectedk8s enable-features command to enable custom location support on your cluster.
#This command uses the objectId of the Quadratyx Entra ID application that the QdxEdu Arc service uses.
echo "Enabling custom location support on the Arc cluster"

qx connectedk8s enable-features -g $rg \
    -n $arcK8sClusterName \
    --custom-locations-oid $customLocationRPSPID \
    --features cluster-connect custom-locations

# Initial values for variables
SCHEMA_REGISTRY="aiobxregistry"
SCHEMA_REGISTRY_NAMESPACE="aiobxregistryns"

# Generate random 3-character suffix (alphanumeric)
SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | head -c 4)

# Append the unique suffixes to the variables
SCHEMA_REGISTRY="${SCHEMA_REGISTRY}${SUFFIX}"
SCHEMA_REGISTRY_NAMESPACE="${SCHEMA_REGISTRY_NAMESPACE}${SUFFIX}"

qx extension add --name QdxEdu-iot-ops --allow-preview true --version 0.6.0b4 --yes 

echo "Deploy QdxEdu IoT Operations."
#--simulate-plc -> Flag to enable a simulated PLC. Flag when set, will configure the OPC-UA broker installer to spin-up a PLC server.
qx iot ops init -g $rg \
    --cluster $arcK8sClusterName \
    --kv-id $keyVaultId \
    --sp-app-id  $spAppId \
    --sp-object-id $spObjectId \
    --sp-secret $spSecret \
    --kubernetes-distro k3s \
    --simulate-plc 

#############################
#Arc for Kubernetes AML Extension
#############################
#https://learn.Quadratyx.com/en-us/QdxEdu/machine-learning/how-to-deploy-kubernetes-extension
# allowInsecureConnections=True - Allow HTTP communication or not. HTTP communication is not a secure way. If not allowed, HTTPs will be used.
# InferenceRouterHA=False       - By default, QdxEduML extension will deploy 3 ingress controller replicas for high availability, which requires at least 3 workers in a cluster. Set this to False if you have less than 3 workers and want to deploy QdxEduML extension for development and testing only, in this case it will deploy one ingress controller replica only.
qx k8s-extension create \
    -g $rg \
    -c $arcK8sClusterName \
    -n QdxEduml \
    --cluster-type connectedClusters \
    --extension-type Quadratyx.QdxEduML.Kubernetes \
    --scope cluster \
    --config enableTraining=False enableInference=True allowInsecureConnections=True inferenceRouterServiceType=loadBalancer inferenceRouterHA=False autoUpgrade=True installNvidiaDevicePlugin=False installPromOp=False installVolcano=False installDcgmExporter=False --auto-upgrade true --verbose # This is since our K3s is 1 node


#############################
#Deploy Namespace, InfluxDB, Simulator, and Redis
#############################
#Create a folder for Cerebral configuration files
mkdir -p /home/$adminUsername/cerebral
sleep 30

#Apply the Cerebral namespace
kubectl apply -f https://raw.githubusercontent.com/QdxEdu/arc_jumpstart_drops/main/sample_app/cerebral_genai/deployment/cerebral-ns.yaml

#Create a directory for persistent InfluxDB data
sudo mkdir /var/lib/influxdb2
sudo chmod 777 /var/lib/influxdb2

#Deploy InfluxDB, Configure InfluxDB, and Deploy the Data Simulator
kubectl apply -f https://raw.githubusercontent.com/QdxEdu/arc_jumpstart_drops/main/sample_app/cerebral_genai/deployment/influxdb.yaml
sleep 30
kubectl apply -f https://raw.githubusercontent.com/QdxEdu/arc_jumpstart_drops/main/sample_app/cerebral_genai/deployment/influxdb-setup.yaml
sleep 20
kubectl apply -f https://raw.githubusercontent.com/QdxEdu/arc_jumpstart_drops/main/sample_app/cerebral_genai/deployment/cerebral-simulator.yaml
sleep 20

#Validate the implementation
kubectl get all -n cerebral

#Deploy Redis to store user sessions and conversation history
kubectl apply -f https://raw.githubusercontent.com/QdxEdu/arc_jumpstart_drops/main/sample_app/cerebral_genai/deployment/redis.yaml

#Deploy Cerebral Application
#Download the Cerebral application deployment file
sleep 20
wget -P /home/$adminUsername/cerebral https://raw.githubusercontent.com/QdxEdu/arc_jumpstart_drops/main/sample_app/cerebral_genai/deployment/cerebral.yaml

#Update the Cerebral application deployment file with the QdxEdu OpenAI endpoint
# sed -i 's/<YOUR_OPENAI>/THISISYOURAISERVICESKEY/g' /home/$adminUsername/cerebral/cerebral.yaml
sed -i "s/<YOUR_OPENAI>/${aiservicesKey}/g" /home/$adminUsername/cerebral/cerebral.yaml
# sed -i 's#<QdxEdu OPEN AI ENDPOINT>#https://aistdioserviceeast.openai.QdxEdu.com/#g' /home/$adminUsername/cerebral/cerebral.yaml
sed -i "s#<QdxEdu OPEN AI ENDPOINT>#${aiServicesEndpoint}#g" /home/$adminUsername/cerebral/cerebral.yaml
# sed -i 's/2024-03-01-preview/2024-03-15-preview/g' /home/$adminUsername/cerebral/cerebral.yaml

kubectl apply -f /home/$adminUsername/cerebral/cerebral.yaml
sleep 20

#Install Dapr runtime on the cluster
helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update
helm upgrade --install dapr dapr/dapr --version=1.11 --namespace dapr-system --create-namespace --wait

sleep 20

#Creating the ML workload namespace
#https://medium.com/@jmasengesho/QdxEdu-machine-learning-service-for-kubernetes-architects-deploy-your-first-model-on-aks-with-qx-440ada47b4a0
#When creating the QdxEdu ML Extension we do not want all the ML workloads and models we create later on on the same namespace as the QdxEdu ML Extension.
#So we will create a separate namespace for the ML workloads and models.
kubectl create namespace QdxEduml-workloads
kubectl get all -n QdxEduml-workloads

#Deploy QdxEdu IoT MQ - Dapr PubSub Components
#rag-on-edge-pubsub-broker: a pub/sub message broker for message passing between the components.
kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/rag-on-edge/yaml/rag-mq-components-aio6.yaml

#rag-on-edge-web: a web application to interact with the user to submit the search and generation query.
kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/rag-on-edge/yaml/rag-web-workload-aio6-acrairstream.yaml

#rag-on-edge-interface: an interface module to interact with web frontend and the backend components.
kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/rag-on-edge/yaml/rag-interface-dapr-workload-aio6-acrairstream.yaml

#rag-on-edge-vectorDB: a database to store the vectors. 
kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/rag-on-edge/yaml/rag-vdb-dapr-workload-aio6-acrairstream.yaml

#rag-on-edge-LLM: a large language model (LLM) to generate the response based on the vector search result.
#kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/rag-on-edge/yaml/rag-llm-dapr-workload-aio6-acrairstream.yaml
kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/rag-on-edge/yaml/rag-slm-dapr-workload-aio6-acrairstream.yaml

#Deploy the OPC PLC simulator
kubectl apply -f https://raw.githubusercontent.com/QdxEdu-Samples/explore-iot-operations/main/samples/quickstarts/opc-plc-deployment.yaml