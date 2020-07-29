##### How to create new ca certificate using openssl
Create a private rsa key
```sh
openssl genrsa -out rsa.key
```
Inspect the rsa key
```sh
openssl rsa -in rsa.key -text
```

###### Create self signed ca cert with rsa private key
```sh
openssl req -new -x509 -key rsa.key -out ca.crt
```

> Note: if we remove -x509 file, it will become the csr (certificate signing request). We can provide this csr and get ca.crt from CA authorities. In the below section we will sign the csr with kubernetes apiserver

##### How to create csr requests and get new ca certificate
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#kubernetes-signers

Using this we can create a kubeconfig.conf file.
Above approach is similar to `kubeadm alpha kubeconfig --user`. In order to use kubeadm, we have to ssh into the k8s master. But csr approach we can achieve it if we have proper rolebinding

##### Inspect a ca cert and get details
```sh
openssl x509 -in ca.crt -text
```

##### References: 
https://gist.github.com/Soarez/9688998