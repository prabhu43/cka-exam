## Technical Instructions

Access these instructions at any time while taking the exam by typing 'man lf_exam'

1. Root privileges can be obtained by running 'sudo −i'
2. Rebooting of your server is permitted at anytime
3. Do not stop or tamper with the certerminal process as this will END YOUR EXAM SESSION.
4. Do not block incoming ports 8080/tcp, 4505/tcp and 4506/tcp. This includes firewall rules that are found within the distribution's default firewall configuration files as well as interactive firewall
commands.
5. Use Ctrl+Alt+W instead of Ctrl+W.
5.1. Ctrl+W is a keyboard shortcut that will close the current tab in Google Chrome.
6. Ctrl+C & and Ctrl+V are not supported in your exam terminal.
To copy and paste text, please use;
6.1. For Linux: select text for copy and middle button for paste (or both left and right
simultaneously if you have no middle button).
6.2. For Mac: ⌘+C to copy and ⌘+V to paste.
6.3. For Windows: Ctrl+Insert to copy and Shift+Insert to paste.
6.4. In addition, you might find it helpful to use the Notepad (see top menu under 'Exam
Controls') to manipulate text before pasting to the command line.
7. Installation of services and applications included in this exam may require modification of system
security policies to successfully complete.
8. Only a single terminal console is available during the exam. Terminal multiplexers such as GNU
Screen and tmux can be used to create virtual consoles.

## Clusters
|Cluster |Members               | CNI     | Description |
|---|---|---|---|
|k8s     |1 master, 2 worker    |flannel  |K8s cluster  |
|hk8s    |1 master, 2 worker    |calico   |K8s cluster  |
|bk8s    |1 master, 1 worker    |flannel  |K8s cluster  |
|wk8s    |1 master, 2 worker    |flannel  |K8s cluster  |
|ek8s    |1 master, 2 worker    |flannel  |K8s cluster  |
|ik8s    |1 master, 1 base node |loopback |K8s cluster - Missing worker node |

## CKA Environment
- OS: Linux
- Each task on this exam must be completed on a designated cluster/configuration context.
- To minimize switching, the tasks are grouped so that all questions on a given cluster appear consecutively
- At the start of each task you'll be provided with the command to ensure you are on the correct cluster to complete the task
- Nodes making up each cluster can be reached via ssh: `ssh nodename`
- You can assume elevated privileges on any node by issuing the following command: `sudo -i`
- You must return to the base node (hostname node-1) after completing each task
- Nested−ssh is not supported
- You can use kubectl and the appropriate context to work on any cluster from the base node
When connected to a cluster member via ssh, you will only be able to work on that particular cluster via kubectl
- Further instructions for connecting to cluster nodes will be provided in the appropriate tasks
- Where no explicit namespace is specified, the default namespace should be acted upon
- If you need to destroy/recreate a resource to perform a certain task, it is your responsibility to back up the resource definition appropriately prior to destroying the resource
## Reference:
https://training.linuxfoundation.org/wp-content/uploads/2020/04/Important-Tips-CKA-CKAD-April2020.pdf