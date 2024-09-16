#!/bin/bash

BASE="https://raw.githubusercontent.com/BlackIceNodeRunner/BlackIceGuides/main/base.sh"
source <(curl -s $BASE)
bold=$(tput bold)
normal=$(tput sgr0)
DOCKER_COMPOSE_YAML="https://raw.githubusercontent.com/ora-io/tora-docker-compose/main/docker-compose.yml"
DIR_NAME=tora
clear
logo

# Update system
header "Updating System and installing Tmux"
sudo apt update && sudo apt upgrade -y && sudo apt install tmux -y

# Remoove old docker versions
header "Remooving old Docker versions"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc;
    do sudo apt-get remove $pkg;
done

# Add Docker's official GPG key:
header "Installing Docker and Docker Compose"
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Create directory
clear
logo
header "Creatind directory for node"
mkdir -p $HOME/$DIR_NAME && cd $HOME/$DIR_NAME
sleep 1
echo "Done!"

# Download docker-compose.yml
header "Downloading docker-compose file"
wget -q -O docker-compose.yml $DOCKER_COMPOSE_YAML && chmod 755 docker-compose.yml
sleep 1
echo "Done!"

#Create env file
header "Creating env file"
read -p "Enter your private key: " PRIV_KEY
read -p "Enter your Alchemy WSS URL for Ethereum Mainnet: " MAINNET_WSS
read -p "Enter your Alchemy HTTP URL for Ethereum Mainnet: " MAINNET_HTTP
read -p "Enter your Alchemy WSS URL for Sepolia Ethereum: " SEPOLIA_WSS
read -p "Enter your Alchemy HTTP URL for Sepolia Ethereum: " SEPOLIA_HTTP

cat <<EOF > .env
############### Sensitive config ###############

PRIV_KEY="$PRIV_KEY"

############### General config ###############

TORA_ENV=production

MAINNET_WSS="$MAINNET_WSS"
MAINNET_HTTP="$MAINNET_HTTP"
SEPOLIA_WSS="$SEPOLIA_WSS"
SEPOLIA_HTTP="$SEPOLIA_HTTP"

REDIS_TTL=86400000

############### App specific config ###############

CONFIRM_CHAINS='["sepolia"]'
CONFIRM_MODELS='[13]'

CONFIRM_USE_CROSSCHECK=true
CONFIRM_CC_POLLING_INTERVAL=3000
CONFIRM_CC_BATCH_BLOCKS_COUNT=300

CONFIRM_TASK_TTL=2592000000
CONFIRM_TASK_DONE_TTL=2592000000
CONFIRM_CC_TTL=2592000000
EOF

sleep 1
echo "Done!"

sudo sysctl vm.overcommit_memory=1

# Start tmux session
header "Starting Tmux session"
echo "If you don't want to create session press ^C"
read -p "Enter Tmux session name: " new_session_name
tmux new -s -d $new_session_name
tmux send-keys -t $new_session_name 'docker compose up' 'Enter'
