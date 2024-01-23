#!/bin/bash

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -svc|--service-name)
      SERVICE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \Service Name: -dn or --service-name\n \tNamespace: -n or --namespace\n"
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

COMMAND_RETURNED=$(kubectl get svc $SERVICE_NAME -n $NAMESPACE --output json)
echo $COMMAND_RETURNED | jq -c '.status.loadBalancer.ingress[].hostname' | sed 's/\"//g'