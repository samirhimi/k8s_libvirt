#!/bin/bash

## !IMPORTANT ##
#
## This script is tested only in the generic/ubuntu2204 Vagrant box
## If you use a different version of Ubuntu or a different Ubuntu Vagrant box test this again
#
echo "[TASK one] Update the system"

apt-get update && apt-get upgrade -y && apt-get autoremove -y

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 4] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[TASK 5] Install containerd runtime"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -qq -y apt-transport-https ca-certificates curl gnupg lsb-release nfs-common >/dev/null
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq >/dev/null
apt-get install -qq -y containerd.io >/dev/null
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null

echo "[TASK 6] Set up kubernetes repo"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' > /etc/apt/sources.list.d/kubernetes.list

echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt-get update -qq >/dev/null
apt-get install -qq -y kubeadm kubelet kubectl >/dev/null
apt-mark hold kubeadm kubelet kubectl >/dev/null

echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 9] Set devops  user"
PASS=$(echo "k8s" | openssl passwd -1 -stdin)
useradd -p  "$PASS" -s /bin/bash -d /home/devops -m devops
echo "devops  ALL=(ALL:ALL) NOPASSWD: ALL"  >> /etc/sudoers.d/devops
chmod 0440 /etc/sudoers.d/devops
mkdir -p /home/devops/.ssh
chmod 700 /home/devops/.ssh
touch /home/devops/.ssh/authorized_keys
chmod 600 /home/devops/.ssh/authorized_keys


echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 10] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.20.10   master.emdc.local     master
192.168.20.11   worker1.emdc.local    worker1
192.168.20.12   worker2.emdc.local    worker2
192.168.20.13   worker3.emdc.local    worker3
192.168.20.14   worker4.emdc.local    worker4
192.168.20.15   worker5.emdc.local    worker5
EOF
