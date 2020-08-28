# Service
- most commonly abstract access to Kubernetes Pods

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    # targets TCP port 9376 on any Pod with the app=MyApp label
    # exposes port 80
    - protocol: TCP # Supported protocols: TCP(default), UDP, HTTP, PROXY, SCTP
      port: 80
      targetPort: 9376 # If this is a string, it will be looked up as a named port in the target Pod's container ports. If this is not specified, the value of the 'port' field is used (an identity map)
```
- Kubernetes(service controller) assigns this Service an IP address (sometimes called the "cluster IP"), which is used by the Service proxies
- controller for the Service selector continuously scans for Pods that match its selector, and then POSTs any updates to an Endpoint object also named “my-service”
- Port definitions in Pods can have names, and you can reference these names in the `targetPort` attribute of a Service. using this, you can change the port numbers that Pods expose in the next version of your backend software, without breaking clients

***Service Without Selectors***
- abstract kinds of backends other than pods
**Scenarios**
- You want to have an external database cluster in production, but in your test environment you use your own databases
- You want to point your Service to a Service in a different Namespace or on another cluster
- You are migrating a workload to K8s. Whilst evaluating the approach, you run only a proportion of your backends in K8s

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```
- the corresponding Endpoint object is not created automatically
- manually map the Service to the network address and port where it's running, by adding an Endpoint object manually
```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
      # endpoint IPs must not be: loopback (127.0.0.0/8 for IPv4), or link-local (169.254.0.0/16 and 224.0.0.0/24 for IPv4)
      # Endpoint IP addresses cannot be the cluster IPs of other Kubernetes Services, because kube-proxy doesn't support virtual IPs as a destination
      - ip: 192.0.2.42 
    ports:
      - port: 9376
```
- An ExternalName Service is a special case of Service that does not have selectors and uses DNS names instead


**EndpointSlices**
- more scalable alternative to Endpoints
- allow for distributing network endpoints across multiple resources
- By default, an EndpointSlice is considered "full" once it reaches 100 endpoints


### Virtual IPs and service proxies
Every node in a k8s cluster runs a kube-proxy. kube-proxy is responsible for implementing a form of virtual IP for Services of type other than ExternalName
- proxy modes: 
  - iptables
    - chooses a backend at random
  - userspace
    - chooses a backend via a round-robin algorithm

### Multi-Port Services
- ports names should be unambiguous
- As with Kubernetes names in general, names for ports must only contain lowercase alphanumeric characters and -. Port names must also start and end with an alphanumeric character

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 9376
    - name: https
      protocol: TCP
      port: 443
      targetPort: 9377
```

### Choosing your own IP address
- set the `.spec.clusterIP` field
- must be a valid IPv4 or IPv6 address from within the service-cluster-ip-range CIDR range that is configured for the API server
- If you try to create a Service with an invalid clusterIP address value, the API server will return a 422 HTTP status code to indicate that there's a problem

### Discovering services
**Environment Variables**
- When a Pod is run on a Node, the kubelet adds a set of environment variables for each active Service (within same namespace)
- Add `{SVCNAME}_SERVICE_HOST` and `{SVCNAME}_SERVICE_PORT` variables; Service name is upper-cased and dashes are converted to underscores
- must create the Service before the client Pods come into existence. Otherwise, those client Pods won't have their environment variables populated

**DNS**
- can setup DNS service using an add-on
- cluster-aware DNS server, such as CoreDNS, watches the K8s API for new Services and creates a set of DNS records for each one
- Example: Service `my-service` in `my-ns` namespace
  - Access within same namespace: `my-service` is enough, `my-service.my-ns` also works
  - Access from other namespace: `my-service.my-ns`
- also supports DNS SRV (Service) records for named ports
  - port named `http` with protocol `TCP`
    - you can do a DNS SRV query for `_http._tcp.my-service.my-ns` to discover the port number for "http", as well as the IP address
- Kubernetes DNS server is the only way to access ExternalName Services
- FQDN: <svcname>.<namespace>.svc.<cluster_domain> 
- cluster domain: default is `cluster.local`
  - can be found at `networking.dnsDomain` in kubeadm config map

### Headless Services
- set `.spec.clusterIP` to `None`
- no loadbalancing and no single service IP
  - can do client side loadbalancing (will get IPs of all pods behind it)
- kube-proxy does not handle these Services
- `with selectors`: endpoints controller creates Endpoints records in the API, and modifies the DNS configuration to return records (addresses) that point directly to the Pods backing the Service
- `without selectors`: endpoints controller does not create Endpoints records
  - CNAME records for ExternalName-type Services

### Publishing Services
- ClusterIP(Default)
  - cluster-internal IP
- NodePort: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting `<NodeIP>:<NodePort>`
- LoadBalancer: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created
- ExternalName: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value
```
k create svc externalname google --external-name google.com
```

### DNS for pods
https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pods

## References:
https://kubernetes.io/docs/concepts/services-networking/service
https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pods