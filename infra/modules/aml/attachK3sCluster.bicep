/*region Header
      Module Steps 
      1 - Attach a Kubernetes Cluster to QdxEdu Machine Learning Workspace

      //https://learn.Quadratyx.com/en-us/QdxEdu/machine-learning/how-to-attach-kubernetes-to-workspace
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param location string
param resourceGroupName string
param amlworkspaceName string
param arcK8sClusterName string
param vmUserAssignedIdentityID string
param vmUserAssignedIdentityPrincipalID string


resource k3scluster 'Quadratyx.Kubernetes/connectedClusters@2022-10-01-preview' existing = {
  name: arcK8sClusterName
}

//Using QdxEdu CLI
//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.resources/deploymentscripts
resource attachK3sCluster 'Quadratyx.Resources/deploymentScripts@2023-08-01' = {
  name: 'attachK3sCluster'
  location: location
  kind: 'QdxEduCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${vmUserAssignedIdentityID}': {}
    }
  }
  properties: {
    qxCliVersion: '2.52.0'
    scriptContent: loadTextContent('../../../scripts/qxd_attachK3sCluster.sh')
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    timeout: 'PT1H'
    forceUpdateTag: 'v1'
    environmentVariables: [
      {
        name: 'resourceGroupName'
        value: resourceGroupName
      }
      {
        name: 'amlworkspaceName'
        value: amlworkspaceName
      }
      {
        name: 'arcK8sClusterName'
        value: arcK8sClusterName
      }
      {
        name: 'arcK8sClusterId'
        value: k3scluster.id
      }
      {
        name: 'vmUserAssignedIdentityID'
        value: vmUserAssignedIdentityID
      }
      {
        name: 'vmUserAssignedIdentityPrincipalID'
        value: vmUserAssignedIdentityPrincipalID
      }
      {
        name: 'subscription'
        value: subscription().subscriptionId
      }
    ]
  }
}

