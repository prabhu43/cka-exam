# Debug Services
### Does the Service exist?
### Does the Service work by DNS name?
```sh
nslookup SVC_NAME.NAMESPACE.CLUSTER_DOMAIN
nslookup nginx.default.svc.cluster.local
nslookup nginx.default.svc.cluster.local DNS_SERVICE_IP
# k8s master Service should always work
nslookup kubernetes.default
```

- If you are able to do a fully-qualified name lookup but not a relative one, you need to check that your `/etc/resolv.conf` file in your Pod is correct.
```
nameserver 10.0.0.10
search default.svc.cluster.local svc.cluster.local cluster.local example.com
options ndots:5
```
    - `nameserver` must indicate your cluster's DNS Service. passed into kubelet with the `--cluster-dns` flag

### Does the Service work by IP?

### Is the Service defined correctly?
- Is the Service port you are trying to access listed in spec.ports[]?
- Is the targetPort correct for your Pods (some Pods use a different port than the Service)?
- If you meant to use a numeric port, is it a number (9376) or a string "9376"?
- If you meant to use a named port, do your Pods expose a port with the same name?
- Is the port's protocol correct for your Pods

### Does the Service have any Endpoints?
kubectl get endpoints ${SERVICE_NAME}

```yaml
# list pods using the labels that Service uses
k get po -l=name=nginx,type=frontend
```
- If the list of pods matches expectations, but your endpoints are still empty, it's possible that you don't have the right ports exposed. 
- If your service has a `containerPort` specified, but the Pods that are selected don't have that port listed, then they won't be added to the endpoints list.
- Verify that the pod's `containerPort` matches up with the Service's `targetPort`

### Are the Pods working?
- use urls in `endpoints`

### Is the kube-proxy working?
- If you get here, your Service is running, has Endpoints, and your Pods are actually serving. At this point, the whole Service proxy mechanism is suspect. 

**Is kube-proxy running?**
- Confirm that kube-proxy is running on your Nodes. To check from node: `ps auxw | grep kube-proxy`
        
- Check logs for any errors. To check from node:
    - `journalctl kube-proxy` or `/var/log/kube-proxy.log`
- One of the possible reasons that kube-proxy cannot run correctly is that the required `conntrack` binary cannot be found. `sudo apt install conntrack`
- Kube-proxy can run in one of a few modes. 
    - In the logs, the line `Using iptables Proxier` indicates that kube-proxy is running in "iptables" mode. 
    - The most common other mode is "ipvs". 
    - The older "userspace" mode has largely been replaced.(deprecated)
- check iptables mode: `iptables-save | grep svc_name`
    - For each port of each Service, there should be 1 rule in `KUBE-SERVICES` and one `KUBE-SVC-<hash>` chain
- check IPVS mode: `ipvsadm -ln`
- check userspace mode: `iptables-save | grep svc_name`

**Is kube-proxy proxying?**
- only for userspace mode

**Edge case: A Pod fails to reach itself via the Service IP**
-  network is not properly configured for "hairpin" traffic, usually when kube-proxy is running in iptables mode and Pods are connected with bridge network
- Kubelet exposes a `hairpin-mode` flag that allows endpoints of a Service to loadbalance back to themselves if they try to access their own Service VIP. 
- Confirm hairpin-mode is set to `hairpin-veth` or `promiscuous-bridge`
    - check hairpin mode in kubelet from node: `ps auxw | grep kubelet`
- Confirm the effective `hairpin-mode`
    - Check if there is any log lines with key word hairpin in kubelet.log
    ```
    I0629 00:51:43.648698    3252 kubelet.go:380] Hairpin mode set to "promiscuous-bridge"
    ```
- If the effective hairpin mode is `hairpin-veth`, ensure the Kubelet has the permission to operate in `/sys` on node
- If the effective hairpin mode is `promiscuous-bridge`, ensure Kubelet has the permission to manipulate linux bridge on node



## References
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/