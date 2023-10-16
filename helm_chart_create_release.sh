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
    -d|--dir)
      HELM_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -vts|--values-to-set)
      VALUES_TO_SET="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tRelease Name: -r or --release \n \tHelm Dir: -d or --dir \n \tNamespace: -n or --namespace \n \tValues to set: -vts or --values-to-set\n"
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

if [ -z "$VALUES_TO_SET" ]
then
  COMAMND="helm install $RELEASE_NAME $HELM_DIR --namespace $NAMESPACE 2>&1"
else
  COMAMND="helm install $RELEASE_NAME $HELM_DIR --namespace $NAMESPACE --set $VALUES_TO_SET 2>&1"
fi

FILE="$HELM_STATE_DIR/release-$RELEASE_NAME-namespace-$NAMESPACE.txt"
SUB="Error"

if [ ! -f "$FILE" ]; then
  COMMAND_RETURNED=`eval ${COMAMND}`
  if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
    echo $COMMAND_RETURNED
    exit 0
  else
    echo "Release $RELEASE_NAME on Namespace $NAMESPACE created!"
    echo $COMMAND_RETURNED > "$HELM_STATE_DIR/release-$RELEASE_NAME-namespace-$NAMESPACE.txt"
  fi
else
  echo "Release already exists!"
fi
############################################################### END TASK