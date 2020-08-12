### Upgrading kubeadm clusters

- All containers are restarted after upgrade, because the container spec hash value is changed

**Allowed upgrades**
- one minor version to next minor version. (1.y to 1.y+1)
    - Eg: 1.17 can be upgraded to 1.18, but not to 1.19
- between patch versions of same minor version. (1.x.y to 1.x.z)
    - Eg: 1.18.1 can be upgraded to 1.18.2
    
#### Steps to upgrade 1.17 to 1.18

**First Master Node**
- Decide the desired version 
  ```shell
  apt update
  ## Show all versions of kubeadm
  apt-cache madison kubeadm
  
  # find the latest 1.18 version in the list
  # it should look like 1.18.x-00, where x is the latest patch
  # Found version `1.18.6-00`
  ```

- Download kubeadm of desired version
  ```shell
  apt-mark unhold kubeadm && \
  apt-get update && apt-get install -y kubeadm=1.18.6-00 && \
  apt-mark hold kubeadm
  ```
- Check kubeadm has expected version `kubeadm version`
- Drain a control plane node
  ```shell
  # replace <cp-node-name> with the name of your control plane node
  kubectl drain <cp-node-name> --ignore-daemonsets
  ```
- See the plan for upgrade and ensure no errors
  ```shell
  sudo kubeadm upgrade plan
  ```
- Upgrade: `sudo kubeadm upgrade apply v1.18.6`

> `kubeadm upgrade` also automatically renews the certificates that it manages on this node. To opt-out of certificate renewal, the flag `--certificate-renewal=false` can be used

- Manually upgrade your CNI provider plugin (if required)
- Upgrade kubelet & kubectl
  ```shell
  apt-mark unhold kubelet kubectl && \
  apt-get update && apt-get install -y kubelet=1.18.6-00 kubectl=1.18.6-00 && \
  apt-mark hold kubelet kubectl
  ```
- Restart kubelet
  ```shell
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  ```
- Uncordon control plane node:
  ```shell
  kubectl uncordon <cp-node-name>
  ```

**Worker Node or Other master nodes**
- Download desired version of kubeadm
  ```shell
  apt-mark unhold kubeadm && \
  apt-get update && apt-get install -y kubeadm=1.18.6-00 && \
  apt-mark hold kubeadm
  ```
- Drain the node
  ```shell
  kubectl drain <node-to-drain> --ignore-daemonsets
  ```
- Upgrade: `sudo kubeadm upgrade node`
- Upgrade kubelet & kubectl
  ```shell
  apt-mark unhold kubelet kubectl && \
  apt-get update && apt-get install -y kubelet=1.18.6-00 kubectl=1.18.6-00 && \
  apt-mark hold kubelet kubectl
  ```
- Restart kubelet
  ```shell
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  ```
- Uncordon node
  ```shell
  kubectl uncordon <node-to-drain>
  ```
### Recover from failure
- `kubeadm upgrade` is idempotent. it can be rerun in case of failures. 
- To recover from a bad state, run `kubeadm upgrade apply --force` without changing the version that your cluster is running

- During upgrade kubeadm writes the following backup folders under /etc/kubernetes/tmp:
```
# backup of local etcd member data
# to manually restore, copy this folder content to `/var/lib/etcd`
- kubeadm-backup-etcd-<date>-<time>

# backup of static pod manifests like apiserver, scheduler, controller-manager
# to manually restore, copy the yamls in this folder to `/etc/kubernetes/manifests`
# if there is no difference between pre and post upgrade for a static pod manifest file, then it will not be backed up
- kubeadm-backup-manifests-<date>-<time>
```

### References:
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/