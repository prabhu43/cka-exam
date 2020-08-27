# Ingress
- An API object that manages external access to the services in a cluster, typically HTTP
- provides loadbalancing, ssl termination, name-based virtual hosting
- exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.
- Traffic routing is controlled by rules defined on the Ingress resource
- Before v1.18, Ingress classes were specified with a `kubernetes.io/ingress.class` annotation on the Ingress
    - From v1.18, it is deprecated. instead use `ingressClassName` field in `ingress.spec`. - assign the name of a `IngressClass` Resource to `ingressClassName` field
    - Mark a IngressClass as default by annotation `ingressclass.kubernetes.io/is-default-class: true` in IngressClass 

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  annotations: # annotations are used by corresponding ingress controllers.
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix # ImplementationSpecific(default), Exact, Prefix
        backend:
          serviceName: test
          servicePort: 80
```

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: IngressClass
metadata:
  name: external-lb # equivalent to annotation value in old version
spec:
  controller: example.com/ingress-controller # some name to represent ingress controller
  parameters: # parameters to ingress controller, optional field
    apiGroup: k8s.example.com/v1alpha
    kind: IngressParameters
    name: external-lb
```

### single service ingress
```yaml
spec:
  backend: # default backend used in case of no rules match
    serviceName: testsvc
    servicePort: 80
```

### Simple fanout
```yaml
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo # foo.bar.com/foo will be routed to "service1"
        backend:
          serviceName: service1
          servicePort: 4200
      - path: /bar # foo.bar.com/bar will be routed to "service2"
        backend:
          serviceName: service2
          servicePort: 8080
```

### Name based virtual hosting
```yaml
spec:
  rules:
  - host: foo.bar.com
    http: # traffic requested for "foo.bar.com" will be routed to "service1"
      paths:
      - backend:
          serviceName: service1
          servicePort: 80
  - host: bar.foo.com
    http: # traffic requested for "bar.foo.com" will be routed to "service2"
      paths:
      - backend:
          serviceName: service2
          servicePort: 80
  - http: # any traffic to the IP address without a hostname defined in request(no request header for Host) sent to "service3"
      paths:
      - backend:
          serviceName: service3
          servicePort: 80
```

### TLS
- only supports a single TLS port(443) and assumes TLS termination
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: testsecret-tls
  namespace: default
data:
  tls.crt: base64 encoded cert # TLS certificate: common name of the certificate should be the hostname
  tls.key: base64 encoded key # TLS private key
type: kubernetes.io/tls
```

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls:
  - hosts:
      - sslexample.foo.com
    secretName: testsecret-tls
  rules:
  - host: sslexample.foo.com
    http:
      paths:
      - path: /
        backend:
          serviceName: service1
          servicePort: 80
```
## References:
https://kubernetes.io/docs/concepts/services-networking/ingress/
https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#support-for-hostname-wildcards

