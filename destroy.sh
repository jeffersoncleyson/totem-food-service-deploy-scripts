### Helm Charts Releases
NAMESPACE=totem-apps

TOTEM_FOOD_RELEASE_NAME=customer
PAYMENT_RELEASE_NAME=payment
MAILHOG_RELEASE_NAME=mailhog
MONGO_RELEASE_NAME=mongo

. ./helm_chart_delete_release.sh --release $TOTEM_FOOD_RELEASE_NAME --namespace $NAMESPACE
. ./helm_chart_delete_release.sh --release $PAYMENT_RELEASE_NAME --namespace $NAMESPACE
. ./helm_chart_delete_release.sh --release $MAILHOG_RELEASE_NAME --namespace $NAMESPACE
. ./helm_chart_delete_release.sh --release $MONGO_RELEASE_NAME --namespace $NAMESPACE


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




