### kubectl scale

- Applicable for Deployment, ReplicaSet, Replication Controller, or StatefulSet
- it also allows users to specify one or more preconditions for the scale action.
    - If `--current-replicas` or `--resource-version` is specified, it is validated before the scale is attempted, and it is guaranteed that the precondition holds true when the scale is sent to the server

**Example**
```
# Scale deployment
kubectl scale deploy utils --replicas=2

# Scale a replicaset named 'foo' to 3
kubectl scale --replicas=3 rs/foo

# Scales all resources identified by type and name specified in "foo.yaml" to 3
kubectl scale --replicas=3 -f foo.yaml

# If the deployment named mysql's current size is 2, scale mysql to 3
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql

# Scale multiple replication controllers.
kubectl scale --replicas=5 rc/foo rc/bar rc/baz

# Scale statefulsets named 'web' and 'utils' to 3
kubectl scale --replicas=3 statefulset/web sts/utils

# If horizontal scaling enabled
kubectl autoscale deployment.v1.apps/nginx-deployment --min=10 --max=15 --cpu-percent=80
```