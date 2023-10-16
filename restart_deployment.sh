#!/bin/bash

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -dn|--deployment-name)
      DEPLOYMENT_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tDeployment Name: -dn or --deployment-name\n \tNamespace: -n or --namespace\n"
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
COMAMND="kubectl rollout restart deployment $DEPLOYMENT_NAME --namespace $NAMESPACE 2>&1"
COMMAND_RETURNED=`eval ${COMAMND}`
SUB=Error

if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
  echo "Error on deployment $DEPLOYMENT_NAME or namespace $NAMESPACE"
else
  echo "Restargin deployment $DEPLOYMENT_NAME on namespace $NAMESPACE"
fi

############################################################### END TASK