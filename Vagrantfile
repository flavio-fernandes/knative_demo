# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

# ssh tinkering...
$tinker_ssh = <<SCRIPT
  mkdir -p /home/vagrant/.ssh
  printf "%s\n" "#{File.read("#{ENV['HOME']}/.ssh/id_rsa_github")}" > /home/vagrant/.ssh/id_rsa_github
  printf "%s\n" "#{File.read("#{ENV['HOME']}/.ssh/known_hosts")}" >> /home/vagrant/.ssh/known_hosts
  printf "%s\n" "#{File.read("./provisioning/ssh_config")}" > /home/vagrant/.ssh/config
  printf "%s\n" "#{File.read("./provisioning/git_config")}" > /home/vagrant/.gitconfig
  chmod 600 /home/vagrant/.ssh/id_rsa_github
  chmod 700 /home/vagrant/.ssh
  chown -R vagrant:vagrant /home/vagrant/.ssh
SCRIPT

$install_reqs = <<SCRIPT
  apt-get update
  apt-get install --yes --quiet git wget python-pip screen
  pip install flask
  apt-get install --yes --quiet emacs tree httpie
  wget --timestamping --quiet https://github.com/sharkdp/bat/releases/download/v0.10.0/bat_0.10.0_amd64.deb
  dpkg --skip-same-version -i bat_0.10.0_amd64.deb
SCRIPT

$install_customs = <<SCRIPT
  ##cd /vagrant
  ##git clone git@github.com:flavio-fernandes/flaskapp.git
  [ ! -e /home/vagrant/flaskapp.git ] && ln -s /vagrant/flaskapp.git /home/vagrant/flaskapp.git ||:
  [ ! -e /home/vagrant/k8s ] && ln -s /vagrant/k8s /home/vagrant/k8s ||:
  printf "%s\n" "#{File.read("./provisioning/bashrc_me")}" > /home/vagrant/.bashrc_me
  grep --quiet bashrc_me /home/vagrant/.bashrc || \
cat << EOT >>/home/vagrant/.bashrc

if [ -f ~/.bashrc_me ]; then
    . ~/.bashrc_me
fi
EOT

  # iterm shell integration
  wget --no-clobber --quiet https://iterm2.com/shell_integration/bash \
    -O /home/vagrant/.iterm2_shell_integration.bash
  grep --quiet iterm2_shell_integration /home/vagrant/.bashrc || \
cat << EOT >>/home/vagrant/.bashrc

if [ -f /home/vagrant/.iterm2_shell_integration.bash ]; then
    . /home/vagrant/.iterm2_shell_integration.bash
fi
EOT

SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/xenial64"
    ubuntu.vm.box_check_update = false
    ubuntu.vm.hostname = "ctlVm"

    ubuntu.vm.provider :virtualbox do |vb|
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--memory", "512"]
      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    end

    ubuntu.vm.network "forwarded_port", guest: 5000, host: 5000, protocol: "tcp"
    ubuntu.vm.network "forwarded_port", guest: 8080, host: 8080, protocol: "tcp"
    ubuntu.vm.network "forwarded_port", guest: 8081, host: 8081, protocol: "tcp"
    ubuntu.vm.network "forwarded_port", guest: 8082, host: 8082, protocol: "tcp"

    ubuntu.vm.provision "tinker_ssh", type: "shell", privileged:false, inline: $tinker_ssh
    ubuntu.vm.provision "install_reqs", type: "shell", privileged:true, inline: $install_reqs
    ubuntu.vm.provision "install_gcloud", type: "shell", privileged:false, path: "provisioning/install_gcloud.sh"
    ubuntu.vm.provision "install_docker", type: "shell", privileged:true, path: "provisioning/install_docker.sh"
    ubuntu.vm.provision "install_gloo", type: "shell", privileged:false, path: "provisioning/install_gloo.sh"
    ubuntu.vm.provision "install_customs", type: "shell", privileged:false, inline: $install_customs
  end
end
