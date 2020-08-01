## Preparation:
- Required K8s knowledge: 
    - Kubernetes API primitives
    - Kubernetes internals such as etcd, tls bootstrap and kubelet
- Intermediate level of linux experience
    - some awk and cut tricks might come in handy as well
- systemd knowledge: https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units
- Deep understanding about Certificates and Keys
    - eg. find expiry date of a certificate
- Learn to use `kubectl explain pod.spec.XXX`; it saves time

## Exam Environment
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- Get comfortable with vim and terminal. The exam environment is within a Linux terminal, so there is no GUI. It’s very important that you feel comfortable in this environment. Kubectl edit uses vim, and at the very least, basic commands shouldn’t be a problem for you (switch modes, save, copy/paste)
- Good hands-on in VIM editor will be very useful; https://devhints.io/vim
- Good hands-on in tmux will be very useful; https://gist.github.com/MohamedAlaa/2961058
- Use kubectl auto-completion. Not having to copy/paste pod and deployment names will save you a lot of time
- Use a notepad for tracking progress along with general notes. This will help you to feel more confident. I used the following format:
```
 Task# — percent — status — comment (if any)
 Task1 — 5% — completed
 Task2 — 3% — completed
 Task3 — 4% — partially completed — check pod status
 ```
- Use aliases 
To avoid time consume, first create an alias in the console for the kubectl
```
alias k=/usr/bin/kubectl
alias kc=kubectl
alias kgp=kubectl get pods
alias kgs=kubectl get svc
alias kgc=kubectl get componentstatuses
alias kctx=kubectl config current-context
alias kcon=kubectl config use-context
alias kgc=kubectl config get-context
```
- Use autocompletion
```
source <(kubectl completion bash) # completion will save a lot of time and avoid typo
source <(kubectl completion bash | sed 's/kubectl/k/g' ) # so completion works with the alias "k"
```
- Use kubectl create option
It is very useful to use the “create” option redirecting the output to a yaml file.

```
kubectl create deployment my-dep --image=busybox --dry-run -o yaml > <exerciseNumber>.yaml
```
- Reuse contents 
Reuse the files from previous exercises. For example if in exercise 3 uses a pod and in 7, you can do something like this and edit the files. It is also a good way to go back to an exercise if cannot be completed at the first and we have some time for review.

```
cp 3-pod.yaml 7-pod.yaml
```

- The exam platform is powered by examslocal.com. Copy paste to external softwares are not permitted. Only 2 tabs of you browser are permitted, one for the exam platform and one for kubernetes.io documentation.
- Allowed to look up the following sites during the exam
    - kubernetes.io/docs
    - kubernetes.io/blog/
    - github.com/kubernetes
- Creating template YAML using kubectl dry-run and edit it instead of creating YAML from scratch
```
# Pod template
$ kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml
# Deployment template
$ kubectl run nginx --image=nginx  --dry-run -o yaml
# Service template
$ kubectl expose deployment nginx --type=NodePort --port 8080 --dry-run -o yaml

# [NOTE1]
# You can change resource to release by changing --restart option:
# kind       |  option
# ---------------------------------------------
# deployment |  none
# pod        |  --restart=Never
# job        |  --restart=OnFailure
# cronjob    |  --schedule='cron format(0/5 * * * ? など)'

# [NOTE2]
# In case that kubectl run will be deprecated in the future, 
$ kubectl create deployment nginx --image=nginx --dry-run -o yaml
```
- Virtual screen: you can virtual screen like tmux and screen. It would be very helpful to use multple screens like using one for deploying kuberenetes resources while using the other one for looking up kuberentes resource state and logs. For example, I’m a tmux user, and added the following .tmux.conf before starting tackling with questions:
```
set-option -g prefix C-z
```
- Set up .bashrc
```
source <(kubectl completion bash)
complete -F __start_kubectl k
alias k=”kubectl”
alias kgd=”k get deploy”
alias kgp=”k get pods”
alias kgn=”k get nodes”
alias kgs=”k get svc”
alias kge=”k get events — sort-by=’.metadata.creationTimestamp’ |tail -8"
export nks=”-n kube-system”
export ETCDCTL_API=3
export k8s=”https://k8s.io/examples"
function vaml()
{
vim -R -c ‘set syntax=yaml’ -;
}
```
Examples of use:
```
kgp $nks
kgp busybox -o yaml | vaml
k apply -f $k8/pods/storage/pv-volume.yaml — dry-run -o yaml
```
- comfortable with bash, vim, cfssl, systemctl, journalctl and tmux
- 3 screens(top 1, bottom 2) in tmux; 
    - top: work area
    - bottom left: `watch kubectl get pods`
    - bottom right: `watch "kubectl get events — sort-by='.metadataCreationstamp' | tail -6"`
- Tried to copy and paste from the exam terminal, I probably wasted 5 mins (yes even 5 mins matter out of the 3 hours) trying to copy and paste from that terminal..... never do that.... trust me it is better to type things

## Exam:
- Time management: Don’t spend too much time on difficult questions. Try to finish all easy questions first and spend the rest for difficult ones. You don’t have to beat everything to pass the exam!!
- Some tasks are difficult; some are easy. The score you get after completing each task depends on how complex it is
- Although, you have a root access to all servers, the 70% of the exam was made to use only `kubectl` command line and the 30% to debug and install kubernetes control plane components. For the debuging part, Kubernetes the Hard Way was a good advantage to accomplish theses problems
- If you’re spending more than 7 mins on questions worth only one or two percent (each question does tell you the percentage it is worth), move on
- Just relax if you see something like "configure fluentd" or "HAproxy". No configuration of external tools will be asked of you! The config file is usually provided.


### Tools Used:
- tmux — does help on the exam. Know how to split screens and switch between them. You only get one console on the test.
- vi — every edit and yaml file is done in vi. Be very comfortable navigating and editing files in vi, quickly.
- systemd — the test runs on Ubuntu 16 currently, so know how to manipulate services running under systemd (Digital ocean has a great intro to systemd post)
- kubectl — well, obviously. Be extremely comfortable with this command.
- cfssl/openssl — knowing how to generate certs (and what they are for) is important. Run through the hard way several times to be comfortable.


## References:
https://kubekub.com/blog/2019/06/29/ckad-cka-certifications/
https://medium.com/@ContinoHQ/the-ultimate-guide-to-passing-the-cka-exam-1ee8c0fd44cd
https://linuxacademy.com/community/show/25094-cka-exam-experience-and-some-useful-tips/