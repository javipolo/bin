#!/bin/bash

debug_image=javipolo/ubuntu-debug:latest

[ "$1" == "-n" ] && { dryrun=true; shift 1; }
[ "$1" == "-d" ] && { image=${debug_image}; shift 1; }
[ "$1" == "-e" ] && { safe_to_evict=false; shift 1; }
[ "$1" == "-p" ] && { type=pod; shift 1; }
[ "$1" == "-i" ] && { image=$2; shift 2; }

deploy_name=$1
pod_new_name=$USER-$1

pod_base='{ "apiVersion": "v1", "kind": "Pod" }'
pod_name='{ "name": "'$pod_new_name'" }'
pod_labels='{ "name": "'$pod_new_name'", "debug": "'$USER'" }'
pod_command='{ "command": ["tail", "-f", "/dev/null"] }'
[ "$image" ] && pod_image='{ "image": "'${image}'"}' || pod_image=null
[ "$safe_to_evict" == "false" ] && pod_no_evict='{ "cluster-autoscaler.kubernetes.io/safe-to-evict": "false" }' || pod_no_evict=null

apply_command="kubectl apply -f -"
[ "$dryrun" == "true" ] && apply_command=$(command -v json2yaml > /dev/null && echo json2yaml || echo cat)

usage(){
    cat << EOF
Creates a debugging pod using a deployment as base

Usage: $0 [-n] [-d] [-i image:name] <deploy-name>
        -n        dry run       - Do nothing, just print the generated json/yaml
        -d        debug image   - Use defaut debug image in all the containers
        -e                      - Set the safe-to-evict to false for this pod
        -p                      - Use a pod instead of a deployment as template
        -i image  custom image  - Use specific image in all the containers

        default debug image: $debug_image
EOF
    exit 1
}

deploy_to_pod(){
    jq "$pod_base + .spec.template"
}

pod_cleanup(){
    jq 'del(.metadata.creationTimestamp) |
        del(.metadata.labels) |
        del(.spec.containers[].livenessProbe) |
        del(.spec.containers[].readinessProbe) |
        del(.spec.resources) |
        del(.spec.containers[].command)
        '
}

pod_amend(){
    jq ". |
        .metadata += $pod_name |
        .metadata.labels += $pod_labels |
        .metadata.annotations += $pod_no_evict |
        .spec.containers[] += $pod_image |
        .spec.containers[] += $pod_command
       "
}

[ "$deploy_name" ] || usage

if [ "$type" == "pod" ]; then
    kubectl get pod $1 -o json | pod_cleanup | pod_amend | $apply_command
else
    kubectl get deploy $1 -o json | deploy_to_pod | pod_cleanup | pod_amend | $apply_command
fi
