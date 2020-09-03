# Troubleshoot clusters

### Listing your cluster
```sh
# Ensure all nodes are in Ready state
k get nodes

# overall health of your cluster
k cluster-info dump
```

### Looking at logs

**Master**
`/var/log/kube-apiserver.log` - API Server, responsible for serving the API
`/var/log/kube-scheduler.log` - Scheduler, responsible for making scheduling decisions
`/var/log/kube-controller-manager.log` - Controller that manages replication controllers

**Worker Nodes**
`/var/log/kubelet.log` - Kubelet, responsible for running containers on the node
`/var/log/kube-proxy.log` - Kube Proxy, responsible for service load balancing

> on systemd-based systems, you may need to use journalctl instead

### A general overview of cluster failure modes 
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/#a-general-overview-of-cluster-failure-modes


## References
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/