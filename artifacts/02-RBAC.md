#### Be familiar with below commands:
```sh
kubectl auth can-i get secret --as secret@test.com

kubectl auth can-i get pods --as system:serviceaccount:default:sa-name

kubectl create rolebinding default-edit --role deploymentEditor --serviceaccount default

kubectl create clusterrolebinding dinesh-ca --user=Dinesh --clusterrole=cluster-admin
```

#### Is it possible to specify rules based on name of the resource ?

Eg: Create a ClusterRole and ClusterRoleBinding so that user deploy@test.com can only deploy and manage pods named compute. Test it.

##### Solution:
use `--resource-name=compute` flag while creating role

```
# Create a Role named "pod-reader" with ResourceName specified
kubectl create role pod-reader --verb=get \
--resource=pods \
--resource-name=readablepod --resource-name=anotherpod
```