#!/bin/bash

EKS_STATE_DIR=./eks_state
[ ! -d $EKS_STATE_DIR ] && mkdir -p $EKS_STATE_DIR

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--region)
      REGION="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--profile)
      PROFILE="$2"
      shift # past argument
      shift # past value
      ;;
    -cn|--cluster-name)
      CLUSTER_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tRegion: -r or --region \n \tProfile: -p or --profile \n \tCluster Name: -cn or --cluster-name\n"
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
COMAMND="aws eks update-kubeconfig --name $CLUSTER_NAME --profile $PROFILE --region $REGION"

FILE="$EKS_STATE_DIR/eks-$CLUSTER_NAME-updated.txt"
SUB="Error"

if [ ! -f "$FILE" ]; then
  COMMAND_RETURNED=`eval ${COMAMND}`
  if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
    echo $COMMAND_RETURNED
    exit 0
  else
    echo "Kube config for cluster $CLUSTER_NAME updated!"
    echo $COMMAND_RETURNED > "$EKS_STATE_DIR/eks-$CLUSTER_NAME-updated.txt"
  fi
else
  echo "Kube config for cluster $CLUSTER_NAME already updated!"
fi

############################################################### END TASK