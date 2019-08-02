#!/usr/bin/env bash

set -e

usage(){
    echo "Usage: "
    echo "  $0 STACK REGION"
    exit 1
}

[ $# -ge 2 ] || usage

STACKNAME=${1}
REGION=${2}
PROFILE=${3:-default}

cat << EOF
Gonna perform this delete operation, hit ENTER to confirm or Ctrl-C to abort

REGION:  $REGION
STACK:   $STACKNAME
PROFILE: $PROFILE

Gonna perform this delete operation, hit ENTER to confirm or Ctrl-C to abort
EOF
[ "$FORCE" == "yes" ] && echo FORCED || read CONFIRM
aws cloudformation delete-stack --region $REGION --profile $PROFILE --stack-name $STACKNAME && echo OK || echo ERROR
