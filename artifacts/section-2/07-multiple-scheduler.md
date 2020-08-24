## Multiple schedulers
- Name of different schedulers should be unique
```sh
command:
- /usr/local/bin/kube-scheduler
- --address=0.0.0.0
- --leader-elect=false
- --scheduler-name=my-scheduler
```
- Use `pod.spec.schedulerName` to assign the pod to particular scheduler

```
# Show events with scheduler info
k get events -o wide
```

### References
https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/