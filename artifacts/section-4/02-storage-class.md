# Storage Class
- contains the fields `provisioner`, `parameters`, and `reclaimPolicy`, which are used when a PersistentVolume belonging to the class needs to be dynamically provisioned
- cannot be updated once they are created
- Administrators can specify a default StorageClass just for PVCs that don't request any particular class to bind to
- PersistentVolumes that are dynamically created by a StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: Immediate
```

### Reclaim Policy
- PersistentVolumes that are dynamically created by a StorageClass will have the reclaim policy specified in the reclaimPolicy field of the class
- 2 types: `Delete (Default)` and `Retain`
- PersistentVolumes that are created manually and managed via a StorageClass will have whatever reclaim policy they were assigned at creation

### Allow Volume Expansion (beta feature)
- PersistentVolumes can be configured to be expandable 
- setting `allowVolumeExpansion` to true, allows users to resize the volume by editing the corresponding PVC object

### Volume Binding Mode
- controls when volume binding and dynamic provisioning should occur
**2 types**
- Immediate(Default): 
    - volume binding and dynamic provisioning occurs once the PVC is created
    - PersistentVolumes will be bound or provisioned without knowledge of the Pod's scheduling requirements. This may result in unschedulable Pods
- WaitForFirstConsumer: 
    - delay the binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created

### Allowed Topologies
- to restrict the topology of provisioned volumes to specific zone
```
...
allowedTopologies:
- matchLabelExpressions:
  - key: failure-domain.beta.kubernetes.io/zone
    values:
    - us-central1-a
    - us-central1-b
```

### Parameters
- describe volumes belonging to the storage class
- depends on the provisioner
- at most 512 parameters defined for a StorageClass
- total length of the parameters object including its keys and values cannot exceed 256 KiB

```
# AWS EBS
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  iopsPerGB: "10"
  fsType: ext4

# GCE PD
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  fstype: ext4
  replication-type: none
```

### Local provisioner
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```
- do not currently support dynamic provisioning

## References:
https://kubernetes.io/docs/concepts/storage/storage-classes/