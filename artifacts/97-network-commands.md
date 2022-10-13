# some network commands
ip link - to find network interface
ip addr - to find IP of node
ip route - to find default gateway
netstat -nplt - to find process listening ports
netstat -anp | grep etcd - to find currently listening ports

ls /etc/cni/net.d/ - find cni configured in k8s cluster

nc -vz -w 2 IP PORT

check "ipalloc-range" in weave pod logs for pod cidr