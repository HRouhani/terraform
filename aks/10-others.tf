/* resource "local_file" "kubeconfig" {
  #depends_on   = [azurerm_kubernetes_cluster.cluster]
  depends_on = [ azurerm_kubernetes_cluster.aks_cluster ]
  #filename     = "aks-kubeconfig"
  filename     = "kubeconfig"
  #content      = azurerm_kubernetes_cluster.cluster.kube_config_raw
  content = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
} */


resource "null_resource" "configmap" {
  #depends_on = [ azurerm_kubernetes_cluster.aks_cluster]
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  provisioner "local-exec" {
    #command = 'export KUBECONFIG="${PWD}/kubeconfig"; kubectl create namespace security-team'
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.security-rg-aks.name}  --name '${azurerm_resource_group.security-rg-aks.name}-cluster' --admin --file ./kubeconfig; export KUBECONFIG='kubeconfig'; kubectl create namespace security-team; kubectl apply -f service-account.yaml ; kubectl apply -f pod-cnspec.yaml; kubectl apply -f azure-vote-backend.yaml; kubectl apply -f azure-vote-fronend.yaml; kubectl apply -f roles.yaml; kubectl apply -f roleBinding.yaml; kubectl apply -f Deactive.yaml; kubectl apply -f Deactive-Security-account.yaml; kubectl apply -f test-network-policy-security-team.mql.yaml;kubectl apply -f test-network-policy-default.mql.yaml; kubectl label --overwrite ns --all pod-security.kubernetes.io/enforce=restricted"
  }
}

#az security pricing create --name ContainerRegistry --tier Standard