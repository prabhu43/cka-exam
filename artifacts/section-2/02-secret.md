# Secret

- store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys
- name of a Secret object must be a valid DNS subdomain name. 

**3 ways of using it in pod**
- As files in a volume mounted on one or more of its containers
- As container environment variable
- By the kubelet when pulling images for the Pod

**3 types of secrets**
- docker-registry: Create a secret for use with a Docker registry
- generic: Create a secret from a local file, directory or literal value
- tls: Create a TLS secret

**Builtin secrets**
- Service accounts automatically create secret and attach it with API credentials
- this can be disabled

### Create secret

**kubectl create**
- create from file
```
echo -n 'admin' > ./username.txt
echo -n '1f2d1e2e67df' > ./password.txt

# uses filename as key
kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt

# k describe secret db-user-pass
Data
====
password.txt:  8 bytes
username.txt:  5 bytes
```

- create from file, but use keyname
```
# uses filename as key
kubectl create secret generic db-user-pass --from-file=username=./username.txt --from-file=password=./password.txt

# k describe secret db-user-pass
Data
====
password:  8 bytes
username:  5 bytes
```

- create from literal
```
k create secret generic db-user-pass --from-literal=username=admin --from-literal=password=abcd1234

# k describe secret db-user-pass
Data
====
password:  8 bytes
username:  5 bytes
```
> use single quotes in case of having special characters in the value

**create manually**
- create a Secret in a file first, in JSON or YAML format, and then create that object
```sh
echo -n 'admin' | base64 # YWRtaW4=
echo -n '1f2d1e2e67df' | base64 # MWYyZDFlMmU2N2Rm
```
- kubectl apply -f ./secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```



- contains two maps: data and stringData. 
- `data`: used to store arbitrary data, encoded using base64
- `stringData`: provided for convenience, and allows you to provide secret data as unencoded strings, it will be automatically encoded on creation/updation
- If a field, is specified in both data and stringData, the value from stringData is used
- keys of data and stringData must consist of alphanumeric characters, '-', '_' or '.'

> Newlines are not valid within the strings and must be omitted

### Decode secret
```sh
echo 'MWYyZDFlMmU2N2Rm' | base64 --decode
```

### Using secrets
**As files in pod using volumes**
- Inside the container that mounts a secret volume, the secret keys appear as files and the secret values are base64 decoded and stored inside these files
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret 
      # Each key in the secret data map becomes the filename under mountPath
```
- Projection of Secret keys to specific paths
```yaml
volumes:
  - name: foo
    secret:
      secretName: mysecret
      items:
      - key: username
        path: my-group/my-username
        # username secret is stored under /etc/foo/my-group/my-username file instead of /etc/foo/username
        # also other keys of secret will not be projected
        # All listed keys must exist in the corresponding secret. Otherwise, the volume is not created
```
- Secret file permissions
    - 0644 is used by default
```
volumes:
  - name: foo
    secret:- 
      secretName: mysecret
      defaultMode: 0400 # default mode for the entire Secret volume is changed
      # it can be changed at key level as well if using items
```

- Mounted Secrets are updated automatically
    - same as configmap
    - A container using a Secret as a subPath volume mount will not receive Secret updates.
- Immutable Secrets and ConfigMaps
    - same as configmap
    - kubernetes alpha feature; has to be enabled by feature gate `ImmutableEphemeralVolumes`

**As environment variables**
- Inside a container that consumes a secret in an environment variables, the secret keys appear as normal environment variables containing the base64 decoded values of the secret data

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
```
**ImagePullSecrets**
- `pod.spec.imagePullSecrets`: pass a secret that contains a Docker (or other) image registry password to the kubelet
- kubelet uses this information to pull a private image on behalf of your Pod

```yaml
# type of secret is docker-registry
kubectl create secret docker-registry myregistrykey --docker-server=DUMMY_SERVER \
        --docker-username=DUMMY_USERNAME --docker-password=DUMMY_DOCKER_PASSWORD \
        --docker-email=DUMMY_DOCKER_EMAIL
```
**Automatic injection of imagePullSecrets**
- Use service account
```sh
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}'
```
- when a new Pod is created in the same namespace as this default ServiceAccount, it will have spec.imagePullSecrets field set automatically

**Automatic injection of secrets**
- Use pod preset

### Restrictions
- a secret needs to be created before any Pods that depend on it
- Secrets can only be referenced by Pods in that same namespace
- Individual secrets are limited to 1MiB in size
- References (secretKeyRef field) to keys that do not exist in a named Secret will prevent the Pod from starting
- while using `envFrom`
  - invalid keys are skipped 
  - pod will start with valid keys
  - but it will be logged in events(`InvalidVariableNames`) with list of such invalid keys skipped

### Secret and Pod lifetime interaction
- When a Pod is created by calling the Kubernetes API, there is no check if a referenced secret exists. Once a Pod is scheduled, the kubelet will try to fetch the secret value
- If the secret cannot be fetched because it does not exist or because of a temporary lack of connection to the API server, the kubelet will periodically retry
- It will report an event about the Pod explaining the reason it is not started yet
- Once the secret is fetched, the kubelet will create and mount a volume containing it. 
- None of the Pod's containers will start until all the Pod's volumes are mounted

### Usecases
**As container environment variables**
Use envFrom to define all of the Secret’s data as container environment variables. The key from the Secret becomes the environment variable name in the Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - secretRef:
          name: mysecret
  restartPolicy: Never
```

### Best practices
**Clients that use the Secret API**
- listing secrets allows the clients to inspect the values of all secrets that are in that namespace
- The ability to `watch` and `list` all secrets in a cluster should be reserved for only the most privileged, system-level components

**Security**
- A secret is only sent to a node if a Pod on that node requires it. The kubelet stores the secret into a tmpfs so that the secret is not written to disk storage. Once the Pod that depends on the secret is deleted, the kubelet will delete its local copy of the secret data as well.

- Risks
    - A user who can create a Pod that uses a secret can also see the value of that secret. Even if the API server policy does not allow that user to read the Secret, the user could run a Pod which exposes the secret.
    - Currently, anyone with root permission on any node can read any secret from the API server, by impersonating the kubelet. It is a planned feature to only send secrets to nodes that actually require them, to restrict the impact of a root exploit on a single node

## References
https://kubernetes.io/docs/concepts/configuration/secret/