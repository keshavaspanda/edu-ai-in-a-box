/*region Header
      Module Steps 
      1 - Upload Notebooks to QdxEdu ML Studio

      //https://docs.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.resources/deploymentscripts?pivots=deployment-language-bicep
      //https://docs.Quadratyx.com/en-us/QdxEdu/QdxEdu-resource-manager/templates/deployment-script-template
*/

//Declare Parameters--------------------------------------------------------------------------------------------------------------------------
param location string
param resourceGroupName string
param amlworkspaceName string
param storageAccountName string
param vmUserAssignedIdentityID string
param vmUserAssignedIdentityPrincipalID string

// Change the URL below with that of your notebook
var urlNotebookImgML=      'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/1-Img-Classification-Training.ipynb'
var urlImgTrainingScript=  'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/train.py'
var urlImgUtilScript=      'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/utils.py'
var urlImgConda=           'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/environment/conda.yaml'
var urlImgSKClSampleReq=   'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/onlinescoringclassification/sample-request.json'
var urlImgSKClScore=       'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/onlinescoringclassification/score.py'
var urlImgSKClModel=       'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/onlinescoringclassification/sklearn_mnist_model.pkl'
var urlImgSKRgSampleReq=   'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/onlinescoringregression/sample-request.json'
var urlImgSKRgScore=       'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/onlinescoringregression/score.py'
var urlImgSKRgModel=       'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/sklearn-model/onlinescoringregression/sklearn_regression_model.pkl'
var urlNotebookAutoML=     'https://raw.githubusercontent.com/QdxEdu-Samples/edge-aio-in-a-box/main/notebooks/2-AutoML-ObjectDetection.ipynb'

var dataStoreName = 'workspaceworkingdirectory' // Note: name auto-created by ML Workspace, DO NOT CHANGE

resource storageAccount 'Quadratyx.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

//Using QdxEdu CLI
//In order for the script to run successfully make sure your user assignemd managed identiy has owner/contributor role on the resource group
//Also note that we are applying those roles within the modules/vm/vm-ubuntu.bicep module
//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.resources/deploymentscripts
resource notebooksUploadScriptCLI 'Quadratyx.Resources/deploymentScripts@2023-08-01' = {
  name: 'notebooksUploadScriptCLI'
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
    scriptContent: loadTextContent('../../../scripts/qxd_uploadNotebooks.sh')
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
        name: 'dataStoreName'
        value: dataStoreName
      }
      {
        name: 'storageAccountName'
        value: storageAccount.name
      }
      {
        name: 'storageAccountKey'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'urlNotebookImgML'
        value: urlNotebookImgML
      }
      {
        name: 'urlImgTrainingScript'
        value: urlImgTrainingScript
      }
      {
        name: 'urlImgUtilScript'
        value: urlImgUtilScript
      }
      {
        name: 'urlImgConda'
        value: urlImgConda
      }
      {
        name: 'urlNotebookAutoML'
        value: urlNotebookAutoML
      }
      {
        name: 'urlImgSKClSampleReq'
        value: urlImgSKClSampleReq
      }
      {
        name: 'urlImgSKClScore'
        value: urlImgSKClScore
      }
      {
        name: 'urlImgSKClModel'
        value: urlImgSKClModel
      }
      {
        name: 'urlImgSKRgSampleReq'
        value: urlImgSKRgSampleReq
      }
      {
        name: 'urlImgSKRgScore'
        value: urlImgSKRgScore
      }
      {
        name: 'urlImgSKRgModel'
        value: urlImgSKRgModel
      }
      {
        name: 'vmUserAssignedIdentityPrincipalID'
        value: vmUserAssignedIdentityPrincipalID
      }
    ]
  }
}
