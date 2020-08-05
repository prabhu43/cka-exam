#!/usr/bin/env bash

alias k="kubectl"
alias kctx="k config current-context"
alias kuctx="k config use-context"
alias kgctx="k config get-contexts"
alias kns="k config set-context --current --namespace"
alias kpoall="k get pod --all-namespaces"
alias kge="k get events --sort-by='.metadata.creationTimestamp'"

## for auto completion
source <(kubectl completion bash)
source <(kubectl completion bash | sed 's/kubectl/k/g')