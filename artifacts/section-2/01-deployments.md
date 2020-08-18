#### Understand deployments and how to perform rolling updates and rollback

```sh
# check the rollout status
kubectl rollout status deploy/nginx

# check the history of rollouts
kubectl rollout history deploy/nginx

# View the details at revision 3
kubectl rollout history deploy/nginx --revision 3

# undo to previous version
kubectl rollout undo deploy/nginx

# undo to version 2
kubectl rollout undo deploy/nginx --to-revision=2

# pause a rollout (set/apply will not have effect on paused deployments)
kubectl rollout pause deploy/nginx

# resume the rollout
# You cannot rollback a paused Deployment until you resume it.
kubectl rollout resume deploy/nginx
```

##### Deployment Strategy:
- Recreate - will delete all the old pods, then create the new pods
- Rollout - can be controlled with
    - **maxUnavailable** The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The absolute number is calculated from percentage by rounding **down**. The value cannot be 0 if .spec.strategy.rollingUpdate.maxSurge is 0. The default value is 25%.
    - **maxSurge** The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The value cannot be 0 if MaxUnavailable is 0. The absolute number is calculated from the percentage by rounding **up**. The default value is 25%.

##### Few important fields of deployment:
- `spec.progressDeadlineSeconds` number of seconds you want to wait for your Deployment to progress before the system reports back that the Deployment has failed progressing. Default 600s
- `.spec.minReadySeconds` minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available. Default: 0
- `.spec.revisionHistoryLimit`number of old ReplicaSets to retain to allow rollback. Default: 10

###### Side Note:
1. `--record=true` will add annotation about how it is updated
```sh
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.161 --record=true
kubectl apply -f filename.yaml --record=true
```
Eg: `kubectl rollout history`
```
REVISION    CHANGE-CAUSE
1           kubectl apply --filename=https://k8s.io/examples/controllers/nginx-deployment.yaml --record=true
2           kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1 --record=true
3           kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.161 --record=true
```

2. `kubectl set --help` is useful to modify the pod/deployment
```
kubectl set resources --help
```

##### References:
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
https://stackoverflow.com/questions/53239081/how-does-minreadyseconds-affect-readiness-probe