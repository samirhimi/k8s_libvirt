#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=192.168.20.10 --pod-network-cidr=172.17.0.0/16 >> /root/kubeinit.log 2>/dev/null
sleep 30

echo "[TASK 3] copy admin.conf"
mkdir -p /home/devops/.kube
cp /etc/kubernetes/admin.conf /home/devops/.kube/config
chown -R devops:devops /home/devops/.kube
export KUBECONFIG=/etc/kubernetes/admin.conf



echo "[TASK 3] Deploy Calico network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml >/dev/null
sleep 10
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/calico.yaml
sleep 10
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml >/dev/null

echo "[TASK ] Deploy metric server"

kubectl apply --kubeconfig=/etc/kubernetes/admin.conf  -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sleep 10
kubectl --kubeconfig=/etc/kubernetes/admin.conf patch -n kube-system deployment metrics-server --type=json -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
sleep 10
kubectl --kubeconfig=/etc/kubernetes/admin.conf patch -n kube-system deployment metrics-server --type=json -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP"}]'
sleep 10

# echo "[TASK 4] Deploy Cilium network"
# CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
# CLI_ARCH=amd64
# if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
# curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
# rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# cilium install --version 1.15.1 

echo "[TASK 5] Generate and save cluster join command to /home/devops/joincluster.sh"
kubeadm token create --print-join-command > /home/devops/joincluster.sh
chown devops:devops /home/devops/joincluster.sh
chmod +x /home/devops/joincluster.sh

