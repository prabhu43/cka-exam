### Nodes

- components of a node:
    - kubelet
    - kube-proxy
    - container runtime
- two main ways to have Nodes added to the API server
    - The kubelet on a node self-registers to the control plane
    - You, or another human user, manually add a Node object
- To mark a Node unschedulable, run: `kubectl cordon $NODENAME`
- Node status: `kubectl describe node $NODENAME`
- Node status contains:
    - Addresses: InternalIP, ExternalIP, Hostname
    - Conditions: Ready, DiskPressure, MemoryPressure, PIDPressure, NetworkUnavailable, ...
    - Capacity and Allocatable: CPU, memory and maximum no of pods that can be scheduled
    - Info: kernel version, k8s version (kubelet and kube-proxy version), Docker version (if used), and OS name
- `node-monitor-grace-period`: argument to kube-controller-manager
    - default is 40 seconds
    - Set `Ready` condition to `Unknown` if the node controller has not heard from the node in the last `node-monitor-grace-period` time
- `pod-eviction-timeout`: argument to kube-controller-manager
    - default is 5 minutes
    - If Status of the Ready condition remains Unknown or False for longer than this time, all the Pods on the node are scheduled for deletion by the node controller.

- node controller
    - assigning a CIDR block to the node when it is registered
    - keeping the node controller's internal list of nodes up to date with the cloud provider's list of available machines
    - monitoring the nodes' health. 
        - it is responsible for updating the NodeReady condition of NodeStatus.
        - checks the state of each node every `--node-monitor-period` seconds(Default: 5 seconds)
- 2 forms of heartbeats
    - NodeStatus: kubelet updates it; default interval is 5 minutes
    - Lease object: kubelet creates and then updates its Lease object every 10 seconds

## References
https://kubernetes.io/docs/concepts/architecture/nodes/
https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/


## Questions:
- who assigns ips to pod?
- what is flannel responsible for?