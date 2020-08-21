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

##### Deployment Strategy(.spec.strategy.type)
- Recreate - will delete all the old pods, then create the new pods
- RollingUpdate - default; can be controlled with `.spec.strategy.rollingUpdate.maxUnavailable` and `.spec.strategy.rollingUpdate.maxSurge`
    - **maxUnavailable** The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The absolute number is calculated from percentage by rounding **down**. The value cannot be 0 if .spec.strategy.rollingUpdate.maxSurge is 0. The default value is 25%.
    - **maxSurge** The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The value cannot be 0 if MaxUnavailable is 0. The absolute number is calculated from the percentage by rounding **up**. The default value is 25%.

##### Few important fields of deployment:
- `spec.progressDeadlineSeconds` number of seconds you want to wait for your Deployment to progress before the system reports back that the Deployment has failed progressing. Default 600s
- `.spec.minReadySeconds` minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available. Default: 0
- `.spec.revisionHistoryLimit`number of old ReplicaSets to retain to allow rollback. Default: 10
- `.spec.paused` optional boolean field for pausing and resuming a Deployment (Default: false)

###### Side Note:
- `--record=true` will add annotation(kubernetes.io/change-cause) about how it is updated
```sh
# Update image of container `nginx` in deployment nginx-deployment
kubectl set image deploy/nginx-deployment nginx=nginx:1.16.1 --record=true
kubectl apply -f filename.yaml --record=true
```
Eg: `kubectl rollout history`
```
REVISION    CHANGE-CAUSE
1           kubectl apply --filename=https://k8s.io/examples/controllers/nginx-deployment.yaml --record=true
2           kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1 --record=true
3           kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1 --record=true
```

- `kubectl set --help` is useful to modify the k8s resources like pod, deployment, etc

- In API version apps/v1, a Deployment's label selector is immutable after it gets created

- The .spec.template and .spec.selector are the only required field of the .spec

- Only a `.spec.template.spec.restartPolicy` equal to `Always` is allowed, which is the default if not specified

##### References:
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
https://stackoverflow.com/questions/53239081/how-does-minreadyseconds-affect-readiness-probe