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
    -h|--help)
      echo -e "Options:\n \tTerraform Dir: -d or --dir \n"
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

if [ -z "$DIR" ]
then
  echo "Terraform directory is required"
  exit
fi

terraform -chdir=$DIR init -reconfigure >> /dev/null