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