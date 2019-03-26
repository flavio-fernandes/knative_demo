#!/bin/bash

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o xtrace
set -o errexit

SCRIPT="install_docker.done"
[ -e ~/${SCRIPT} ] && { echo "noop: ${SCRIPT}"; exit 0; }

apt-get --quiet update && apt-get install --yes --quiet \
  apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get --quiet update && apt-get install --yes --quiet docker-ce

systemctl start docker
systemctl enable docker

groupadd docker >/dev/null 2>&1 ||:
usermod -aG docker vagrant

touch ~/${SCRIPT}
echo ok
