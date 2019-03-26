#!/bin/bash

set -o xtrace
set -o errexit

SCRIPT="install_gloo.done"
[ -e ~/${SCRIPT} ] && { echo "noop: ${SCRIPT}"; exit 0; }

curl -sL https://run.solo.io/gloo/install | sh

grep --quiet "gloo/bin" /home/vagrant/.bashrc || \
echo 'export PATH=$HOME/.gloo/bin:$PATH' >> /home/vagrant/.bashrc

touch ~/${SCRIPT}
echo ok
