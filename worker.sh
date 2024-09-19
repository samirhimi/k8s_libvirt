#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"

export DEBIAN_FRONTEND=noninteractive
apt-get install -qq -y sshpass >/dev/null
sshpass -p "k8s" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master:/home/devops/joincluster.sh  /home/devops/joincluster.sh > /dev/null 2>&1
chmod +x /home/devops/joincluster.sh
cd /home/devops
bash /home/devops/joincluster.sh >/dev/null

