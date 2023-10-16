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
    -uPoolId|--user-pool-id)
      USER_POOL_ID="$2"
      shift # past argument
      shift # past value
      ;;
    -cn|--client-name)
      CLIENT_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -cId|--client-id)
      CLIENT_ID="$2"
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
SERVICE=cognito-idp
COMMAND=describe-user-pool-client
OUTPUT=json
REQUIRED_PARAMS="--user-pool-id=\"$USER_POOL_ID\" --client-id=\"$CLIENT_ID\""
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

CLIENT_RETURNED=`eval ${COMMAND_AWS}`

JQ_FILTER=".UserPoolClient.ClientName"
CONTAINS=$(echo $CLIENT_RETURNED | jq '.UserPoolClient.ClientName | contains('\"$CLIENT_NAME\"')')

if [ $CONTAINS = "true" ] 
then
  JQ_FILTER=".UserPoolClient.ClientSecret"
  CLIENT_SECRET=$(echo $CLIENT_RETURNED | jq $JQ_FILTER)
  echo $CLIENT_SECRET | sed 's/\"//g'
else
  echo "NOT_FOUND"
fi
############################################################### END TASK
