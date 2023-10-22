#!/bin/bash

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--namespace)
      NAMESPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tNamespace: -n or --namespace\n"
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
COMAMND="kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f - 2>&1"
COMMAND_RETURNED=`eval ${COMAMND}`
SUB=AlreadyExists

echo "RETORNO: $COMMAND_RETURNED"

if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
  echo "Namespace $NAMESPACE already exists"
else
  echo "Namespace $NAMESPACE created"
fi

############################################################### END TASK