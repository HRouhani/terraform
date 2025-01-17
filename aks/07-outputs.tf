
# Resource Group Outputs
output "location" {
  value = azurerm_resource_group.security-rg-aks.location
}

output "resource_group_id" {
  value = azurerm_resource_group.security-rg-aks.id
}

output "resource_group_name" {
  value = azurerm_resource_group.security-rg-aks.name
}

output "node_resource_group" {
  value = "${azurerm_resource_group.security-rg-aks.name}-nrg"
}


# Azure AKS Versions Datasource
output "versions" {
  value = data.azurerm_kubernetes_service_versions.current.versions
}

output "latest_version" {
  value = data.azurerm_kubernetes_service_versions.current.latest_version
}

# Azure AD Group Object Id
output "azure_ad_group_id" {
  value = azuread_group.aks_administrators.id
}
output "azure_ad_group_objectid" {
  value = azuread_group.aks_administrators.object_id
}


# Azure AKS Outputs

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_cluster_kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}

output "tls_private_key" {
  #value     = tls_private_key.attacker_vm_ssh.private_key_pem
  value     = tls_private_key.vm_ssh.private_key_pem
  sensitive = true
}

output "summary" {
  value = <<EOT

The kubeconfig file will be created automatically for you, and will be exported automatically to your environment. 

In case you have problem with kubectl command, export it one more time:

export KUBECONFIG='kubeconfig'

If other colleagues also want to use the same cluster for testing:

Send him/her kubeconfig file, and ask her to do the following in the terminal:

    ***  export KUBECONFIG=./kubeconfig



To find the Public IP address of the worker node(s), we need to first get the name of the Virtual Machine Scale Set


      ***  az vmss list -g "${azurerm_resource_group.security-rg-aks.name}-nrg" | grep name


The name should be something like "aks-securitypool-xxxxxx-vmss"


and then finding the Public IP addresses:

      *** kubectl describe node <SCALE-SET-NAME> | grep IP



To do the ssh to the worker node: (create the Private Key)

      *** terraform output -raw tls_private_key > id_rsa
          chmod 600 id_rsa
          ssh  -i id_rsa ubuntu@<pUblic-IPadd>

          if got "Too many authentication failures" try this --> ssh -o IdentitiesOnly=yes -i id_rsa ubuntu@<pUblic-IPadd>


At the end for testing the Policy Bundle:

      # Worker node related tests:

      *** ./cnspec-8.23.2 scan ssh -i id_rsa ubuntu@X.X.X.X --policy-bundle azure-aks.mql.yaml 


      # Cluster related tests:

      *** ./cnspec-8.23.2 scan k8s --policy-bundle azure-aks.mql.yaml --namespaces-exclude kube-system,kube-node-lease,kube-public --discover clusters


Cnspec has been installed on one of the pod, which you can connect and test some policies directly on the worker node:

      ***  kubectl -n security-team exec cnspec -it -- /bin/sh
           cnspec shell filesystem --path /mnt/host/



To make some tests pass following manual procedure is needed:



1     1) create a config file in /var/lib/kubelet/ directory of the worker node we are testing: (otherwise 2 tests will be skipped)

          *** ssh  -i id_rsa ubuntu@pUblic-IPadd
          sudo -i
          touch /var/lib/kubelet/kubelet-config.json


      2) Run following to add lables - related to Policy Security Standards part:

         # kubectl label --overwrite ns security-team pod-security.kubernetes.io/enforce=baseline; kubectl label --overwrite ns kube-system pod-security.kubernetes.io/enforce=baseline; kubectl label --overwrite ns default pod-security.kubernetes.io/enforce=baseline; kubectl label --overwrite ns kube-public pod-security.kubernetes.io/enforce=baseline; kubectl label --overwrite ns kube-node-lease pod-security.kubernetes.io/enforce=baseline; kubectl label --overwrite ns gatekeeper-system pod-security.kubernetes.io/enforce=baseline
         # kubectl label --overwrite ns security-team pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns kube-system pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns default pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns kube-public pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns kube-node-lease pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns gatekeeper-system pod-security.kubernetes.io/enforce=restricted



EOT
}



