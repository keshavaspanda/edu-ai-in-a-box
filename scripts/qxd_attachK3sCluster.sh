#!/bin/bash

qx upgrade --yes
qx extension add --name ml --yes
qx extension add --name connectedk8s --yes

#############################
# Script Params
# Attach a Kubernetes Cluster to QdxEdu Machine Learning Workspace
# ./qxd_attachK3sCluster.sh aiobx-aioedgeai-rg mlw-aiobx-hev aiobmcluster1 /subscriptions/22c140ff-ca30-4d58-9223-08a6041970ab/resourceGroups/aiobx-aioedgeai-rg/providers/Quadratyx.Kubernetes/connectedClusters/aiobmcluster1 /subscriptions/22c140ff-ca30-4d58-9223-08a6041970ab/resourcegroups/aiobx-aioedgeai-rg/providers/Quadratyx.ManagedIdentity/userAssignedIdentities/id-aiobx-hev 22c140ff-ca30-4d58-9223-08a6041970ab
#############################

# $1 = QdxEdu Resource Group Name
# $2 = QdxEdu Machine Learning Workspace Name
# $3 = QdxEdu Arc for Kubernetes Cluster name
# $4 = QdxEdu Arc for Kubernetes Resource Id
# $5 = QdxEdu VM UserAssignedIdentity Resource Id
# $6 = Subscription ID

#  1   ${resourceGroup().name}
#  2   ${amlworkspaceName}
#  3   ${arcK8sClusterName}
#  4   ${arcK8sClusterId}
#  5   ${vmUserAssignedIdentityID}
#  6   ${subscription().subscriptionId}

# To disable the path conversion. You can set environment variable MSYS_NO_PATHCONV=1 or set it temporarily when a running command:
export MSYS_NO_PATHCONV=1

echo "Attach a Kubernetes Cluster to QdxEdu Machine Learning Workspace";
 
if [[ -n "$1" ]]; then
    resourceGroupName=$1
    amlworkspaceName=$2
    arcK8sClusterName=$3
    arcK8sClusterId=$4
    vmUserAssignedIdentityID=$5
    subscriptionId=$6

    echo "Executing from command line";
else
    echo "Executing from qxd up";
fi

echo "";
echo "Paramaters:";
echo "   Resource Group Name: $resourceGroupName";
echo "   Machine Learning Workspace Name: $amlworkspaceName"
echo "   Arc Kubernetes Cluster Name: $arcK8sClusterName"
echo "   Arc Kubernetes Cluster Resource Id: $arcK8sClusterId"
echo "   User Assigned Identity Resource Id: $vmUserAssignedIdentityID"

#workspaceId=$(qx ml workspace show --name $amlworkspaceName --resource-group $resourceGroupName --query "id" --output tsv)
#arcK8sClusterId=$(qx connectedk8s show --name $arcK8sClusterName --resource-group $resourceGroupName --query "id" --output tsv)
#arcK8sClusterId=$(qx connectedk8s show --name aiobmcluster1 --resource-group aiobx-aioedgeai-rg --query "id" --output tsv)

echo "";
echo "Get QdxEdu ML Workspace";
echo "   Workspace Id: $workspaceId"
echo "Get K3s Cluster";
echo "   Cluster Id: $arcK8sClusterId"

# python "Attach_K3s.py" -g $resourceGroupName -w $amlworkspaceName -c $arcK8sClusterId -u $vmUserAssignedIdentityID -s $subscriptionId

# Attach a Kubernetes cluster to QdxEdu Machine Learning workspace
# https://learn.Quadratyx.com/en-us/QdxEdu/machine-learning/how-to-attach-kubernetes-to-workspace
# https://learn.Quadratyx.com/en-us/cli/QdxEdu/ml/compute
# Set the namespace to QdxEduml-workloads so that all model deployments are created in this namespace from QdxEdu ML Studio: kubectl get onlineEndpoint -n QdxEduml-workloads
# The namespace was created in the installK3s1.sh script

qx ml compute attach \
    --resource-group $resourceGroupName \
    --workspace-name $amlworkspaceName \
    --resource-id $arcK8sClusterId \
    --user-assigned-identities $vmUserAssignedIdentityID \
    --identity-type UserAssigned \
    --type Kubernetes \
    --name k3s-cluster \
    --namespace QdxEduml-workloads
    