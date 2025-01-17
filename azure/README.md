# Azure Terraform Deployment

## Apply terraform

- Please Do not forget to Destroy everything at the end, as this files will activate almost everything in azure!

- Important 1

  The Terraform should know the Subscription ID of the tenant which we want to deploy our cluster. There are 2 ways of doing that:

  a. Copy past the subscription ID in the terraform.tfvars!

  b. Do it through env variable as follow:
     
     export TF_VAR_subscription="f........................"


- Important 2

  There are some variables which need to be filled in terraform.tfvars!


- deploy infra

```bash
terraform init 
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

- get the ssh private key for VM login which in this test the ssh port 22 is not Open, so can be ignored!

```bash
terraform output -raw tls_private_key > id_rsa
```

- change permissions of the ssh private key

```bash
chmod 600 id_rsa
```

- get the ssh command

```bash
terraform output
```

## destroy infra

```bash
terraform destroy -auto-approve
```


### Still failling on pass

**✕ Fail:  F   0  Ensure that logging for Azure Key Vault is 'Enabled'**

**✕ Fail:  D  20  Ensure That 'All users with the following roles' is set to 'Owner'**

**✕ Fail:  D  20  Ensure 'Infrastructure double encryption' for PostgreSQL Database Server is 'Enabled'**

**✕ Fail:  D  20  Ensure that 'Public access level' is disabled for storage accounts with blob containers**

**✕ Fail:  D  20  Ensure that SKU Basic/Consumption is not used on artifacts that need to be monitored (Particularly for Production Workloads)**

**✕ Fail:  C  40  Ensure Storage logging is Enabled for Blob Service for 'Read', 'Write', and 'Delete' requests**

**✕ Fail:  C  40  Ensure That 'Notify about alerts with the following severity' is Set to 'High'**

**✕ Fail:  C  40  Ensure That 'Firewalls & Networks' Is Limited to Use Selected Networks Instead of All Networks**

**✕ Fail:  C  40  Ensure Storage Logging is Enabled for Table Service for 'Read', 'Write', and 'Delete' Requests**

**✕ Fail:  D  20  Ensure that Auto provisioning of 'Log Analytics agent for Azure VMs' is Set to 'On'**
