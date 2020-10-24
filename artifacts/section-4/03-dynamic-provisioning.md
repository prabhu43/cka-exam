# Dynamic Provisioning
- allows storage volumes to be created on-demand.
- Without dynamic provisioning, cluster administrators have to manually make calls to their cloud or storage provider to create new storage volumes, and then create PersistentVolume objects to represent them in Kubernetes

### Enable Dynamic Provisioning
- a cluster administrator needs to pre-create one or more StorageClass objects for users.
- StorageClass objects define which provisioner should be used and what parameters should be passed to that provisioner when dynamic provisioning is invoked

```yaml
# creates a storage class "slow" which provisions standard disk-like persistent disks
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
```

```yaml
# creates a storage class "fast" which provisions SSD-like persistent disks
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

### Using Dynamic Provisioning
- Users request dynamically provisioned storage by including a storage class in their PVC
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim1
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 30Gi
```

### Defaulting Behavior
- A cluster administrator can enable this behavior by
    - Marking one `StorageClass` object as default; `storageclass.kubernetes.io/is-default-class`
    - Making sure that the `DefaultStorageClass` admission controller is enabled on the API server
- When a default StorageClass exists in a cluster and a user creates a PersistentVolumeClaim with storageClassName unspecified, the DefaultStorageClass admission controller automatically adds the storageClassName field pointing to the default storage class

### Topology Awareness
- Default volume binding mode is `Immediate`. In that case, volumes will be provisioned immediately in a zone without considering pod scheduling constraints. This may result in unschedulable Pods.
- In Multi-Zone clusters, Pods can be spread across Zones in a Region. To support that, use volume binding `WaitForFirstConsumer`. It will delay the binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created. PersistentVolumes will be selected or provisioned conforming to the topology that is specified by the Pod's scheduling constraints
