#### Awarness of manifest management and common templating tools

##### Imperative

```sh
# create pod
k run busybox --image busybox -- sleep 1d
# create deployment
k create deployment busybox --image busybox -- sleep 1d
# create service
k expose rc/rs/deploy/pod/pod.yaml nginx --port=80 --target-port=8000
k create service --help
# autoscale
k autoscale deployment foo --min=2 --max=10 --cpu-percent=75%
# add label
k label pods foo unhealthy=true
# add annotation
k annotate pods foo unhealthy=true
# scale
k scale deployment foo --replicas 4
# set image
k set image --help # we can set all containers across pods also
# set environment
k set env --help
# set resources
k set resources --help
# set 
k set selector/sa/subject # looks not very useful
# edit before creating
k run busybox --image busybox --dry-run=client -oyaml -- sleep 1d | k create --edit -f -
```

#### Imperative using config files
```sh
# create
k create -f pod.yaml
kubectl create -f <url> --edit
# update
k replace -f pod.yaml
# delete
k delete -f pod.yaml
```

###### Limitations of replace:
The create, replace, and delete commands work well when each object's configuration is fully defined and recorded in its configuration file. However when a live object is updated, and the updates are not merged into its configuration file, the updates will be lost the next time a replace is executed. This can happen if a controller, such as a HorizontalPodAutoscaler, makes updates directly to a live object. Here's an example:

- You create an object from a configuration file.
- Another source updates the object by changing some field.
- You replace the object from the configuration file. Changes made by the other source in step 2 are lost.

If you need to support multiple writers to the same object, you can use `kubectl apply` to manage the object.

#### Declarative using config files
```sh
kubectl apply -f <directory>/
# add -R to recursive process directory
```

`Nice to have:` [how-apply-calculates-differences-and-merges-changes](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/#how-apply-calculates-differences-and-merges-changes)

#### Declaration using kustomize

https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

#### Kubectl patch

```sh
# Partially update a node using a strategic merge patch. Specify the patch as JSON.
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'

# Partially update a node using a strategic merge patch. Specify the patch as YAML.
kubectl patch node k8s-node-1 -p $'spec:\n unschedulable: true'

# Partially update a node identified by the type and name specified in "node.json" using strategic merge patch.
kubectl patch -f node.json -p '{"spec":{"unschedulable":true}}'

# Update a container's image; spec.containers[*].name is required because it's a merge key.
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# Update a container's image using a json patch with positional arrays.
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"newimage"}]'

# patch with custom file
kubectl patch deployment patch-demo --patch "$(cat patch-file.yaml)"
```

#### References:
- All 5 links in https://kubernetes.io/docs/tasks/manage-kubernetes-objects/