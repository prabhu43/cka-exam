## Configmap
- an API object used to store non-confidential data in key-value pairs
- The name of a ConfigMap must be a valid [DNS subdomain name](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-subdomain-names)
- Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.
- Example:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  # property-like keys; each key maps to a simple value
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"
  #
  # file-like keys
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
```

**4 ways of using configmap in pod**
- Command line arguments to the entrypoint of a container
- Environment variables for a container
- Add a file in read-only volume, for the application to read
- Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap (lets you access a ConfigMap in a different namespace)

> For the first three methods, the kubelet uses the data from the ConfigMap when it launches container(s) for a Pod


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: busybox
      command: "sleep 1d"
      env:
        # Define the environment variable
        - name: PLAYER_INITIAL_LIVES # Notice that the case is different here
                                     # from the key name in the ConfigMap.
          valueFrom:
            configMapKeyRef:
              name: game-demo           # The ConfigMap this value comes from.
              key: player_initial_lives # The key to fetch.
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name
      volumeMounts:
      - name: config
        mountPath: "/config"
        readOnly: true
  volumes:
    # You set volumes at the Pod level, then mount them into containers inside that Pod
    - name: config
      configMap:
        # Provide the name of the ConfigMap you want to mount.
        name: game-demo
        # An array of keys from the ConfigMap to create as files
        items:
        - key: "game.properties"
          path: "game.properties"
        - key: "user-interface.properties"
          path: "user-interface.properties"
```

- If you omit the items array entirely, every key in the ConfigMap becomes a file with the same name as the key and you get 4 files in this case
- Multiple Pods can reference the same config map.

**Mounted ConfigMaps are updated automatically**
- when configmap used as volume in pod is updated, the projected keys are  `eventually` updated by kubelet.
- kubelet periodically sync, uses its local cache to detect the change
- A container using a ConfigMap as a `subPath` volume will not receive ConfigMap updates
- More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#mounted-configmaps-are-updated-automatically

**Immutable Secrets and ConfigMaps**
- alpha feature in v1.18
- Cannot edit config map; can only delete and recreate the ConfigMap
- Existing Pods maintain a mount point to the deleted ConfigMap - it is recommended to recreate these pods
- Uses:
    - protects you from accidental (or unwanted) updates that could cause applications outages
    - improves performance of your cluster by significantly reducing load on kube-apiserver, by closing watches for config maps marked as immutable
- Example:    
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  ...
data:
  ...
immutable: true
```
### Create configmap

**from directory**
- `k create cm <cm-name> --from-file=<directory-path>`
- above command created a configmap with all files in the directory with the file name as key and its contents as value; 1 entry in map for each file in the directory

**from file**
- `k create cm <cm-name> --from-file=<filepath1> --from-file=<filepath2>`
- above command created a configmap with 2 entries with the file name as key and its contents as value

**from file, but using different key name instead of filename**
- `k create cm <cm-name> --from-file=<key-name>=<filepath1>`

**from env-file**
- `k create cm <cm-name> --from-env-file=<filepath1>`
```sh
# Env-files contain a list of environment variables.
# These syntax rules apply:(if not, creation will fail)
#   Each line in an env file has to be in VAR=VAL format.
#   Lines beginning with # (i.e. comments) are ignored.
#   Blank lines are ignored.
#   There is no special handling of quotation marks (i.e. they will be part of the ConfigMap value)).

# The env-file `game-env-file.properties` looks like below
cat env-file.properties
enemies=aliens
lives=3
allowed="true"

# This comment and the empty line above it are ignored
```
>  When passing --from-env-file multiple times to create a ConfigMap from multiple data sources, only the last env-file is used

**from-literal**
`k create cm literal1 --from-literal firstname=prabhu --from-literal=lastname=jayakumar`
```yaml
apiVersion: v1
data:
  firstname: prabhu
  lastname: jayakumar
kind: ConfigMap
...
```

**Mixing different ways of creation is allowed**
`k create cm mixed --from-literal firstname=prabhu --from-file=<filepath>`

### Use configmap

**container environment variables**
```yaml
containers:
  - name: test-container
    env:
    # Define the environment variable
    - name: SPECIAL_LEVEL_KEY
      valueFrom:
        configMapKeyRef:
          # ConfigMap containing the value you want to assign to SPECIAL_LEVEL_KEY
          name: special-config
          # Specify the key associated with the value
          key: special.how
```
**Configure all key-value pairs in a ConfigMap as container environment variables**
```yaml
containers:
  - name: test-container
    envFrom:
    - configMapRef:
        name: special-config
```

**Use configmap defined env variable in command**
```yaml
containers:
  - name: test-container
    image: k8s.gcr.io/busybox
    command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY)" ]
    env:
      - name: SPECIAL_LEVEL_KEY
        valueFrom:
          configMapKeyRef:
            name: special-config
            key: SPECIAL_LEVEL
```
**Populate a Volume with data stored in a ConfigMap**
```yaml
# ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  SPECIAL_LEVEL: very
  SPECIAL_TYPE: charm
---
# pod spec
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls /etc/config/" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        # Name of the ConfigMap containing the files you want
        # to add to the container
        name: special-config
```
- 2 files `SPECIAL_LEVEL` and `SPECIAL_TYPE` will be created in /etc/config. If there are some files in the /etc/config/ directory, they will be deleted
-  if you create a Kubernetes Volume from a ConfigMap, each data item in the ConfigMap is represented by an individual file in the volume

**Add ConfigMap data to a specific path in the Volume**
```yaml
spec:
  # ...same as above...
  volumes:
    - name: config-volume
      configMap:
        name: special-config
        items:
        - key: SPECIAL_LEVEL
          path: keys # creates file in /etc/config/keys
```

### Restrictions
- You must create a ConfigMap before referencing it in a Pod spec
- pod will not start, if:
  - reference a ConfigMap that doesn't exist
  - references to keys that don't exist in the ConfigMap
- while using `envFrom`
  - invalid keys are skipped 
  - pod will start with valid keys
  - but it will be logged in events(`InvalidVariableNames`) with list of such invalid keys skipped
- A ConfigMap can only be referenced by pods residing in the same namespace
- You can't use ConfigMaps for static pods, because the Kubelet does not support this

### References:
https://kubernetes.io/docs/concepts/configuration/configmap/
https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/