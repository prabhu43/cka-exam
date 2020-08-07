#!/usr/bin/env bash

alias k="kubectl"
alias kctx="k config current-context"
alias kuctx="k config use-context"
alias kgctx="k config get-contexts"
alias kpoall="k get pod --all-namespaces"
alias kge="k get events --sort-by='.metadata.creationTimestamp'"
alias kubens="k config set-context --current --namespace"
alias newdep="k create deploy --dry-run=client -o yaml"

## for auto completion
source <(kubectl completion bash)
source <(kubectl completion bash | sed 's/kubectl/k/g')