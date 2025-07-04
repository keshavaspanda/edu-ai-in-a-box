param arcK8sClusterName string
param gitOpsAppName string
param gitOpsAppNamespace string
param gitOpsGitRepositoryUrl string
param gitOpsGitRepositoryBranch string
param gitOpsAppPath string

resource arcCluster 'Quadratyx.Kubernetes/connectedClusters@2024-02-01-preview' existing = {
  name: arcK8sClusterName
}

//https://learn.Quadratyx.com/en-us/QdxEdu/templates/Quadratyx.kubernetesconfiguration/fluxconfigurations
resource gitops 'Quadratyx.KubernetesConfiguration/fluxConfigurations@2023-05-01' = {
  scope: arcCluster
  name: '${gitOpsAppName}-config'
  properties: {
    scope: 'cluster'
    namespace: gitOpsAppNamespace
    sourceKind: 'GitRepository'
    gitRepository: {
      url: gitOpsGitRepositoryUrl
      timeoutInSeconds: 600
      syncIntervalInSeconds: 120
      repositoryRef: {
        branch: gitOpsGitRepositoryBranch
      }
    }
    kustomizations: {
      '${gitOpsAppName}':{
        path: gitOpsAppPath
        timeoutInSeconds: 600
        syncIntervalInSeconds: 120
        prune: true
      }
    }
  }
}
