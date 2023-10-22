#!/bin/bash

##############################################################################
################### VARIABLES
##############################################################################
APP_NAME="totem-food-service"
ENVIRONMENT="sandbox"
OWNER_TEAM="team-totem-food-service"
REGION=us-east-1
NAMESPACE=totem-apps
MERCADO_PAGO_PAYMENT_GATEWAY=https://api.mercadopago.com
STORE_ID=POSTOTEM001
STORE_USER_ID=1481636739
WHITE_SPACE=@
STORE_TOKEN_ID="\"Bearer${WHITE_SPACE}TEST-TOKEN\""


### AWS Profile if you are using SSO
### In case of AWS credials comment this variable
PROFILE=soat1

### Terraform dir
TERRAFORM_COMPONENTS_DIR=../totem-food-service-tf-module-components
TERRAFORM_INTEGRATION_DIR=../totem-food-service-tf-module-integration-api-gateway-and-eks

### Helm Chart dir
HELM_CHART_DIR=../totem-food-service-helm-chart


##############################################################################
################### AWS SSO
##############################################################################

# echo -e "\n########### SSO Login #####################\n"
# . ./sso_login.sh --profile $PROFILE

##############################################################################
################### TOTEM FOOD SERVICE COMPONENTS - TERRAFORM
##############################################################################

echo -e "\n########### TERRAFORM INIT #####################\n"
cat << EOF > $TERRAFORM_COMPONENTS_DIR/terraform.tfvars.json
{
  "application_name": "$APP_NAME", 
  "environment": "$ENVIRONMENT", 
  "owner_team": "$OWNER_TEAM",
  "region": "$REGION"
}
EOF
. ./terraform-init.sh --dir $TERRAFORM_COMPONENTS_DIR

echo -e "\n########### TERRAFORM PLAN #####################\n"
. ./terraform-plan.sh --dir $TERRAFORM_COMPONENTS_DIR

echo -e "\n########### TERRAFORM APPLY #####################\n"
. ./terraform-apply.sh --dir $TERRAFORM_COMPONENTS_DIR

exit

echo -e "\n########### GETTING VARIABLES FROM TERRAFORM #####################\n"
CLIENT_NAME=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cognito_client_name)
CLIENT_ID=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cognito_client_id)
USER_POOL_ID=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cognito_user_pool_id)
API_GATEWAY_STAGE_URL=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key api_gateway_url)
API_GATEWAY_STAGE_URL_PAYMENT_CALLBACK=$API_GATEWAY_STAGE_URL/v1/totem/payment/callback

echo -e "\n########### GETTING CLIENT SECRET #####################\n"
CLIENT_SECRET=$(. ./cognito_get_client_secret.sh --profile $PROFILE --user-pool-id $USER_POOL_ID --client-name $CLIENT_NAME --client-id $CLIENT_ID)

echo -e "\n########### CONFIGURING KUBE CONTEXT #####################\n"
CLUSTER_NAME=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cluster_eks_name)
. ./add_eks.sh --profile $PROFILE --cluster-name $CLUSTER_NAME

echo -e "\n########### CREATING NAMESPACE #####################\n"
. ./add_namespace.sh --namespace $NAMESPACE

echo -e "\n########### RESTARTING DEPLOYMENT #####################\n"
./restart_deployment.sh -dn coredns -n kube-system

##############################################################################
################### TOTEM FOOD SERVICE - HELM CHART
##############################################################################

echo -e "\n########### RELEASING MICRO SERVICES #####################\n"

MONGO_CHART=mongodb-chart
. ./helm_chart_create_release.sh --release mongo --dir $HELM_CHART_DIR/$MONGO_CHART --namespace $NAMESPACE

MAILHOG_CHART=mailhog-chart
. ./helm_chart_create_release.sh --release mailhog --dir $HELM_CHART_DIR/$MAILHOG_CHART --namespace $NAMESPACE

PAYMENT_GATEWAY_CHART=payment-gateway-chart
. ./helm_chart_create_release.sh --release payment --dir $HELM_CHART_DIR/$PAYMENT_GATEWAY_CHART --namespace $NAMESPACE

TOTEM_FOOD_CHART=totem-food-chart
VALUES_TO_SET=image.tag=temporary,image.pullPolicy=Always,secrets.cognito.userPoolId=$USER_POOL_ID,secrets.cognito.clientId=$CLIENT_ID,secrets.cognito.clientSecret=$CLIENT_SECRET,secrets.payment.gateway.callback=$API_GATEWAY_STAGE_URL_PAYMENT_CALLBACK,secrets.payment.gateway.url=$MERCADO_PAGO_PAYMENT_GATEWAY,secrets.payment.gateway.store_id=$STORE_ID,secrets.payment.gateway.store_user_id=$STORE_USER_ID,secrets.payment.gateway.store_token_id=$STORE_TOKEN_ID
. ./helm_chart_create_release.sh --release totem --dir $HELM_CHART_DIR/$TOTEM_FOOD_CHART --namespace $NAMESPACE --values-to-set $VALUES_TO_SET --white-space $WHITE_SPACE

echo -e "\n########### RESTARTING DEPLOYMENT #####################\n"
./restart_deployment.sh -dn coredns -n kube-system

##############################################################################
################### INTEGRATION EKS AND API GATEWAY - AWS VARIABLES
##############################################################################

echo -e "\n########### GETTING KUBERNETES LOAD BALANCER DNS #####################\n"
SVC_PRIVATE_LB="totem-totem-food-service-lb-private"
DNS_NAME=$(. ./svc_get_load_balancer.sh --service-name $SVC_PRIVATE_LB --namespace $NAMESPACE)

echo -e "\n########### GETTING AWS LOAD BALANCER ARN #####################\n"
LB_ARN=$(. ./load_balancer_get_attributes.sh --profile $PROFILE --region $REGION --dns-name $DNS_NAME)

echo -e "\n########### GETTING AWS LOAD BALANCER LISTENER ARN #####################\n"
LISTENER_ARN=$(. ./describe_load_balancer_lister.sh --profile $PROFILE --region $REGION --load-balancer-arn $LB_ARN)


##############################################################################
################### INTEGRATION EKS AND API GATEWAY - TERRAFORM
##############################################################################

echo -e "\n########### APPLING INTEGRATION BETWEEN EKS AND API GATEWAY #####################\n"

echo -e "\n########### GETTING VARIABLES FROM TERRAFORM #####################\n"
CLUSTER_EKS_VPC_LINK=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cluster_eks_vpc_link)
CLUSTER_EKS_PRIVATE_SUBNET_ONE=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cluster_eks_private_subnet_one)
CLUSTER_EKS_PRIVATE_SUBNET_TWO=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key cluster_eks_private_subnet_two)
API_GATEWAY_RESTRICT_API_ID=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key aws_apigatewayv2_api_restrict_api_id)
API_GATEWAY_AUTORIZER_ID=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key aws_apigatewayv2_authorizer_authorizer_id)
API_GATEWAY_VPC_LINK_ID=$(. ./value-from-terrafom.sh --dir $TERRAFORM_COMPONENTS_DIR --key aws_apigatewayv2_vpc_link_eks_id)

cat << EOF > $TERRAFORM_INTEGRATION_DIR/terraform.tfvars.json
{
  "profile": "$PROFILE",
  "application_name": "$APP_NAME", 
  "environment": "$ENVIRONMENT", 
  "owner_team": "$OWNER_TEAM",
  "region": "$REGION",
  "vpc_security_group_eks_ids": ["$CLUSTER_EKS_VPC_LINK"], 
  "eks_private_subnet_ids": ["$CLUSTER_EKS_PRIVATE_SUBNET_ONE", "$CLUSTER_EKS_PRIVATE_SUBNET_TWO"], 
  "eks_private_load_balancer_arn": "$LISTENER_ARN",
  "aws_apigatewayv2_api_restrict_api_id": "$API_GATEWAY_RESTRICT_API_ID",
  "aws_apigatewayv2_authorizer_authorizer_id": "$API_GATEWAY_AUTORIZER_ID",
  "aws_apigatewayv2_vpc_link_eks_id": "$API_GATEWAY_VPC_LINK_ID"
}
EOF

echo -e "\n########### TERRAFORM INIT #####################\n"
. ./terraform-init.sh --dir $TERRAFORM_INTEGRATION_DIR

echo -e "\n########### TERRAFORM PLAN #####################\n"
. ./terraform-plan.sh --dir $TERRAFORM_INTEGRATION_DIR

echo -e "\n########### TERRAFORM APPLY #####################\n"
. ./terraform-apply.sh --dir $TERRAFORM_INTEGRATION_DIR