
**To install aws in Linux**
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


The cluster will be installed by default in eu-central-1 region. If you want to deploy it in different region please change it in varianles.tf file and following commands accordingly.




**You need to have a user in IAM with enough permission**
  
  You can use "security-team" group which has AdministratorAccess permission policies. 
  Go to your user in IAM, then in "Security credentials" part, create Access Keys for the Terminal Access. You need the "Key ID" and "Secret Access Key".




**to connect to AWS through cli:**
```
$ aws configure
AWS Access Key ID [None]: AXXXXXXXXXXXXXXXXXXR
AWS Secret Access Key [None]: CXXXXXXXXXXXXXXXXXXXXXXXXXXXXs
Default region name [None]: eu-centra-1
Default output format [None]: 
hrouhan@hrz aws $ aws iam list-users
```

  > The cluster will be deployed by default in eu-central-1 region which has been configigured in variables.tf

To avoid any unforseen error please export following environmental variable in your terminal before starting with the Terraform
$ export AWS_REGION=eu-central-1

**Then simply initialize the terraform and apply**
```
$ terraform init -upgrade
$ terraform apply -auto-approve
```

**After you are done, please destroy everthing**
```
terraform destroy -auto-approve
```


  > in case the destroy process got stocked which is normal in EKS, try to delete from portal in following order:
      load balancer
      VPC
      network interfaces

**all pods will be deployed in security-team namespace**

  
  > some useful commands

    
    kubectl get pods -A
    
    for deleting any pods, you need to delete the corresponding deployments

    kubectl get deployments -A
    kubectl delete deployment aws-vote-back
    

After deploying the cluster, you might need to check the pods/nodes directly from console (logged with your user). If you had issue for seeing the resources, you might need to do the following (https://stackoverflow.com/questions/70787520/your-current-user-or-role-does-not-have-access-to-kubernetes-objects-on-this-eks)

kubectl edit configmap aws-auth -n kube-system

here is how mine looks like:

```
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::072487201929:role/security-team-iam-role
      username: system:node:{{EC2PrivateDNSName}}
kind: ConfigMap
metadata:
  creationTimestamp: "2023-08-30T18:19:40Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "1024"
  uid: xxxxxxx-xxxxxxxxx-xxxx-xxxxxxxx
```

Then you need to login directly with your IAM user to aws to see the resouces!

Important:

  There are several commands inserted into the 06-others.tf file for fully automation. The commands are partially **aws** commands which for execution/connection are dependent on proper "AWS_REGION" configuration in your terminal. Therefore make sure before running the Terraform commands, the environment variable has been set correctly. 
    > if you forgotten to set it in the first round of the Terraform execution, you need to detroy the cluster and re-create/re-apply it again since the commands in the 06-others.tf file will be executed only One time in cluster creation and not in the minor modification. Another option would be to deploy the commands in the 06-others.tf manually!


It should be noted that so far we could not managed to change any configuration related to worker nodes. It is indeed our top priority to figure it out and be able to configure PASS/FAIL part properly