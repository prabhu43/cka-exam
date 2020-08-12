- Do all steps as `root` user

### All nodes

**Install tools**
```shell
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

**Letting iptables see bridged traffic**
```shell
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

**Disable swap**
```shell
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab # comment the line having swap
```

### Master node

**Dryrun**
```shell
kubeadm init --kubernetes-version $(kubeadm version -o short) \
    --service-cidr 10.11.0.0/16 \
    --pod-network-cidr 10.12.0.0/16 \
    --dry-run
```

**Initialise cluster**
```shell
kubeadm init --kubernetes-version $(kubeadm version -o short) \
    --service-cidr 10.11.0.0/16 \
    --pod-network-cidr 10.12.0.0/16 \
    --apiserver-advertise-address 10.10.10.2
```
- Ensure apiserver is reachable from worker node using `telnet <apiserver-advertise-address> <apiserver-bind-port>`. Default port is 6443
- Copy and save the last few lines of output. (after `Your Kubernetes control-plane has initialized successfully!`). 
And do the steps mentioned in that as follows.

**Setup kubeconfig**
- For non-root user,
```shell
# taken from output from kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- For root user, this is enough
```shell
export KUBECONFIG=/etc/kubernetes/admin.conf
```

**Install network plugin**
```shell
# Use canal(calico + flannel)
# calico for network policy & flannel for networking
# memorise this url
curl https://docs.projectcalico.org/manifests/canal.yaml -O
kubectl apply -f canal.yaml
```

> coredns pods will be in `Pending` state till the network plugin is installed. So ensure coredns pods goes to `Running` state after installing network plugin

### Worker node

**Join worker node**
- run the `kubeadm join` command that was output by `kubeadm init`
```shell
kubeadm join <apiserver-advertise-address> --token <token> \
    --discovery-token-ca-cert-hash <sha>
```

> In case of issues, to troubleshoot, use `--v=2` in kubeadm join command

### References:
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/