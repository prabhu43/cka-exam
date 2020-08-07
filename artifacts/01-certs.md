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

**Some openssl commands**
```
- Generate a 2048bit RSA private key and save it to a file:
    openssl genrsa -out filename.key 2048

- Generate a certificate signing request to be sent to a certificate authority:
    openssl req -new -sha256 -key filename.key -out filename.csr

- Generate a self-signed certificate from a certificate signing request valid for some number of days:
    openssl x509 -req -days days -in filename.csr -signkey filename.key -out filename.crt

- Display certificate information:
    openssl x509 -in filename.crt -noout -text

- Display a certificate's expiration date:
    openssl x509 -enddate -noout -in filename.pem

- Display the start and expiry dates for a domain's certificate:
    openssl s_client -connect host:port 2>/dev/null | openssl x509 -noout -dates

- Display the certificate presented by an SSL/TLS server:
    openssl s_client -connect host:port </dev/null

- Display the complete certificate chain of an HTTPS server:
    openssl s_client -connect host:443 -showcerts </dev/null
```