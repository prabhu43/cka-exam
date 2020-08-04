- [Create-backup / restore-backup cluster data](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/) with ETCD server via TLS connection. Try to remember options with create-backup/restore-backup command (since they’re not listed fully in CKA document, especially for restore-backup command !!!)
- Query resources metadata with [jsonpath](https://kubernetes.io/docs/reference/kubectl/jsonpath/): CKA exam takes me to surprise when requiring up to 5 questions that involves jsonpath skill to solve the problem. If you don’t familiar with jsonpath, go for it right now !
- [DNS for pods & services](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/): you should understand how DNS is implemented in K8S cluster. Try to resolve the service-name & pod-name by your own (with nslookup command).
- [Deploy pod without using kube-scheduler](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/): differentiate the difference between static pod / dynamic pod.
- CLEARLY understand working mechanism & configuration of K8S cluster components (etcd servers, api-server, kubelet,…) Some of the debugging questions you will see in the exam are:
    - debugging why “kubectl get pods” does not work (api-server is not listening)
    - debugging why deployment can not be scaled (kube-controller-manager issued)
    - debugging why pods is pending for long time (kube-scheduler issued),









## References:
- https://medium.com/faun/passing-certified-kubernetes-administrator-exam-tips-d5107d8e3e7b