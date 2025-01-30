#!/bin/bash

set -e

KUBERNETES_VERSION="1.32"
JOIN_CMD=""
MASTER="No"
INGRESS="No"

# Check if the script is run as super user
if [ "$(id -u)" -ne 0 ]; then
  echo "------------------------------------"
  echo "Please run this script as super user"
  echo "------------------------------------"
  exit 1
fi

# Check if the script is being instructed to run on master node
while getopts 'mhiv:' opt; do
  case "$opt" in
  m)
    echo "---------------------------------------"
    echo "Running installer script on master node"
    echo "---------------------------------------"
    MASTER="Yes"
    ;;
  i)
    echo "-----------------------------------------"
    echo "Setting up ingress for kubernetes cluster"
    echo "-----------------------------------------"
    INGRESS="Yes"
    ;;
  v)
    echo "---------------------------------------------------------------"
    echo "Using kubernetes version $OPTARG instead of $KUBERNETES_VERSION"
    echo "---------------------------------------------------------------"
    KUBERNETES_VERSION="$OPTARG"
    ;;
  h | ?)
    echo "------------------------------------------------------------"
    echo "-m: run this script for setting up master node"
    echo "-i: apply ingress nginx config to kubernetes cluster"
    echo "-v: set the version of kubernetes to install (default: 1.32)"
    echo "------------------------------------------------------------"
    exit 1
    ;;
  esac
done

# Update apt repos and upgrade any upgradable packages
sudo apt -y update
sudo apt -y upgrade

# Install packages required for running script
sudo apt -y install apt-transport-https ca-certificates curl jq vim

# Enable overlay and br_netfilter kernel modules required for containerd to work
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe -a overlay br_netfilter

# Install containerd, runc and official cni plugins
sudo apt -y install containerd runc containernetworking-plugins

# Enable systemd cgroup support in containerd config toml file
sudo mkdir -p /etc/containerd/
sudo touch /etc/containerd/config.toml
sudo containerd config default | sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml >/dev/null

# Restart and enable containerd service
sudo systemctl restart containerd
sudo systemctl enable containerd

# Configure sysctl
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# Turn off swap files or partitions
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Install kubeadm, kubelet and/or kubectl
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt -y update
sudo apt -y upgrade
if [ "$MASTER" == "Yes" ]; then
  sudo apt -y install kubeadm kubelet kubectl
else
  sudo apt -y install kubeadm kubelet
fi

# Initialize kubeadm
if [ "$MASTER" == "Yes" ]; then
  KUBEADM_LOG_FILE="kubeadm.log"
  sudo kubeadm init | tee $KUBEADM_LOG_FILE
  JOIN_CMD=$(cat $KUBEADM_LOG_FILE | tail -n 2)
  sudo rm -rf KUBEADM_LOG_FILE
fi

if [ "$MASTER" == "Yes" ]; then
  if [ ! -f /etc/kubernetes/admin.conf ]; then
    echo "-------------------"
    echo "Kubeadm init failed"
    echo "-------------------"
    exit 1
  fi
fi

# Setup kubectl config to connect to current cluster
if [ "$MASTER" == "Yes" ]; then
  mkdir -p "$HOME/.kube"
  sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
  sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"
fi

# Apply flannel CNI plugin yaml
if [ "$MASTER" == "Yes" ]; then
  kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
fi

# Apply nginx ingress controller yaml
if [ "$INGRESS" == "Yes" ]; then
  INGRESS_NGINX_VERSION=$(curl -sL https://api.github.com/repos/kubernetes/ingress-nginx/releases | jq -r '.[] | .name' | grep controller | head -n 1)
  kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/$INGRESS_NGINX_VERSION/deploy/static/provider/baremetal/deploy.yaml"
fi

# Print versions
echo "------------------------"
if [ "$MASTER" == "Yes" ]; then
  kubectl version
  kubeadm version
  kubelet --version
  containerd --version
  runc --version
else
  kubeadm version
  kubelet --version
  containerd --version
  runc --version
fi
echo "------------------------"

# Print join command to be run on worker nodes
if [ "$MASTER" == "Yes" ]; then
  echo
  echo "---------------------------------------------------"
  echo "Run the below join command in all the worker nodes."
  echo "---------------------------------------------------"
  echo "$JOIN_CMD"
  echo "---------------------------------------------------"
else
  echo
  echo "------------------------------------------------------------------"
  echo "Run the join command provided by the master node once initialized."
  echo "------------------------------------------------------------------"
fi
