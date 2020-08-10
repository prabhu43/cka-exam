
https://learnk8s.io/blog/kubectl-productivity

### Custom columns
https://learnk8s.io/blog/kubectl-productivity#3-use-the-custom-columns-output-format

### Jsonpath:

```
k get deploy utils -o jsonpath={.metadata.name}

k get deploy -o jsonpath="{.items[].metadata.name}"
k get deploy -o jsonpath="{.items[*].metadata.name}"
k get deploy -o jsonpath="{.items[*]['.metadata.name','.metadata.namespace'] }"
k get deploy -o jsonpath="{.items[1].metadata.name}"
k get deploy -o jsonpath="{.items[0:2].metadata.name}"

k get deploy -o jsonpath="{ range .items[*]} {.metadata.name},{.metadata.namespace}{'\n'} {end}"

k get po -A -o jsonpath="{.items[?(@.metadata.namespace=='default')].metadata.name}"

k get po -A -o jsonpath="{.items[?(@.metadata.namespace!='default')].metadata.name}"

```

#### References:
https://kubernetes.io/docs/reference/kubectl/jsonpath/
https://discuss.kubernetes.io/t/quick-jsonpath-basics/10102
