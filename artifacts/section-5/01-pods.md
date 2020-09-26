## Init containers

**Init Container Status**
kubectl get pod nginx --template '{{.status.initContainerStatuses}}'

**Access logs**
kubectl logs <pod-name> -c <init-container-2>

**Pod status**
`Init:N/M` - The Pod has M Init Containers, and N have completed so far
`Init:Error` - An Init Container has failed to execute
`Init:CrashLoopBackOff` - An Init Container has failed repeatedly
`Pending` - The Pod has not yet begun executing Init Containers
`PodInitializing` or `Running`	- The Pod has already finished executing Init Containers

Note: InitContainers will run in sequence. If there are 4 init containers, one by one will run. After all are completed only, pod will go PodInitializing/Running status

## Determine the Reason for Pod Failure

**Writing and reading a termination message**
- Termination messages provide a way for containers to write information about fatal events to a location where it can be easily retrieved and surfaced by tools like dashboards and monitoring software
-  kubelet truncates messages that are longer than 4096 bytes. The total message length across all containers will be limited to 12KiB

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: termination-demo
spec:
  containers:
  - name: termination-demo-container
    image: debian
    command: ["/bin/sh"]
    args: ["-c", "sleep 10 && echo Sleep expired > /dev/termination-log"]
    terminationMessagePath: "/dev/termination-log" # this is default; can be changed
```
```yaml
apiVersion: v1
 kind: Pod
 ...
     lastState:
       terminated:
         containerID: ...
         exitCode: 0
         finishedAt: ...
         message: |
           Sleep expired
         ...
```

- `terminationMessagePolicy` field of a Container
    - `File`(default): termination messages are retrieved only from the termination message file
    - `FallbackToLogsOnError`: last chunk of container log output if the termination message file is empty and the container exited with an error
    - log output is limited to 2048 bytes or 80 lines, whichever is smaller

## Debugging pods
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/#debugging-pods

## Debug Running Pods

#### Examining pod logs
```sh
kubectl logs ${POD_NAME} ${CONTAINER_NAME}

# If container has previously crashed, access the previous container's crash log
kubectl logs -p ${POD_NAME} ${CONTAINER_NAME} 
```

#### Debugging with container exec

```sh
kubectl exec ${POD_NAME} -c ${CONTAINER_NAME} -- ${CMD} ${ARG1} ${ARG2} ... ${ARGN}
# -c ${CONTAINER_NAME} is optional. Can omit it for Pods with a single container

# look at the logs from a running Cassandra pod
kubectl exec cassandra -- cat /var/log/cassandra/system.log

# run a shell that's connected to your terminal using the -i and -t arguments
kubectl exec -it cassandra -- sh
```

#### Debugging with an ephemeral debug container
- alpha feature
- require the `EphemeralContainers` feature gate enabled in your cluster
- Ephemeral containers are useful for interactive troubleshooting when kubectl exec is insufficient because a container has crashed or a container image doesn't include debugging utilities, such as with distroless images
- kubectl has an alpha command that can create ephemeral containers for debugging beginning with version v1.18

```sh
kubectl run ephemeral-demo --image=k8s.gcr.io/pause:3.1 --restart=Never

# you will see an error because there is no shell in this container image
kubectl exec -it ephemeral-demo -- sh 


kubectl alpha debug -it ephemeral-demo --image=busybox --target=ephemeral-demo
# --target parameter targets the process namespace of another container. it must be supported by the Container Runtime
# It's necessary here because kubectl run does not enable process namespace sharing in the pod it creates
```
- refer `kubectl alpha debug -h` for more examples

## References
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-init-containers/
https://kubernetes.io/docs/tasks/debug-application-cluster/determine-reason-pod-failure/
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-pod-replication-controller/