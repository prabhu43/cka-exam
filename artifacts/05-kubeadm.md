## Setup single control-plane cluster

#### Initialize cluster
- `kubeadm init --kubernetes-version $(kubeadm version -o short)`

`--apiserver-advertise-address` can be used to set the advertise address for this particular control-plane node's API server

```
# init command with more options
kubeadm init --service-cidr {{ service_cidr }} \
                 --pod-network-cidr {{ pod_network_cidr }} \
                 --token-ttl 1m \
                 --apiserver-advertise-address {{ master_ip }} \
                 --apiserver-cert-extra-sans {{ default_network_ip }} \
                 {{ kubeadm_opts }} \
                 {{ init_opts }}
```

#### Join worker node
- `kubeadm token create --ttl 1m --print-join-command` (in master node) 
- execute the output of above command in worker node (kubeadm join)

## Setup HA control-plane cluster
#### Create load balancer for kube-apiserver

#### Initialize cluster
```
sudo kubeadm init \
    --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" \
    --upload-certs
```
`--control-plane-endpoint` can be used to set the shared endpoint for all control-plane nodes

> Turning a single control plane cluster created without --control-plane-endpoint into a highly available cluster is not supported by kubeadm.

Copy the output to a text file. You will need it later to join control plane and worker nodes to the cluster.

#### Join another control plane node to HA cluster
```
kubeadm join <APISERVER> \
    --control-plane \
    --token <TOKEN>
```

#### Join worker node to make
```
kubeadm join <APISERVER_IP> --token <TOKEN>
```

## Tear down
- kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
- kubeadm reset

> To run `kubeadm init` or `kubeadm join` again, you must first tear down the cluster.

## Upgrade cluster

**On First Control Plane Node**
- Upgrade kubeadm
- Drain the control plane node: 
`kubectl drain <cp-node-name> --ignore-daemonsets`
- `kubeadm upgrade plan`
- `kubeadm upgrade apply <new_version>`
- `kubectl uncordon <cp-node-name>`
- Upgrade kubelet and kubectl

**On Other Control Plane Nodes**
- Upgrade kubeadm
- Drain the control plane node: 
`kubectl drain <cp-node-name> --ignore-daemonsets`
- `kubeadm upgrade node`
- `kubectl uncordon <cp-node-name>`
- Upgrade kubelet and kubectl

**On Worker Nodes**
- Upgrade kubeadm
- Drain the worker node: 
`kubectl drain <node-to-drain> --ignore-daemonsets`
- Upgrade Kubelet configuration
`kubeadm upgrade node`
- Upgrade kubelet and kubectl

## Common Kubeadm cmdlets
- **kubeadm init** to bootstrap the initial Kubernetes control-plane node.
- **kubeadm join** to bootstrap a Kubernetes worker node or an additional control plane node, and join it to the cluster.
- **kubeadm upgrade** to upgrade a Kubernetes cluster to a newer version.
- **kubeadm reset** to revert any changes made to this host by kubeadm init or kubeadm join.

## Some Commands
* Initializes cluster master node:
```
kubeadm init \
    --apiserver-advertise-address $(hostname -i) \
    --pod-network-cidr 10.5.0.0/16
```
* Invoke single phase of the init workflow
```
kubeadm init phase
```
> All phases of kubeadm init can be found in `kubectl init --help`
* Re-upload the certificates from control plane node
```
kubeadm init phase upload-certs --upload-certs
```
* Generate kubeconfig for a user
```
kubeadm alpha kubeconfig user \
    --client-name <username> \
    --apiserver-advertise-address <advertise_address>
```
* Pull images required for setting up a Kubernetes cluster
```
kubeadm config images pull
```
* Print a list of images kubeadm will use
```
kubeadm config images list
```
* Print default init configuration, that can be used for 'kubeadm init'
Prints `ClusterConfiguration` & `InitConfiguration`
```
kubeadm config print init-defaults
```
* Print default join configuration, that can be used for 'kubeadm join' 
Prints `JoinConfiguration`
```
kubeadm config print join-defaults
```
* View kubeadm config `ClusterConfiguration`
```
kubeadm config view
```
* Create a bootstrap token and also print the join command
```
kubeadm token create --print-join-command --ttl 1m
```


## References:
- https://kubernetes.io/docs/reference/setup-tools/kubeadm/
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/