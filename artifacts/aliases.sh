#!/usr/bin/env bash

alias kubens="k config set-context --current --namespace"

alias kctx="k config current-context"
alias kuctx="k config use-context"
alias kgctx="k config get-contexts"

alias kpoall="k get pod --all-namespaces"
alias kge="k get events --sort-by='.metadata.creationTimestamp'"

alias newdep="k create deploy --dry-run=client -o yaml"
#alias newdep-server="k create deploy --dry-run=server -o yaml"

export KS="-n kube-system" # k get po $KS

## For autocompletion, use kubectl cheatsheet page in k8s docs site. 
## https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete