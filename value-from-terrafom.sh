#!/bin/bash

############################################################### INIT PARAMETERS READ
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -k|--key)
      KEY="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "Options:\n \tTerraform Dir: -d or --dir \n \tTerraform Key from output: -k or --key\n"
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
TERRAFORM_OUT_JSON=$(terraform -chdir=$DIR output -json)
JQ_FILTER=".$KEY.value"
# echo $JQ_FILTER
RESULT_FROM_JQ=$(echo $TERRAFORM_OUT_JSON | jq $JQ_FILTER)
echo $RESULT_FROM_JQ | sed 's/\"//g'
############################################################### END TASK