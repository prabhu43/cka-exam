#### Liveness probe:
If this probe fail, kubelet will restart the container
```sh
# to know all the fields
kubectl explain pod.spec.containers.livenessProbe --recursive
```
```yaml
exec <Object> # kubelet executes the command
    command   <[]string> # If the command returns a non-zero value, the kubelet kills the container and restarts it.
failureThreshold     <integer>
httpGet      <Object> # Any code greater than or equal to 200 and less than 400 indicates success. 
    host      <string> # default podIP (use 127.0.0.1 for hostNetwork)
    httpHeaders       <[]Object>
        name   <string>
        value  <string>
    path      <string> # eg: /healthz
    port      <string> # eg: 8080 or named-port
    scheme    <string> # eg: http/https. the kubelet sends an HTTPS request skipping the certificate verification
initialDelaySeconds  <integer>
periodSeconds        <integer>
successThreshold     <integer>
tcpSocket    <Object>
    host      <string> # cannot use a service name in the host parameter since the kubelet is unable to resolve it
    port      <string>
timeoutSeconds       <integer>
```

#### Readiness probe:
If this probe fail, kubelet will mark the pod as not ready.

Same configuration as livenessProbe.

#### Startup probe:
StartupProbe indicates that the Pod has successfully **initialized**. If specified, **no other probes are executed until this completes successfully**. If this probe fails, the Pod will be restarted, just as if the livenessProbe failed. 

Same configuration as livenessProbe.

#### Avoid Pods being placed into a single node
- pod anti-affinity (two pods with same label can be scheduled in different nodes)
```sh
k explain pod.spec.affinity.podAntiAffinity --recursive
```

- pod affinity (pod can be scheduled only when another dependency pod is running)
```sh
k explain pod.spec.affinity.podAffinity --recursive
```

#### Avoid many pods of my delpoyment getting deleted during node upgrades/downscale
 A **PodDisruptionBudget** limits the number of Pods of a replicated application that are down simultaneously from voluntary disruptions.

 - If you set maxUnavailable to 0% or 0, or you set minAvailable to 100% or the number of replicas, you are requiring zero voluntary evictions. When you set zero voluntary evictions for a workload object such as ReplicaSet, then you cannot successfully drain a Node running one of those Pods. If you try to drain a Node where an unevictable Pod is running, the drain never completes. This is permitted as per the semantics of PodDisruptionBudget.

```yaml
 # Example
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: zk-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: zookeeper
```

- k get pdb <pdb-name> to see the status like below:
```yaml
NAME     MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
zk-pdb   2               N/A               0                     7s
```

#### Set an appropriate Quality of Service (QoS) for Pods
- Guaranteed
    - CPU request = CPU limit for all containers
    - Memory request = Memory limit for all containers
- Burstable
    - At least one Container in the Pod has a memory or CPU request
- BestEffort
    - No requests in any container

We can see the QoS in the status object in the pod

```
k get pod -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

References:
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- https://learnk8s.io/production-best-practices
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity
- https://kubernetes.io/docs/concepts/workloads/pods/disruptions/