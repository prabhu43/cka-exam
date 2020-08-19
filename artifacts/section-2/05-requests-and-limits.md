##### Understand how resource limit affects the pod scheduling

###### Memory
```yaml
#configure containers in pod.yaml
spec:
  containers:
  - name: memory-demo-ctr
    image: polinux/stress
    resources:
      limits:
        memory: "200Mi"
      requests:
        memory: "100Mi"
```
- If a Container allocates more memory than its limit, the Container becomes a candidate for termination. If the Container continues to consume memory beyond its limit, the Container is terminated (OOMKilled)
- Memory requests and limits are associated with Containers, but it is useful to think of a Pod as having a memory request and limit.
- A Pod is scheduled to run on a Node only if the Node has enough available memory to satisfy the Pod's memory request. (Pending State)
- The memory resource is measured in bytes. You can express memory as a plain integer or a fixed-point integer with one of these suffixes: E, P, T, G, M, K, Ei, Pi, Ti, Gi, Mi, Ki. Eg: 128974848, 129e6, 129M , 123Mi
- The Container is running in a namespace that has a default memory limit, and the Container is automatically assigned the default limit (k get LimitRange)

#### CPU

```yaml
#configure containers in pod.yaml
spec:
  containers:
  - name: cpu-demo-ctr
    image: vish/stress
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "0.5"
```
```sh
# to see the current memory and cpu usage
kubectl top pod pod-name
```

- The CPU resource is measured in CPU units. One CPU, in Kubernetes, is equivalent to:
    - 1 AWS vCPU
    - 1 GCP Core
    - 1 Azure vCore
    - 1 Hyperthread on a bare-metal Intel processor with Hyperthreading
- CPU is always requested as an absolute quantity, never as a relative quantity; 0.1 is the same amount of CPU on a single-core, dual-core, or 48-core machine.

#### Configure Default Memory/CPU Requests and Limits for a Namespace and Max/Min Requests/Limits for a Container/Pod
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
      cpu: "1"
    defaultRequest:
      memory: 256Mi
      cpu: 500m
    max:
      memory: 512Mi
      cpu: 2
    min:
      memory: 100Mi
      cpu: 0.2
    type: Container
```

#### Configure Memory and CPU Quotas and PodQuota for a Namespace
- constraint for sum of all containers in that namespace
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-demo
spec:
  hard:
    pods: "2"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```
We can get the current status in the status field in same object
```yaml
status:
  hard:
    pods: "2"
    limits.cpu: "2"
    limits.memory: 2Gi
    requests.cpu: "1"
    requests.memory: 1Gi
  used:
    pods: "1"
    limits.cpu: 800m
    limits.memory: 800Mi
    requests.cpu: 400m
    requests.memory: 600Mi
```

##### Reference:
https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/
https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/
https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/