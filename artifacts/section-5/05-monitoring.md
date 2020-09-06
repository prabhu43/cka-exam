# Monitoring

## Resource metrics pipeline

- Resource usage metrics, such as `container CPU` and `memory usage`, are available in Kubernetes through the Metrics API

- These metrics can be either accessed directly by user, for example by using kubectl top command, or used by a controller in the cluster, e.g. Horizontal Pod Autoscaler, to make decisions

**CPU**
- average usage, in CPU cores, over a period of time.
- kubelet chooses the window for the rate calculation
- value is derived by taking a rate over a cumulative CPU counter provided by the kernel 

**Memory**
- working set, in bytes, at the instant the metric was collected
- `working set` is the amount of memory in-use that cannot be freed under memory pressure

**Metrics API**
- Through the Metrics API, you can get the amount of resource currently used by a given node or a given pod. 

- This API doesn't store the metric values

- it is discoverable through the same endpoint as the other Kubernetes APIs under /apis/metrics.k8s.io/ path

- this API requires `metrics server` to be deployed in the cluster. Otherwise it will be not available.

**Metrics server**
- a cluster-wide aggregator of resource usage data

- collects metrics from the Summary API, exposed by Kubelet on each node.

- registered with the main API server through Kubernetes aggregator.

## Monitor Node Health
- Node problem detector is a DaemonSet monitoring the node health. It collects node problems from various daemons and reports them to the apiserver as NodeCondition and Event
- Node problem detector running as a cluster addon enabled by default in the gce cluster.

**Limitations**
- The kernel issue detection of node problem detector only supports file based kernel log now. It doesn't support log tools like journald
- The kernel issue detection of node problem detector has assumption on kernel log format, and now it only works on Ubuntu and Debian. However, it is easy to extend it to support other log format

**Install node problem detector via kubectl**
```yaml
# k apply -f https://k8s.io/examples/debug/node-problem-detector.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-problem-detector-v0.1
  namespace: kube-system
  labels:
    k8s-app: node-problem-detector
    version: v0.1
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    matchLabels:
      k8s-app: node-problem-detector  
      version: v0.1
      kubernetes.io/cluster-service: "true"
  template:
    metadata:
      labels:
        k8s-app: node-problem-detector
        version: v0.1
        kubernetes.io/cluster-service: "true"
    spec:
      hostNetwork: true
      containers:
      - name: node-problem-detector
        image: k8s.gcr.io/node-problem-detector:v0.1
        securityContext:
          privileged: true
        resources:
          limits:
            cpu: "200m"
            memory: "100Mi"
          requests:
            cpu: "20m"
            memory: "20Mi"
        volumeMounts:
        - name: log
          mountPath: /log
          readOnly: true
      volumes:
      - name: log
        hostPath:
          path: /var/log/
```
**Addon Pod in master nodes**
- Just create `node-problem-detector.yaml`, and put it under the addon pods directory /etc/kubernetes/addons/node-problem-detector on master node
- This is for those who have their own cluster bootstrap solution, and don't need to overwrite the default configuration. They could leverage the addon pod to further automate the deployment

**Overwrite the Configuration**
-  default configuration is embedded when building the Docker image of node problem detector
- However, you can use ConfigMap to overwrite it as follows:
    - Change the config files in `config/` directory in pod
    - `kubectl create configmap node-problem-detector-config --from-file=config/`
    - Change the node-problem-detector.yaml to use the ConfigMap
    ```yaml
    spec:
        ...
        volumeMounts:
        - name: log
          mountPath: /log
          readOnly: true
        - name: config # Overwrite the config/ directory with ConfigMap volume
          mountPath: /config
          readOnly: true
      volumes:
      - name: log
        hostPath:
          path: /var/log/
      - name: config # Define ConfigMap volume
        configMap:
          name: node-problem-detector-config
    ```
- this approach only applies to node problem detector started with kubectl
- For node problem detector running as cluster addon, because addon manager doesn't support ConfigMap, configuration overwriting is not supported now

### Kernel Monitor
- Kernel Monitor is a problem daemon in node problem detector. It monitors kernel log and detects known kernel issues following predefined rules.
- it matches kernel issues according to a set of predefined rule list in config/kernel-monitor.json
- The rule list is extensible, and you can always extend it by overwriting the configuration

**Add New NodeConditions**
- To support new node conditions, you can extend the conditions field in config/kernel-monitor.json with new condition definition:
```json
{
  "type": "NodeConditionType",
  "reason": "CamelCaseDefaultNodeConditionReason",
  "message": "arbitrary default node condition message"
}
```

**Detect New Problems**
- To detect new problems, you can extend the rules field in config/kernel-monitor.json with new rule definition:

```json
{
  "type": "temporary/permanent",
  "condition": "NodeConditionOfPermanentIssue",
  "reason": "CamelCaseShortReason",
  "message": "regexp matching the issue in the kernel log"
}
```

**Change log path**

- `log` field in `config/kernel-monitor.json` is the log path inside the container
-  configure it to match your OS distro

**Support Other Log Format**
- Kernel monitor uses Translator plugin to translate kernel log the internal data structure. It is easy to implement a new translator for a new log format

### Caveats
- It is recommended to run the node problem detector in your cluster to monitor the node health. However, you should be aware that this will introduce extra resource overhead on each node. 
- Usually this is fine, because:
    - The kernel log is generated relatively slowly
    - Resource limit is set for node problem detector
    - Even under high load, the resource usage is acceptable

## References:
https://kubernetes.io/docs/tasks/debug-application-cluster/monitor-node-health/