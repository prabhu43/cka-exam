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

## References:
https://kubernetes.io/docs/tasks/administer-cluster/coredns/
https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/