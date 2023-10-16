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
    -h|--help)
      echo -e "Options:\n \tProfile: -p or --profile\n"
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



SUB=Error

if [ ! -z "$PROFILE" ]
then

  COMAMND="aws s3 ls --profile $PROFILE 2>&1"
  COMMAND_RETURNED=`eval ${COMAMND}`

  if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
    aws sso login --profile $PROFILE
  else
    echo "Logged in with SSO Token"
  fi
else
  COMAMND="aws s3 ls 2>&1"
  COMMAND_RETURNED=`eval ${COMAMND}`

  if [[ "$COMMAND_RETURNED" == *"$SUB"* ]]; then
    echo "Invalid credentials set your credentials on aws file ~/.aws/credentials"
    exit
  else
    echo "Logged in with SSO Token"
  fi
fi