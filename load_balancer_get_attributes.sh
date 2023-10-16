#!/bin/bash

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--profile)
      PROFILE="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--region)
      REGION="$2"
      shift # past argument
      shift # past value
      ;;
    -dns|--dns-name)
      DNS_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tAws Profile: -p or --profile \n \tUser Pool ID: -uPoolId or --user-pool-id \n \tClient Name: -cn or --client-name \n \tClient ID: -cId or --client-id\n"
      exit 1
      ;;
    -*|--*)
      echo "Unknown option $1"
      echo "Use optiona -h | --help"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
############################################################### END PARAMETERS READ

############################################################### INIT TASK
SERVICE=elbv2
COMMAND=describe-load-balancers
OUTPUT=json
REQUIRED_PARAMS="--region=$REGION"
CUSTOM_PARAM="--output=${OUTPUT}"


############################################################################
#### Considering the AWS CLI will run without specify the profile
############################################################################
if [ -z "$PROFILE" ]
then
  COMMAND_AWS="aws $SERVICE $COMMAND $REQUIRED_PARAMS $CUSTOM_PARAM"
else
  COMMAND_AWS="aws --profile=$PROFILE $SERVICE $COMMAND $REQUIRED_PARAMS $CUSTOM_PARAM"
fi
############################################################################
COMMAND_RETURNED=`eval ${COMMAND_AWS}`
echo $COMMAND_RETURNED | jq -c '[ .LoadBalancers[] | select( .DNSName | contains("'$DNS_NAME'")) ][].LoadBalancerArn' | sed 's/\"//g'

############################################################### END TASK
