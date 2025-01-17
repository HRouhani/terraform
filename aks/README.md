
login with az command to the azure platform (we tested on "k8s Operator Dev" subscription by azuremondoo.onmicrosoft.com account which automatically will choose the k8s subscription)

```
az login
```

**Then terraform commands**

```
terraform init
terraform apply -auto-approve
```


**at the end, please**

```
terraform destroy -auto-approve
```



The code will create a sample multi-container application with a web front-end and a Redis instance in the cluster.
we have used partially the code from Microsoft (https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?tabs=azure-cli)