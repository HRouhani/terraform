

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

/* output "ec2_linux_public_ip" {
  value = <<EOT

  
ssh -o StrictHostKeyChecking=no -i ${var.ssh_key_path} kali@${module.ec2_instance.public_ip}


EOT
}
 */

output "igw_id" {
  value = module.vpc.igw_id
}


output "route_table_id" {
  #value = module.vpc.
  value = module.vpc.private_route_table_ids
}



output "summary" {
  value = <<EOT


***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************




You need the Ec2 Instance id of the Worker node (EC2 Instance), something like "i-0a8e3fe273ca66fd4". If there are some Terminated EC2 instances, you see them as well with the following command which you need to ignore:

      ***  aws ec2 describe-instances | grep -i InstanceId


There are 2 ways to connect to worker nodes (EC2):

      
a. Session Manager
   
   requirements:  To initiate Session Manager sessions with your managed nodes by using the AWS Command Line Interface (AWS CLI), you must install the Session Manager plugin on your local machine.
                   Ubuntu:   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
                             sudo dpkg -i session-manager-plugin.deb 


    ***  aws ssm start-session  --target <EC2 Instance ID>


b. EC2 Connect

    *** aws ec2-instance-connect ssh --instance-id <EC2 Instance ID> 



At the end for testing the Policy Bundle:


      # Worker node related tests:

      *** cnspec scan aws ec2 instance-connect ec2-user@<EC2 Instance ID> --policy-bundle amazon-eks.mql.yaml


      # Kubernetes Cluster related tests:

      *** cnspec scan k8s --policy-bundle amazon-eks.mql.yaml --namespaces-exclude kube-system,kube-node-lease,kube-public --discover clusters


      # aws platform related tests

        *** export AWS_REGION=eu-central-1
            cnspec scan aws --policy-bundle amazon-eks.mql.yaml




cnspec has been installed on one of the pod, which you can connect and test some policies directly on the worker node:

      ***  kubectl -n security-team exec cnspec -it -- /bin/sh
           cnspec shell filesystem /mnt/host/



To make some tests pass:


   1) Ensure that the --read-only-port is disabled

          # vi /etc/kubernetes/kubelet/kubelet-config.json

            The value is there but the cnspec does not show the value! 

    

     2) Ensure that the --hostname-override argument is not set
    
           # vi /etc/systemd/system/kubelet.service.d/10-kubelet-args.conf

           and remove --hostname-override and its value from the KUBELET_ARGS


            Then restart the service: (should not see any error)

              systemctl daemon-reload
              systemctl restart kubelet.service
              systemctl status kubelet -l


    
    3)  Enable audit Logs


      aws eks update-cluster-config --region $(terraform output -raw region) --name $(terraform output -raw cluster_name) --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'

EOT
}