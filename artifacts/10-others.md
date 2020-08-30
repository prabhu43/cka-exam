## Feature gates:
https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/

### Feature stages:
- alpha: disabled by default, can be enabled by FeatureGate
- beta: enabled by default, can be disabled by FeatureGate
- GA: always enabled, cannot disable

## Pod Preset:
- alpha feature; disabled by default
https://kubernetes.io/docs/concepts/workloads/pods/podpreset/
https://kubernetes.io/docs/tasks/inject-data-application/podpreset/

## Ephemeral Containers
- alpha feature; disabled by default
- a special type of container that runs temporarily in an existing Pod to accomplish user-initiated actions such as troubleshooting. 
- use it to inspect services rather than to build applications
- `k alpha debug -h`
https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/#debugging-with-ephemeral-debug-container


## Encrypt Data at Rest
https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

## Downward API
https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/#capabilities-of-the-downward-api

### two ways to expose Pod and Container fields to a running Container:
- Environment variables
- Volume Files

### Following info available to containers through both environment variables and volumes

**Information available via fieldRef**
- metadata.name - the pod's name
- metadata.namespace - the pod's namespace
- metadata.uid - the pod's UID
- metadata.labels['<KEY>'] - the value of the pod's label <KEY> (for example, metadata.labels['mylabel'])
- metadata.annotations['<KEY>'] - the value of the pod's annotation <KEY> (for example, metadata.annotations['myannotation'])

**Information available via resourceFieldRef**
- A Container's CPU limit
- A Container's CPU request
- A Container's memory limit
- A Container's memory request
- A Container's ephemeral-storage limit
- A Container's ephemeral-storage request

### Following info available through `downwardAPI` volume `fieldRef`
- metadata.labels - all of the pod's labels, formatted as label-key="escaped-label-value" with one label per line
- metadata.annotations - all of the pod's annotations, formatted as annotation-key="escaped-annotation-value" with one annotation per line

### Following info available through env variables
- status.podIP - the pod's IP address
- spec.serviceAccountName - the pod's service account name
- spec.nodeName - the node's name
- status.hostIP - the node's IP