#!/bin/bash

HELM_STATE_DIR=./helm_state
[ ! -d $HELM_STATE_DIR ] && mkdir -p $HELM_STATE_DIR

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--release)
      RELEASE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tRelease Name: -r or --release \n \tNamespace: -n or --namespace\n"
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
COMAMND="helm delete $RELEASE_NAME --namespace $NAMESPACE 2>&1"

FILE="$HELM_STATE_DIR/release-$RELEASE_NAME-namespace-$NAMESPACE.txt"

if [ -f "$FILE" ]; then
  COMMAND_RETURNED=`eval ${COMAMND}`
  rm -r "$FILE"
fi

echo "Release $RELEASE_NAME on Namespace $NAMESPACE deleted!"
############################################################### END TASK