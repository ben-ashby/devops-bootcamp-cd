.PHONY: bootstrap kube-create-cluster kube-secret kube-delete-cluster kube-deploy-cluster kube-validate kube-config \
namespace-up namespace-down ssh-gen

bootstrap:
	cd bootstrap && terraform init
	cd bootstrap && terraform apply --auto-approve

########
# KOPS
########

kube-create-cluster:
	kops create cluster --state=s3://$(shell cd bootstrap && terraform output kops_state_bucket_name) --name=bootcamp.k8s.local --zones="ap-southeast-2a,ap-southeast-2b" --master-size=t2.small --node-size=t2.small --node-count=1 --yes

kube-secret:
	kops create secret --state=s3://$(shell cd bootstrap && terraform output kops_state_bucket_name) --name bootcamp.k8s.local sshpublickey admin -i ~/.ssh/personal/id_rsa.pub

kube-delete-cluster:
	aws iam detach-role-policy --role-name nodes.bootcamp.k8s.local --policy-arn arn:aws:iam::aws:policy/AdministratorAccess | echo "hack"
	kops delete cluster --state=s3://$(shell cd bootstrap && terraform output kops_state_bucket_name) bootcamp.k8s.local --yes

kube-deploy-cluster:
	kops update cluster --state=s3://$(shell cd bootstrap && terraform output kops_state_bucket_name) bootcamp.k8s.local --yes
	aws iam attach-role-policy --role-name nodes.bootcamp.k8s.local --policy-arn arn:aws:iam::aws:policy/AdministratorAccess | echo "Hack"

kube-validate:
	kops validate cluster --state=s3://$(shell cd bootstrap && terraform output kops_state_bucket_name)

kube-config:
	kops export kubecfg --state=s3://$(shell cd bootstrap && terraform output kops_state_bucket_name)

#######
# Kubernetes
#######


namespace-up:
	kubectl create namespace test
	kubectl create namespace prod

namespace-down:
	kubectl delete namespace prod
	kubectl delete namespace test

logging-up:
	kubectl apply -f logging/cloudwatch-namespace.yaml
	kubectl apply -f logging/fluentd.yaml

logging-down:
	kubectl delete -f logging/fluentd.yaml
	kubectl delete -f logging/cloudwatch-namespace.yaml 

########
# SSH
########

ssh-gen:
	mkdir -p ~/keys
	yes | ssh-keygen -t rsa -b 4096 -f ~/keys/ec2-key -P ''
	chmod 0644 ~/keys/ec2-key.pub
	chmod 0600 ~/keys/ec2-key