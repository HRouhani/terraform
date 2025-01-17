resource "null_resource" "configmap2" {
  depends_on = [
    module.eks
  ]
  provisioner "local-exec" {
    command = "sleep 10; aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) --kubeconfig ./kubeconfig; export KUBECONFIG='kubeconfig'; kubectl create namespace security-team; kubectl apply -f service-account.yaml ; kubectl apply -f pod-cnspec.yaml; kubectl apply -f aws-vote-backend.yaml; kubectl apply -f aws-vote-fronend.yaml; kubectl apply -f roles.yaml; kubectl apply -f roleBinding.yaml; aws ec2 create-route --route-table-id '${module.vpc.private_route_table_ids[0]}' --destination-cidr-block '${chomp(data.http.myip.response_body)}/32' --gateway-id '${module.vpc.igw_id}'; kubectl label --overwrite ns security-team pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns kube-system pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns default pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns kube-public pod-security.kubernetes.io/enforce=restricted; kubectl label --overwrite ns kube-node-lease pod-security.kubernetes.io/enforce=restricted"
  }

}


resource "aws_ecr_repository" "security-team-ecr" {
  name                 = "security-team-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}