# Volume Cloning
- supports CSI Volume Plugins only
- adds support for specifying existing PVCs in the dataSource field to indicate a user would like to clone a Volume
- A Clone is defined as a duplicate of an existing Kubernetes Volume that can be consumed as any standard Volume would be
- source PVC must be bound and available (not in use)
- only available for dynamic provisioners
- CSI drivers may or may not have implemented the volume cloning functionality
- source and destination must be in the same namespace
- source and destination must be in the same storage class
- source and destination must be in the same volume mode
- Clones are provisioned just like any other PVC with the exception of adding a dataSource that references an existing PVC in the same namespace
- `spec.resources.requests.storage` in clone is mandatory, and the value must be the same or larger than the capacity of the source volume
- newly created PVC(by clone) is an independent object
- source is not linked in any way to the newly created clone

```yaml
# Create PersistentVolumeClaim from an existing PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cloned-pvc
spec:
  storageClassName: my-csi-plugin
  dataSource:
    name: existing-src-pvc-name
    kind: PersistentVolumeClaim
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
