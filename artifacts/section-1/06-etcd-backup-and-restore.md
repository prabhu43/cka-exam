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

We have to provide endpoints, cacert, servercrt, serverkey  for the above command. We can find these values from etcd pod in kube-system namespace or the static manifest for etcd (/etc/kubernetes/manifests/etcd.yaml).

Example:
```sh
## take snapshot into file `snapshot.db`
etcdctl snapshot save snapshot.db \
    --endpoints=https://172.17.0.3:2379 \
    --cacert=/var/lib/minikube/certs/etcd/ca.crt \
    --cert=/var/lib/minikube/certs/etcd/server.crt \
    --key=/var/lib/minikube/certs/etcd/server.key 

# check status of snapshot taken
etcdctl snapshot status <snapshot-file-name> -w json
# sample output {"hash":1948432566,"revision":1645,"totalKey":611,"totalSize":1085440}
```

#### 2) Restore using snapshot

**restore snapshot**
```sh
etcdctl snapshot restore --help
```

Refer static manifest of etcd to populate the following required options. 
    - `initial-cluster-token` and `data-dir` should be different from previous one
    - others configs should be same
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

**change etcd pod**
Change `--initial-cluster-token=etcd-cluster-restore` and hostpath volume to new directory `/var/lib/minikube/etcd-restore`
