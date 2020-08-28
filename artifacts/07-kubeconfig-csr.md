## CertificateSigningRequest

**create certificate signing request**
```sh
# generate private key
# write the key to file 'prabhu.key'
# 2048 bits
openssl genrsa -out prabhu.key 2048

# generate certificate, give user name in Common Name
# '-new' => new request
# '-key prabhu.key' => use the private key contained in file
# '-out prabhu.csr' => write certificate to file
openssl req -new -key prabhu.key -out prabhu.csr

# create CSR
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: prabhu
spec:
  groups:
  - system:authenticated
  request: <base64 encoded value of prabhu.csr content> # cat prabhu.csr | base64 | tr -d "\n"
  usages:
  - client auth
EOF

# Check the status of csr
kubectl get csr

# Approve csr
kubectl certificate approve prabhu

# Ensure the status of csr is approved
kubectl get csr

# Check the status.certificate; it is the signed certificate(base64 encoded)
kubectl get csr/prabhu -o yaml

# fetch the signed certificate
kubectl get csr prabhu -o jsonpath='{.status.certificate}' | base64 --decode > prabhu.signed.crt

```

## Create kubeconfig
**create kubeconfig using signed certificate created above**
- fetch ca certificate from existing kubeconfig
```sh
kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > k8s-ca.crt
```
- create kubeconfig for new user 'prabhu'
```sh
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')
kubectl config set-cluster $CLUSTER_NAME --server=$SERVER --certificate-authority=k8s-ca.crt --kubeconfig=prabhu-k8s-config --embed-certs
```
- add user credentials (use signed certificate and private key)
```sh
kubectl config set-credentials prabhu --client-certificate=prabhu.crt --client-key=prabhu.key --embed-certs --kubeconfig=prabhu-k8s-config
```
- set context
```
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')
kubectl config set-context prabhu@k8s --cluster=$CLUSTER_NAME --namespace=default --user=prabhu --kubeconfig=prabhu-k8s-config
```

- use context
```
kubectl config use-context prabhu --kubeconfig=prabhu-k8s-config
```

- check version using new kubeconfig
```
kubectl version --kubeconfig=prabhu-k8s-config
```

**Set permissions for new user using roles and rolebindings**
- give builtin `admin` role to user
```sh
kubectl create rolebinding prabhu-admin --namespace=default --clusterrole=admin --user=prabhu
```
- or create new developer role and assign it to user
```sh
kubectl create role developer --verb=create --verb=get --verb=list --verb=update --verb=delete --resource=pods

kubectl create rolebinding developer-binding-prabhu --role=developer --user=prabhu

```

## References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/
