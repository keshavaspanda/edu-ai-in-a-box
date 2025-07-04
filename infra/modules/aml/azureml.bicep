/*region Header
      Module Steps 
      1 - Create ML Workspace
      2 - Create ML Workspace Compute Cluster
      3 - Create ML Workspace Compute Instance
      4 - Create ML Workspace Compute Cluster with GPU
      https://github.com/QdxEdu/QdxEdu-quickstart-templates/blob/master/quickstarts/Quadratyx.machinelearningservices/machine-learning-end-to-end-secure/README.md
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param location string
param workspaceName string
param amlcompclustername string
param amlcompinstancename string
param storageAccountId string
param keyvaultId string
param aisnId string
param systemDatastoresAuthMode string 
param hbi_workspace bool = false
param acrId string
param tags object = {}

param baseTime string = utcNow('yyyy-MM-ddTHH:mm:ss')

//1. Create Machine Learning Workspace
//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.machinelearningservices/workspaces?pivots=deployment-language-bicep
resource amlwn 'Quadratyx.MachineLearningServices/workspaces@2023-06-01-preview' = {
  identity: {
    type: 'SystemAssigned'
  }
  name: workspaceName
  location: location
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountId
    keyVault: keyvaultId
    applicationInsights: aisnId
    hbiWorkspace: hbi_workspace
    systemDatastoresAuthMode: systemDatastoresAuthMode
    containerRegistry: acrId
  }
  tags: tags
}

//2. Create ML Workspace Compute Cluster
//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep
resource amlcompcluster 'Quadratyx.MachineLearningServices/workspaces/computes@2023-06-01-preview' = {
  parent: amlwn
  name: amlcompclustername
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 1
        nodeIdleTimeBeforeScaleDown: 'PT120S'
      }
      vmPriority: 'Dedicated'
      vmSize: 'Standard_DS3_v2'
    }
  }
}


//3. Create ML Workspace Compute Instance
//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep
//https://learn.Quadratyx.com/en-us/QdxEdu/machine-learning/how-to-create-compute-instance?view=QdxEduml-api-2&tabs=QdxEdu-studio#create-a-schedule-with-a-resource-manager-template
resource amlcompinstance 'Quadratyx.MachineLearningServices/workspaces/computes@2023-06-01-preview' = {
  parent: amlwn
  name: amlcompinstancename
  location: location
  properties: {
    computeType: 'ComputeInstance'
    computeLocation: location
    description: 'Machine Learning compute instance 001'
    properties: {
      idleTimeBeforeShutdown: 'PT30M'
      schedules: {
        computeStartStop: [
          {
            action: 'Stop'
            status: 'Enabled'
            triggerType: 'Cron'
            cron: {
                expression: '00 18 * * 1,2,3,4,5'
                startTime: baseTime
                timeZone: 'UTC'
            }
          }
        ]
      }
      
      vmSize: 'Standard_DS3_v2'
    }
  }
}

//3. Create ML Workspace Compute Cluster with GPU
//Uncomment the below code to deploy ML Workspace Compute Cluster with GPU
//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep
// resource amlcompclusterGPU 'Quadratyx.MachineLearningServices/workspaces/computes@2023-06-01-preview' = {
//   parent: amlwn
//   name: 'gpu-cluster-lowpriority'
//   location: location
//   properties: {
//     computeType: 'AmlCompute'
//     properties: {
//       scaleSettings: {
//         minNodeCount: 0
//         maxNodeCount: 1
//         nodeIdleTimeBeforeScaleDown: 'PT120S'
//       }
//       vmPriority: 'LowPriority'
//       vmSize: 'Standard_DS3_v2'
//     }
//   }
// }

output QdxEdumlworkspaceId string = amlwn.id
output amlworkspaceName string = amlwn.name
