**kubectl api-resources**
Print the supported API resources on the server

**kubectl api-versions**
Print the supported API versions on the server, in the form of "group/version"

**some kubectl create commands**
```
## Create role
kubectl create role developer \
    --verb=create --verb=get --verb=list --verb=update --verb=delete \
    --resource=pods

## Create rolebinding
kubectl create rolebinding developer-binding-john \
    --role=developer 
    --user=john
```

**Update the labels on a resource**
```sh
# add a label to node
k label node NODE_NAME KEY=VALUE

# for more examples
k label -h
```

**Taint node**
```sh
# Add a taint to a node
# taint effects: NoSchedule, PreferNoSchedule, NoExecute
k taint nodes NODE_NAME KEY=VALUE:TAINT_EFFECT

# Remove from node 'foo' the taint with key 'dedicated' and effect 'NoSchedule' if one exists.
k taint nodes foo dedicated:NoSchedule-

# for more examples
k taint -h
```

> If a node fails and has to be recreated, you must re-apply the label to the recreated node. To make this easier, you can use Kubelet's command-line parameter for applying node labels in your node startup script.

**[kubeadm alpha commands](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-alpha/)**
```
kubeadm alpha certs renew
kubeadm alpha certs certificate-key
kubeadm alpha certs check-expiration
kubeadm alpha kubeconfig user
kubeadm alpha kubelet config
kubeadm alpha selfhosting pivot
```

**kubectl top**
```
# most cpu consuming pods
# --reverse for descending order
# --key 3 means order by 3rd column
k top po -A | sort --reverse --key 3
```

**View custom kubeconfig file as json**
```
k config view --kubeconfig=<config-file>
```

**Verbs applicable for a resource**
```
k api-resources -o wide
```