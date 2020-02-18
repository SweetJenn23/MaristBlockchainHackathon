#!/bin/bash

# Build out the Hyperledger Fabric environment for Linux on z Systems

# Global Variables
OS_FLAVOR=""
GO_VER="1.12.15"

usage() {
  cat << EOF

Usage:  `basename $0` options

This script installs and configures a Hyperledger Fabric environment on a Linux on
IBM z Systems instance.  The execution of this script assumes that you are starting
from a new Linux on z Systems instance.  The script will autodetect the Linux
distribution (currently RHEL, SLES, and Ubuntu) and build out the necessary components.
After running this script, logout and then login to pick up updates to
Hyperledger Fabric specific environment variables.

To run the script:
<path-of-script>/ZFabricBuild-v1.4.sh

The script will install the following components:
    - Docker and supporting Hyperledger Fabric Docker images
    - Golang
    - Nodejs 
    - Hyperledger Fabric core components (fabric, fabric-ca, and fabric-sdk-node)


EOF
  exit 1
}

# Install prerequisite packages for an RHEL Hyperledger build
prereq_rhel() {
  echo -e "\nInstalling RHEL prerequisite packages\n"
  sudo yum -y -q install git gcc gcc-c++ wget tar python-setuptools python-devel device-mapper libtool-ltdl-devel libffi-devel openssl-devel bzip2
  if [ $? != 0 ]; then
    echo -e "\nERROR: Unable to install pre-requisite packages.\n"
    exit 1
  fi
  if [ ! -f /usr/bin/s390x-linux-gnu-gcc ]; then
    sudo ln -s /usr/bin/s390x-redhat-linux-gcc /usr/bin/s390x-linux-gnu-gcc
  fi
}

# Install prerequisite packages for an SLES Hyperledger build
prereq_sles() {
  echo -e "\nInstalling SLES prerequisite packages\n"
  sudo SUSEConnect -p sle-module-containers/15.1/s390x
  sudo zypper --non-interactive addrepo https://download.opensuse.org/repositories/Cloud:Tools/SLE_12_SP3/Cloud:Tools.repo
  sudo zypper refresh
  sudo zypper --non-interactive in git-core gcc make gcc-c++ patterns-sles-apparmor  python3-setuptools python3-devel python3-pip gawk libtool libffi-devel libopenssl-devel bzip2 python3-PyYAML
  sudo zypper --non-interactive in git-core gcc make gcc-c++ patterns-sles-apparmor python3-setuptools python3-devel python3-pip gawk libtool libffi-devel libopenssl-devel bzip python3-PyYAML
  sudo pip3 install docker-compose==1.25.3
  if [ $? != 0 ]; then
    echo -e "\nERROR: Unable to install pre-requisite packages.\n"
    exit 1
  fi
  if [ ! -f /usr/bin/s390x-linux-gnu-gcc ]; then
    sudo ln -s /usr/bin/gcc /usr/bin/s390x-linux-gnu-gcc
  fi
}

# Install prerequisite packages for an Unbuntu Hyperledger build
prereq_ubuntu() {
  echo -e "\nInstalling Ubuntu prerequisite packages\n"
  sudo apt-get update
  sudo apt-get -y install build-essential git debootstrap python-setuptools python-dev alien libtool libffi-dev libssl-dev
  if [ $? != 0 ]; then
    echo -e "\nERROR: Unable to install pre-requisite packages.\n"
    exit 1
  fi
}

# Determine flavor of Linux OS
get_linux_flavor() {
  OS_FLAVOR=`cat /etc/os-release | grep ^NAME | sed -r 's/.*"(.*)"/\1/'`

  if grep -iq 'red' <<< $OS_FLAVOR; then
    OS_FLAVOR="rhel"
  elif grep -iq 'sles' <<< $OS_FLAVOR; then
    OS_FLAVOR="sles"
  elif grep -iq 'ubuntu' <<< $OS_FLAVOR; then
    OS_FLAVOR="ubuntu"
  else
    echo -e "\nERROR: Unsupported Linux Operating System.\n"
    exit 1
  fi
}

# Build and install the Docker Daemon
install_docker() {
  echo -e "\n*** install_docker ***\n"

  # Setup Docker for RHEL or SLES
  if [ $1 == "rhel" ]; then
    DOCKER_URL="ftp://ftp.unicamp.br/pub/linuxpatch/s390x/redhat/rhel7.3/docker-17.05.0-ce-rhel7.3-20170523.tar.gz"
    DOCKER_DIR="docker-17.05.0-ce-rhel7.3-20170523"

    # Install Docker
    cd /tmp
    wget -q $DOCKER_URL
    if [ $? != 0 ]; then
      echo -e "\nERROR: Unable to download the Docker binary tarball.\n"
      exit 1
    fi
    tar -xzf $DOCKER_DIR.tar.gz
    if [ -f /usr/bin/docker ]; then
      sudo mv /usr/bin/docker /usr/bin/docker.orig
    fi
    sudo cp $DOCKER_DIR/docker* /usr/bin

    # Setup Docker Daemon service
    if [ ! -d /etc/docker ]; then
      sudo mkdir -p /etc/docker
    fi

    # Create environment file for the Docker service
    sudo touch /etc/docker/docker.conf
    sudo chmod 664 /etc/docker/docker.conf
    echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock -s overlay"'| sudo tee -a /etc/docker/docker.conf > /dev/null
    sudo touch /etc/systemd/system/docker.service
    sudo chmod 664 /etc/systemd/system/docker.service

    # Create Docker service file
    sudo sh -c "cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com

[Service]
Type=notify
ExecStart=/usr/bin/docker daemon \$DOCKER_OPTS
EnvironmentFile=-/etc/docker/docker.conf

[Install]
WantedBy=default.target
EOF"
    # Start Docker Daemon
    sudo systemctl daemon-reload
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
  elif [ $1 == "sles" ]; then
    sudo zypper --non-interactive in docker
    sudo systemctl stop docker.service
    sudo sed -i '/^DOCKER_OPTS/ s/\"$/ \-H tcp\:\/\/0\.0\.0\.0\:2375\ -H unix:///var/run/docker.sock"/' /etc/sysconfig/docker
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
  else      # Setup Docker for Ubuntu
    sudo apt-get -y install docker.io
    sudo systemctl stop docker.service
    sudo sed -i "\$aDOCKER_OPTS=\"-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock\"" /etc/default/docker
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
  fi

  sudo groupadd docker
  BCUSER="$(whoami)"
  sudo usermod -aG docker $BCUSER
  sudo systemctl restart docker
  echo "Your userid  was not a member of the docker group. This has been corrected."
  echo -e "*** DONE ***\n"
}

# Install the Golang compiler for the s390x platform
install_golang() {
  echo -e "\n*** install_golang ***\n"
  export GOROOT="/opt/go"
  cd /tmp
  wget --quiet --no-check-certificate https://dl.google.com/go/go1.12.15.linux-s390x.tar.gz
  tar -xvf go${GO_VER}.linux-s390x.tar.gz
  sudo mv go /opt
  sudo chmod 775 /opt/go
  echo -e "*** DONE ***\n"
}

# Build the Hyperledger Fabric peer components
build_hyperledger_fabric() {
  echo -e "\n*** build_hyperledger_fabric ***\n"
 
 # Setup Environment Variables
  export GOPATH=$HOME/git
  export PATH=/opt/go/bin:$PATH

  echo "Your path is:" + $PATH 

  # Download latest Hyperledger Fabric codebase
  if [ ! -d $GOPATH/src/github.com/hyperledger ]; then
    mkdir -p $GOPATH/src/github.com/hyperledger
  fi
  
  # Delete fabric directory, if it exists
  cd $GOPATH/src/github.com/hyperledger
  rm -rf fabric
  git clone -b release-1.4 https://github.com/hyperledger/fabric.git
  cd $GOPATH/src/github.com/hyperledger/fabric
  sg docker -c "make native docker"
  

  if [ $? != 0 ]; then
    echo -e "\nERROR: Unable to build the Hyperledger Fabric peer components.\n"
    exit 1
  fi

  echo -e "*** DONE ***\n"
}

# Build the Hyperledger Fabric Membership Services components
build_hyperledger_fabric-ca() {
  echo -e "\n*** build_hyperledger_fabric-ca ***\n"

  # Download latest Hyperledger Fabric codebase
  if [ ! -d $GOPATH/src/github.com/hyperledger ]; then
    mkdir -p $GOPATH/src/github.com/hyperledger
  fi
  cd $GOPATH/src/github.com/hyperledger
  # Delete fabric directory, if it exists
  rm -rf fabric-ca
  git clone -b release-1.4 https://github.com/hyperledger/fabric-ca.git

  cd $GOPATH/src/github.com/hyperledger/fabric-ca
  sg docker -c "make fabric-ca-server fabric-ca-client docker"

  if [ $? != 0 ]; then
    echo -e "\nERROR: Unable to build the Hyperledger Membership Services components.\n"
    exit 1
  fi

#  echo -e "*** DONE ***\n"
}

# Build the Hyperledger Fabric Samples
build_hyperledger_fabric-samples() {
  echo -e "\n*** build_hyperledger_fabric-samples ***\n"

  # Download latest Hyperledger Fabric codebase
  if [ ! -d $GOPATH/src/github.com/hyperledger ]; then
    mkdir -p $GOPATH/src/github.com/hyperledger
  fi
  cd $GOPATH/src/github.com/hyperledger
  # Delete fabric directory, if it exists
  rm -rf fabric-samples
  git clone -b release-1.4 https://github.com/hyperledger/fabric-samples.git

  cd $GOPATH/src/github.com/hyperledger/fabric-samples
  ln -s $GOPATH/src/github.com/hyperledger/fabric/.build/bin bin
  ln -s $GOPATH/src/github.com/hyperledger/fabric/sampleconfig config

  if [ $? != 0 ]; then
    echo -e "\nERROR: Unable to build the Hyperledger Fabric Samples.\n"
    exit 1
  fi

  echo -e "*** DONE ***\n"
}


# Install Nodejs
install_nodejs() {
  echo -e "\n*** install_nodejs ***\n"
  cd /tmp
  wget -q https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-s390x.tar.gz
  cd /usr/local && sudo tar --strip-components=1 -xzf /tmp/node-v8.9.4-linux-s390x.tar.gz
  echo -e "*** DONE ***\n"
}

# Install Behave and its pre-requisites.  Firewall rules are also set.
setup_behave() {
  echo -e "\n*** setup_behave ***\n"
  # Setup Firewall Rules if they don't already exist
  grep -q '2375' <<< `sudo iptables -L INPUT -nv`
  if [ $? != 0 ]; then
    sudo iptables -I INPUT 1 -p tcp --dport 21212 -j ACCEPT
    sudo iptables -I INPUT 1 -p tcp --dport 7050 -j ACCEPT
    sudo iptables -I INPUT 1 -p tcp --dport 7051 -j ACCEPT
    sudo iptables -I INPUT 1 -p tcp --dport 7053 -j ACCEPT
    sudo iptables -I INPUT 1 -p tcp --dport 7054 -j ACCEPT
    sudo iptables -I INPUT 1 -i docker0 -p tcp --dport 2375 -j ACCEPT
  fi

  # Install Behave Tests Pre-Reqs
  cd /tmp
  curl -s "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
  python get-pip.py > /dev/null 2>&1
  pip install -q --upgrade pip > /dev/null 2>&1
  pip install -q behave nose docker-compose > /dev/null 2>&1
  pip install -q -I flask==0.10.1 python-dateutil==2.2 pytz==2014.3 pyyaml==3.10 couchdb==1.0 flask-cors==2.0.1 requests==2.4.3 pyOpenSSL==16.2.0 pysha3 slugify ecdsa > /dev/null 2>&1
  pip install --upgrade six
}

# Update profile with environment variables required for Hyperledger Fabric use
# Also, clean up work directories and files
post_build() {
  echo -e "\n*** post_build ***\n"

  if ! test -e /etc/profile.d/goroot.sh; then
sudo sh -c "cat <<EOF >/etc/profile.d/goroot.sh
export GOROOT=$GOROOT
export GOPATH=$GOPATH
export PATH=\$PATH:$GOROOT/bin:$GOPATH/bin:/usr/local/bin
export XDG_CACHE_HOME=/tmp/.cache
EOF"

sudo sh -c "cat <<EOF >>/etc/environment
GOROOT=$GOROOT
GOPATH=$GOPATH
EOF"

    if [ $OS_FLAVOR == "rhel" ] || [ $OS_FLAVOR == "sles" ]; then
sudo sh -c "cat <<EOF >>/etc/environment
CC=gcc
EOF"
    fi
  fi

  if [ $OS_FLAVOR == "ubuntu" ]; then
    sudo apt -y autoremove
  fi


  # Cleanup files and Docker images and containers
  sudo rm -rf /tmp/*

  echo -e "Cleanup Docker artifacts\n"
  # Delete any temporary Docker containers created during the build process
  if [[ ! -z $(docker ps -aq) ]]; then
      docker rm -f $(docker ps -aq)
  fi

  echo -e "*** DONE ***\n"
}

################
# Main Routine #
################

# Check for help flags
if [ $# == 1 ] && ([[ $1 == "-h"  ||  $1 == "--help" || $1 == "-?" || $1 == "?" || -z $(grep "-" <<< $1) ]]); then
  usage
fi

# Ensure that the user running this script is root.
#if [ xroot != x$(whoami) ]; then
#  echo -e "\nERROR: You must be root to run this script.\n"
#  exit 1
#fi

# Determine Linux distribution
get_linux_flavor

# Install pre-reqs for detected Linux OS Distribution
prereq_$OS_FLAVOR

# Default action is to build all components for the Hyperledger Fabric environment
if ! node -v > /dev/null 2>&1; then
  install_nodejs
fi

if ! docker images > /dev/null 2>&1; then
  install_docker $OS_FLAVOR
fi

if ! test -d /opt/go; then
  install_golang $OS_FLAVOR
else
  export GOROOT=/opt/go
fi

build_hyperledger_fabric $OS_FLAVOR
build_hyperledger_fabric-ca $OS_FLAVOR
build_hyperledger_fabric-samples $OS_FLAVOR


if ! behave --version > /dev/null 2>&1; then
  setup_behave
fi

post_build

echo -e "\nThe Hyperledger Fabric and its supporting components have been successfully installed. \n"    
echo -e "Some changes have been made that require you to log out and log back in."
echo -e "Please log out and log back in right now."

exit 0
