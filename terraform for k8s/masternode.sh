sudo hostnamectl set-hostname k8masternode

#Update the apt package index and install packages needed to use the Kubernetes apt repository:

sudo apt-get update -y
sudo apt install docker.io -y
sudo apt-get install -y apt-transport-https ca-certificates curl

#Download the Google Cloud public signing key:
sleep 30
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#Add the Kubernetes apt repository:
sleep 30
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sleep 30
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
sleep 30
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sleep 30
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
sleep 30
kubeadm token create --print-join-command >> /home/ubuntu/token.sh
