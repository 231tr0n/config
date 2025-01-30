#!/bin/bash

set -e

# WARNING: Don't edit the parameters here
KUBERNETES_VERSION="1.32"
JOIN_CMD=""
MASTER="No"
INGRESS="No"

# Helper function used to print stages and information
function error_log() {
  echo
  echo
  echo -ne "[\e[1;36mINFO\e[1;0m] " >&2
  echo -e "$1" >&2
  echo
  echo
}
function info_log() {
  echo
  echo
  echo -ne "[\e[1;36mINFO\e[1;0m] "
  echo -e "$1"
  echo
  echo
}

# Parse script arguments
while getopts 'mhiv:' opt; do
  case "$opt" in
  m)
    info_log "Running installer script on master node"
    MASTER="Yes"
    ;;
  i)
    info_log "Setting up ingress for kubernetes cluster"
    INGRESS="Yes"
    ;;
  v)
    info_log "Using kubernetes version $OPTARG instead of $KUBERNETES_VERSION"
    KUBERNETES_VERSION="$OPTARG"
    ;;
  h | ?)
    info_log "Help\n
    -m: use this option for setting up master node
    -i: apply ingress nginx config yaml to kubernetes cluster
    -v VERSION: set the version of kubernetes to install (default: $KUBERNETES_VERSION)"
    exit
    ;;
  esac
done

# Check if the script is run as super user
if [ "$(id -u)" -ne 0 ]; then
  error_log "Please run this script as super user"
fi

info_log "Update apt repos and upgrade any upgradable packages"
apt -y update
apt -y upgrade

info_log "Install packages required for running script"
apt -y install apt-transport-https ca-certificates curl jq vim

info_log "Install containerd"
apt -y install containerd

info_log "Enable systemd cgroup support in containerd config toml file"
mkdir -p /etc/containerd/
containerd config default | tee /etc/containerd/config.toml >/dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

info_log "Restart and enable containerd service"
systemctl restart containerd
systemctl enable containerd

info_log "Install kubeadm, kubelet and/or kubectl"
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt -y update
apt -y upgrade
if [ "$MASTER" == "Yes" ]; then
  apt -y install kubeadm kubelet kubectl
else
  apt -y install kubeadm kubelet
fi

info_log "Turn off swap files or partitions"
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

info_log "Enable overlay and br_netfilter kernel modules required for containerd to work"
modprobe -a overlay br_netfilter
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

info_log "Configure sysctl"
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

info_log "Initialize kubeadm"
if [ "$MASTER" == "Yes" ]; then
  KUBEADM_LOG_FILE="kubeadm.log"
  kubeadm init | tee $KUBEADM_LOG_FILE
  JOIN_CMD=$(cat $KUBEADM_LOG_FILE | tail -n 2)
fi

# Exit if kubeadm init command failed
if [ "$MASTER" == "Yes" ]; then
  if [ ! -f /etc/kubernetes/admin.conf ]; then
    error_log "Kubeadm init failed"
  fi
fi

info_log "Setup kubectl config to connect to current cluster"
if [ "$MASTER" == "Yes" ]; then
  mkdir -p "$HOME/.kube"
  cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
  chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"
fi

info_log "Apply flannel CNI plugin yaml"
if [ "$MASTER" == "Yes" ]; then
  kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
fi

info_log "Apply nginx ingress controller yaml"
if [ "$MASTER" == "Yes" ]; then
  if [ "$INGRESS" == "Yes" ]; then
    INGRESS_NGINX_VERSION=$(curl -sL https://api.github.com/repos/kubernetes/ingress-nginx/releases | jq -r '.[] | .name' | grep controller | head -n 1)
    kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/$INGRESS_NGINX_VERSION/deploy/static/provider/baremetal/deploy.yaml"
  fi
fi

# Print versions
info_log "Print all versions of binaries"
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

# Print join command to be run on worker nodes
if [ "$MASTER" == "Yes" ]; then
  info_log "Run the below join command in all the worker nodes"
  info_log "$JOIN_CMD"
else
  info_log "Run the join command provided by the master node once initialized"
fi
