#!/bin/bash

set -o xtrace
set -o errexit

SCRIPT="install_gcloud.done"
[ -e ~/${SCRIPT} ] && { echo "noop: ${SCRIPT}"; exit 0; }

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo \
tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl --silent https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update --quiet && sudo apt-get install --yes --quiet google-cloud-sdk
sudo apt-get install --yes --quiet kubectl

# add autocomplete permanently to bash shell.
echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc

# get kubens and kubectx.
mkdir -pv /home/vagrant/bin
cd /home/vagrant/bin
wget --timestamping --quiet https://raw.githubusercontent.com/flavio-fernandes/kubectx/knative-demo/kubectx
wget --timestamping --quiet https://raw.githubusercontent.com/flavio-fernandes/kubectx/knative-demo/kubens
chmod 755 ./kubectx ./kubens

# get kube-ps1
cd /home/vagrant/bin
git clone https://github.com/jonmosco/kube-ps1.git kube-ps1.git
cat << EOT >>/home/vagrant/.bashrc

if [ -f /home/vagrant/bin/kube-ps1.git/kube-ps1.sh ]; then
  source "/home/vagrant/bin/kube-ps1.git/kube-ps1.sh"
  PS1='\$(kube_ps1)\${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
EOT

# Handy commands at this point...
#gcloud container clusters get-credentials knative --zone $CLUSTER_ZONE --project $PROJECT
#gcloud init   ; # OR  ;  gcloud auth login
#gcloud auth application-default login
#gcloud config set core/project ${PROJECT}
#gcloud config set compute/zone ${CLUSTER_ZONE}
#gcloud container clusters list
#gcloud auth list
#gcloud config list
#gcloud info

touch ~/${SCRIPT}
echo ok
