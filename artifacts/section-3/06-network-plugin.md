### Network Plugins

Network plugins in Kubernetes come in a few flavors:
    - CNI plugins: adhere to the appc/CNI specification, designed for interoperability.
    - Kubenet plugin: implements basic cbr0 using the bridge and host-local CNI plugin

##### Configure network plugin here:
Configure cni type network:
```sh
cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--network-plugin=cni"
```
kubelet --cni-conf-dir (default /etc/cni/net.d)
```sh
ls /etc/cni/net.d/
10-canal.conflist  calico-kubeconfig
```

### Usage Summary
- --network-plugin=cni specifies that we use the cni network plugin with actual CNI plugin binaries located in --cni-bin-dir (default /opt/cni/bin) and CNI plugin configuration located in --cni-conf-dir (default /etc/cni/net.d).
- --network-plugin=kubenet specifies that we use the kubenet network plugin with CNI bridge and host-local plugins placed in /opt/cni/bin or cni-bin-dir.
- --network-plugin-mtu=9001 specifies the MTU to use, currently only used by the kubenet network plugin.

### References
https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/