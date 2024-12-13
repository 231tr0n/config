#!/bin/bash
set -e
rm -rf kubernetes
mkdir -p kubernetes
cd kubernetes
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm -f minikube-linux-amd64
go install -v sigs.k8s.io/kind@latest
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm -f kubectl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
cd ..
rm -rf kubernetes
