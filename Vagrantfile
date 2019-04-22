# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.network "private_network", ip: "192.168.33.10"

  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  config.vm.provision "shell", inline: <<-SHELL
    # yum update

    # kubectl
    VERSION="v1.14.1"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubectl
    chmod +x kubectl
    mv kubectl /usr/local/bin/

    # helm
    VERSION="v2.12.3"
    curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz
    tar zxvf helm-${VERSION}-linux-amd64.tar.gz
    cp linux-amd64/helm /usr/local/bin/
    rm -rf linux-amd64
    rm -f helm-${VERSION}-linux-amd64.tar.gz

    # jq
    VERSION="1.6"
    curl -Lo jq https://github.com/stedolan/jq/releases/download/jq-${VERSION}/jq-linux64
    chmod +x jq
    mv jq /usr/local/bin/

    # ibmcloud
    curl -Lo IBM_Cloud_CLI.tar.gz https://clis.ng.bluemix.net/download/bluemix-cli/latest/linux64
    tar xzvf IBM_Cloud_CLI.tar.gz
    Bluemix_CLI/install
    rm -rf IBM_Cloud_CLI.tar.gz
    su - vagrant -c "ibmcloud plugin install kubernetes-service"
    su - vagrant -c "ibmcloud plugin install container-registry"

    # git
    yum -y install git

    # kubens/kubectx
    git clone https://github.com/ahmetb/kubectx.git /opt/kubectx
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    # kube-ps1
    git clone https://github.com/jonmosco/kube-ps1.git /opt/kube-ps1
    cat <<"EOF" >> /home/vagrant/.bashrc
source /opt/kube-ps1/kube-ps1.sh" >> 
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOF

    # completion
    echo "source /usr/local/ibmcloud/autocomplete/bash_autocomplete" >> /home/vagrant/.bashrc
    echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc

  SHELL
end
