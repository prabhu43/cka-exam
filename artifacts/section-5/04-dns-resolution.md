# Debugging DNS Resolution
```sh
k run utils --image arunvelsriram/utils -- sleep 1d

k exec -it utils -- nslookup kubernetes.default
```

### If the nslookup command fails, check the following:

**Check the local DNS configuration first**

```sh
k exec -it utils -- cat /etc/resolv.conf
# nameserver 10.96.0.10
# search default.svc.cluster.local svc.cluster.local cluster.local
# options ndots:5
```

**Check if the DNS pod is running**
```sh
k get po -n kube-system -l=k8s-app=kube-dns
```
- The value for label `k8s-app` is `kube-dns` for both CoreDNS and kube-dns deployments
- ensure core-dns or kube-dns pods running

**Check for errors in the DNS pod**
```sh
k logs -n kube-system -l=k8s-app=kube-dns
```

**Is DNS service up?**
```sh
k get svc kube-dns -n kube-system
```
- The service name is kube-dns for both CoreDNS and kube-dns deployments.


**Are DNS endpoints exposed?**
```sh
k get endpoints kube-dns -n kube-system
```

**Are DNS queries being received/processed?**
- verify if queries are being received by CoreDNS by adding the `log` plugin to the CoreDNS configuration (aka Corefile)
- The CoreDNS Corefile is held in a ConfigMap named `coredns`
- After saving the changes, it may take up to minute or two for Kubernetes to propagate these changes to the CoreDNS pods(no need to restart pods)
- make some dns queries and view the logs
```sh
# sample logs
2018/09/07 15:29:04 [INFO] plugin/reload: Running configuration MD5 = 162475cdf272d8aa601e6fe67a6ad42f
2018/09/07 15:29:04 [INFO] Reloading complete
172.17.0.18:41675 - [07/Sep/2018:15:29:11 +0000] 59925 "A IN kubernetes.default.svc.cluster.local. udp 54 false 512" NOERROR qr,aa,rd,ra 106 0.000066649s
```
### Known issues
**systemd-resolved issue**

- some linux disto like ubuntu use a local DNS resolver by default (systemd-resolved)
- Systemd-resolved moves and replaces /etc/resolv.conf with a stub file that can cause a fatal forwarding loop when resolving names in upstream servers
- this can be fixed manually by using kubelet's --resolv-conf flag to point to the correct resolv.conf (With systemd-resolved, this is /run/systemd/resolve/resolv.conf)
- kubeadm automatically detects `systemd-resolved`, and adjusts the kubelet flags accordingly

**nameserver records limit**
- Linux's libc (a.k.a. glibc) has a limit for the DNS nameserver records to 3 by default
- for glibc versions which are older than glibc-2.17-222 , allowed number of DNS search records has been limited to 6
- k8s needs to consume 1 nameserver record and 3 search records
- To work around the DNS nameserver records limit, the node can run `dnsmasq`, which will provide more nameserver entries. You can also use kubelet's `--resolv-conf` flag
- To fix the DNS search records limit, consider upgrading your linux distribution or upgrading to an unaffected version of glibc