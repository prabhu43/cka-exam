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

**[kubeadm alpha commands](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-alpha/)**
```
kubeadm alpha certs renew
kubeadm alpha certs certificate-key
kubeadm alpha certs check-expiration
kubeadm alpha kubeconfig user
kubeadm alpha kubelet config
kubeadm alpha selfhosting pivot
```