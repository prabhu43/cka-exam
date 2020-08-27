## Feature gates:
https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/

## Pod Preset:
- alpha feature; disabled by default
https://kubernetes.io/docs/concepts/workloads/pods/podpreset/
https://kubernetes.io/docs/tasks/inject-data-application/podpreset/

## Ephemeral Containers
- alpha feature; disabled by default
- a special type of container that runs temporarily in an existing Pod to accomplish user-initiated actions such as troubleshooting. 
- use it to inspect services rather than to build applications
- `k alpha debug -h`
https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/
https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/#debugging-with-ephemeral-debug-container

## CertificateSigningRequest
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/

## Encrypt Data at Rest
https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/