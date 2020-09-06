# Volume Snapshot
- support only available for CSI drivers

- `VolumeSnapshotContent`: 
    - snapshot taken from a volume in the cluster
    - resource in the cluster just like a PV
- `VolumeSnapshot`: 
    - request for snapshot(VolumeSnapshotContent) of a volume by a user(similar to PVC). 
- `VolumeSnapshotClass`
    - specify different attributes belonging to a VolumeSnapshot(similar to StorageClass)

- All these 3 things are CRDs, not part of core API

### Provisioning
**PreProvisioned**
- A cluster administrator creates a number of VolumeSnapshotContents
- They carry the details of the real volume snapshot on the storage system which is available for use by cluster users

**Dynamic**
- can request that a snapshot to be dynamically taken from a PersistentVolumeClaim
 - `VolumeSnapshotClass` specifies storage provider-specific parameters to use when taking a snapshot.

### Binding 
- snapshot controller handles the binding of a VolumeSnapshot object with an appropriate VolumeSnapshotContent object, in both pre-provisioned and dynamically provisioned scenarios. The binding is a one-to-one mapping
- In the case of pre-provisioned binding, the VolumeSnapshot will remain unbound until the requested VolumeSnapshotContent object is created

### Persistent Volume Claim as Snapshot Source Protection

- If you delete a PVC in active use as a snapshot source, the PersistentVolumeClaim object is not removed immediately. 
- Instead, removal of the PVC object is postponed until the snapshot is readyToUse or aborted

### Delete
- Deletion is triggered by deleting the VolumeSnapshot object, and the DeletionPolicy will be followed
- `DeletionPolicy=Delete`: underlying storage snapshot will be deleted along with the VolumeSnapshotContent object
- `DeletionPolicy=Retain`: both the underlying snapshot and VolumeSnapshotContent remain

## Volume Snapshots
```yaml
# dynamic provisioning
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshot
metadata:
  name: new-snapshot-test
spec:
  volumeSnapshotClassName: csi-hostpath-snapclass # If nothing is set, then the default class is used if available
  source:
    persistentVolumeClaimName: pvc-test # required for dynamically provisioning a snapshot
```

```yaml
# PreProvisioned
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshot
metadata:
  name: test-snapshot
spec:
  source:
    volumeSnapshotContentName: test-content # required for pre-provisioned snapshots
```

## Volume Snapshot Contents
- in dynamic provisioning, snapshot common controller creates VolumeSnapshotContent objects
```yaml
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotContent
metadata:
  name: snapcontent-72d9a349-aacd-42d2-a240-d775650d2455
spec:
  deletionPolicy: Delete
  driver: hostpath.csi.k8s.io
  source:
    volumeHandle: ee0cfb94-f8d4-11e9-b2d8-0242ac110002 # required; unique identifier of the volume created on the storage backend and returned by the CSI driver during the volume creation
  volumeSnapshotClassName: csi-hostpath-snapclass
  volumeSnapshotRef:
    name: new-snapshot-test
    namespace: default
    uid: 72d9a349-aacd-42d2-a240-d775650d2455
```
- for pre-provisioned snapshots, you (as cluster administrator) are responsible for creating the VolumeSnapshotContent object
```yaml
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotContent
metadata:
  name: new-snapshot-content-test
spec:
  deletionPolicy: Delete
  driver: hostpath.csi.k8s.io
  source:
    snapshotHandle: 7bdd0de3-aaeb-11e8-9aae-0242ac110002 # required; unique identifier of the volume snapshot created on the storage backend
  volumeSnapshotRef:
    name: new-snapshot-test
    namespace: default
```

## Volume Snapshot Usage
- supports CSI Volume Plugins only
- To enable support for restoring a volume from a volume snapshot data source, enable the `VolumeSnapshotDataSource` feature gate on the apiserver and controller-manager
  - beta feature; enabled by default

```yaml
# Create a PersistentVolumeClaim from a Volume Snapshot
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restore-pvc
spec:
  storageClassName: csi-hostpath-sc
  dataSource:
    name: new-snapshot-test
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

## Volume Snapshot Class
- a way to describe the "classes" of storage when provisioning a volume snapshot
- fields cannot be updated once they are created
```yaml
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
  name: csi-hostpath-snapclass
  annotations:
    snapshot.storage.kubernetes.io/is-default-class: "true" # mark it as default 
driver: hostpath.csi.k8s.io # required; determines what CSI volume plugin is used for provisioning
deletionPolicy: Delete # required; Retain or Delete
parameters: # specfic to `driver`
```

## References:
https://kubernetes.io/docs/concepts/storage/volume-snapshots/
https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-snapshot-and-restore-volume-from-snapshot-support
https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/
