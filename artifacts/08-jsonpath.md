## Jsonpath
https://kubernetes.io/docs/reference/kubectl/jsonpath/

```sh
k get po -o jsonpath="{.kind}"
k get po -o jsonpath="{['kind']}"

k get po -o jsonpath="{@}"

k get po -o jsonpath="{.items[0]}"

k get po -o jsonpath="{.items[*]}"

k get po -o jsonpath="{..name}"

k get po -o jsonpath="{.items[0]['metadata.name']}"

# start:end:step, index => 0,2
k get po -o jsonpath="{.items[0:4:2]['metadata.name']}"

k get po -o jsonpath="{.items[*]['metadata.name']}"

# prints all the names and then all the nodenames
k get po -o jsonpath="{.items[*]['metadata.name', 'spec.nodeName']}"

# filter; show name of pods running in a node 
k get po -o jsonpath="{.items[?(.spec.nodeName=='k8s-node-medium-1')].metadata.name}"

# range: show name of all pods
k get po -o jsonpath="{ range .items[*]}{.metadata.name}{'\n'}{end}"

# range; show pod name and nodename of all pods
k get po -o jsonpath="{ range .items[*]}{.metadata.name},{.spec.nodeName}{'\n'} {end}"
```