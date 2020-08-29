# Coredns
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors 
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```
- configmap options: https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#coredns-configmap-options

## configure stubdomain and nameserver
- use consul running at `10.150.0.1` as DNS server for domain names with suffix `consul.local`
- explicitly force all non-cluster DNS lookups to go through a specific nameserver at 172.16.0.1, point the forward to the nameserver instead of /etc/resolv.conf
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . 172.16.0.1
        cache 30
        loop
        reload
        loadbalance
    }
    consul.local:53 {
        errors
        cache 30
        forward . 10.150.0.1
    }
```

- resolve external name to the internal ClusterIP, avoiding the hairpin traffic(travel out of the cluster and then back in via the external IP). Use `rewrite` in Corefile in core-dns configmap.
```
.:53 {
    rewrite name foo.example.com foo.default.svc.cluster.local
    kubernetes cluster.local 10.0.0.0/24
    ...
}
```
- To let CoreDNS know that the Corefile has changed, send SIGUSR1 signal to tell it to reload graceful - that is, without loss of service
```
kubectl exec -n kube-system coredns-980047985-g2748 -- kill -SIGUSR1 1
```

### commands useful for troubleshooting
```
host kubernetes.default

nslookup kubernetes.default

dig kubernetes.default
```

### estimate the amount of memory required for a CoreDNS instance
- MB required (default settings) = (Number of Pods + Services) / 1000 + 54
- MB required (with autopath plugin) = (Number of Pods + Services) / 250 + 56

### We cannot exec into coredns pod
https://github.com/coredns/coredns/issues/3533

## References:
https://kubernetes.io/docs/tasks/administer-cluster/coredns/
https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/
https://coredns.io/2018/11/15/scaling-coredns-in-kubernetes-clusters/