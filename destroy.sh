### Helm Charts Releases
NAMESPACE=totem-apps

. ./helm_chart_delete_release.sh --release totem --namespace $NAMESPACE
. ./helm_chart_delete_release.sh --release payment --namespace $NAMESPACE
. ./helm_chart_delete_release.sh --release mailhog --namespace $NAMESPACE
. ./helm_chart_delete_release.sh --release mongo --namespace $NAMESPACE


### Destroy Terraform

### Terraform dir
### Terraform dir
TERRAFORM_COMPONENTS_DIR=../totem-food-service-tf-module-components
TERRAFORM_INTEGRATION_DIR=../totem-food-service-tf-module-integration-api-gateway-and-eks

terraform -chdir=$TERRAFORM_INTEGRATION_DIR destroy
terraform -chdir=$TERRAFORM_COMPONENTS_DIR destroy


HELM_STATE_DIR=./helm_state
EKS_STATE_DIR=./eks_state

rm -rf $HELM_STATE_DIR/*.txt
rm -rf $EKS_STATE_DIR/*.txt




