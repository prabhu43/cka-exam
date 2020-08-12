### MVP: Etcd backup and restore

#### 1) Take snapshot
Very important to use v3 etcdctl client 
```sh
$ etcdctl version
etcdctl version: 3.3.13
API version: 3.3
```
If API version is **not** 3.x.x, then
`export ETCDCTL_API=3`

```sh
etcdctl snapshot save <snapshot-file-name> --help
```
We have to provide cacert, servercrt, serverkey, endpoints for the above command.
We can find this values from etcd pod in kube-system namespace
Default for kubeadm: `/etc/kubernetes/pki/etcd/ca.crt`

Example:
```sh
etcdctl snapshot save snapshot.db --endpoints=https://172.17.0.3:2379 --cert=/var/lib/minikube/certs/etcd/server.crt --key=/var/lib/minikube/certs/etcd/server.key --cacert=/var/lib/minikube/certs/etcd/ca.crt
```

```sh
$ etcdctl snapshot status <snapshot-file-name> -w json
# sample output {"hash":1948432566,"revision":1645,"totalKey":611,"totalSize":1085440}
```

#### 2) Restore using snapshot

```sh
etcdctl snapshot restore --help
```
Example:
```sh
etcdctl snapshot restore ./snapshot.db \
    --endpoints=https://172.17.0.3:2379 \
    --cert=/var/lib/minikube/certs/etcd/server.crt \
    --key=/var/lib/minikube/certs/etcd/server.key \
    --cacert=/var/lib/minikube/certs/etcd/ca.crt \
    --name=minikube \
    --initial-cluster-token="etcd-cluster-restore" \
    --initial-advertise-peer-urls=https://172.17.0.3:2380 \
    --initial-cluster=minikube=https://172.17.0.3:2380 \
    --data-dir=/var/lib/minikube/etcd-restore
```

Change `--initial-cluster-token=etcd-cluster-restore` and hostpath volume to new directory `/var/lib/minikube/etcd-restore`
