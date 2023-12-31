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
    -ws|--white-space)
      WHITE_SPACE="$2"
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

if [ ! -z "$WHITE_SPACE" ]
then
  COMAMND=$(echo $COMAMND | sed "s/$WHITE_SPACE/ /g")
fi

COMMAND_RETURNED=`eval ${COMAMND}`
SUB="Error"
REUSE="re-use"

if [[ "$COMMAND_RETURNED" != *"$REUSE"* ]]; then
  if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
    echo $COMMAND_RETURNED
    exit 0
  else
    echo "Release $RELEASE_NAME on Namespace $NAMESPACE created!"
  fi
else
  echo "Release already exists!"
fi
############################################################### END TASK