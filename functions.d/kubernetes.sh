# Kubernetes shit
KUBEDIR=~/.kube
EXTRA_NAMESPACES="staging ci"
KUBERNETES_NAMESPACE_F=$KUBEDIR/.namespace
KUBERNETES_NAMESPACES_F=$KUBEDIR/.namespaces
KUBERNETES_CONTEXT_F=$KUBEDIR/.context
KUBERNETES_KUBECTL_DEFAULT=kubectl

source <(kubectl completion bash)

# Cache stuff in files to faster use in other places (command line prompt, ...)
k_get_context(){ grep ^current-context ${KUBECONFIG:-~/.kube/config}|cut -d ' ' -f 2| tr -d \\n; }
k_get_context_fast(){ cat $KUBERNETES_CONTEXT_F; }
k_get_namespace(){ kubectl config get-contexts | awk '/^*/{print $NF}'; }
k_get_namespace_fast(){ cat $KUBERNETES_NAMESPACE_F; }
k_write_fasts(){ k_get_context > $KUBERNETES_CONTEXT_F; k_get_namespace > $KUBERNETES_NAMESPACE_F; }
k_write_namespaces(){ echo "$(kubectl get namespaces -o name | cut -d / -f 2) $EXTRA_NAMESPACES" > $KUBERNETES_NAMESPACES_F; }
[ -f $KUBERNETES_NAMESPACES_F ] || k_write_namespaces

# kch <context> [namespace] # Change kubernetes cluster
kch(){
    context=$1
    namespace=$2
    kubectl config use-context $context
    [ "$2" ] && kns $namespace
    k_write_fasts
}
complete -W "$(kubectl config get-contexts -o name)" kch

# kns <namespace> [context] # Change default namespace
kns(){
    local namespace=${1:-default}
    local context=${2:-$(k_get_context)}
    kubectl config set-context $context --namespace=${namespace}
    k_write_fasts
}
complete -W "$(cat $KUBERNETES_NAMESPACES_F)" kns

# Shortcut to kubectl, allowing different versions of the client
k(){
    #case $(k_get_context_fast) in
    #    exception) _kubectl=kubectl-1.9.2;;
    #    *) _kubectl=$KUBERNETES_KUBECTL_DEFAULT;;
    #esac
    _kubectl=$KUBERNETES_KUBECTL_DEFAULT
    $_kubectl $@
}

# kshell <pod> [command] # Exec command on pod (default: bash)
kshell(){
    if [ $# -gt 0 ]; then
        kubectl exec -it $1 -- ${2:-bash}
    fi
}
complete -F _k kshell

# custom completion for "k"
_k(){
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    case "$prev" in
        -f)
            _filedir;;
        get)
            opts="clusters cm componentstatuses configmaps cs daemonsets deploy deployments ds endpoints ep ev events horizontalpodautoscalers hpa ing ingress jobs jobs limitranges limits namespaces no nodes ns persistentvolumeclaims persistentvolumes statefulset sts po pods pv pvc quota quota quota rc replicasets replicationcontrollers resourcequotas rs sa secrets serviceaccounts services svc"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
        deploy|deployment)
            opts="$(kubectl get deploy|grep -v NAME|cut -d ' ' -f 1)"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
        *)
            opts="$(kubectl get pods|grep -v NAME|cut -d ' ' -f 1)"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac
    return 0
}
complete -F _k k

# configmap to files
k_configmap_to_files(){
    command="k get cm -o json $@"
    for key in $( $command | jq -r '.data | keys[]'); do
        echo $key
        $command | jq -r '.data."'${key}'"' > $key
    done
}

# decode kubernetes secret
decode_kubernetes_secret(){
    if [ "$1" == "-j" ]; then
        shift
        command="k get secret -o json $@"
        for key in $( $command | jq -r '.data | keys[]'); do
            echo ""
            echo $key
            echo $key|tr '[:print:]' =
            $command | jq -r '.data."'${key}'"' | base64 -d
            echo ""
        done
    elif [ "$1" == "--cert" ]; then
        shift
        command="k get secret -o json $@"
        key=tls.crt
        $command | jq -r '.data."'${key}'"' | base64 -d
    elif [ "$1" == "--key" ]; then
        shift
        command="k get secret -o json $@"
        key=tls.key
        $command | jq -r '.data."'${key}'"' | base64 -d
    else
        command="k get secret -o json $@"
        $command | jq '.data | map_values(@base64d)'
    fi
}
alias ds=decode_kubernetes_secret

# check if all replicas are ready
k_check_allready(){
    type=$1
    name=$2
    case $type in
        deploy|deployment)
            field=unavailableReplicas
            grep=null
            k get $type $name -o json | jq -r .status.$field | grep -qx null
            ;;
        daemonset|ds)
            field=numberMisscheduled
            grep=0
            ;;
        *) echo "Type $type not supported yet"
            exit 1
            ;;
    esac
    k get $type $name -o json | jq -r .status.$field | grep -qx "$grep"
}

# wait until all replicas are ready
k_waitfor_allready(){
    while ! k_check_allready $1 $2; do
        sleep 1
    done
}

k_get_labels(){
    type=$1
    service=$2

    case $type in
        deploy*|sts|statefulset|ds|daemonset) field=.spec.template.metadata.labels ;;
        *) field=.metadata.labels ;;
    esac
    k get $type $service -o yaml | yq $field | json2yaml| tr -d \ \' | tr : =|paste -s -d , -
}

# Performs a delete of all of the pods of a deployment in a "rolling restart" fashion, one by one
k_rolling_delete(){
    type=$1
    name=$2
    labels=$(k_get_labels $type $name)
    if [ "$labels" ]; then
        for pod in $(k get po -o name -l $labels); do
            k delete $pod
            k_waitfor_allready $type $name
        done
    else
        echo "ERROR: No pods with labels $labels"
    fi
}

k_node_selector(){
    export node_selector=$@
    ns_template='"spec": {"template": { "spec": { "nodeSelector": { ${node_selector} } } } }'
    echo $ns_template | envsubst | tr -d ' '
}

# kdebug [-i image] [-n name_of_pod] [-s fast_node_selector] [-ns node_selector] # Run debug container
kdebug(){
    image=javipolo/ubuntu-debug
    name=javipolo

    if [ "$1" == "-d" ]; then
        debug="echo "
        shift;
    fi

    if [ "$1" == "-i" ]; then
        image=$2
        shift; shift;
    fi

    if [ "$1" == "-n" ]; then
        name=$2
        shift; shift;
    fi

    if [ "$1" == "-ns" ]; then
        node_selector=$(k_node_selector $(k_node_selector $2))
        extra_args="--overrides={$node_selector}"
        shift; shift;
    fi

    kubectl run --restart=Never -it $extra_args --image $image $name
}
