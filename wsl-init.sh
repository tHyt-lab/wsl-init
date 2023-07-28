#!bin/bash

sudo apt-get update
sudo apt-get upgrade -y

# Docker install
{
  echo
  echo "**************************************************"
  echo Install Docker.
  echo "**************************************************"
  echo
}
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER
sudo /etc/init.d/docker start
echo "sudo /etc/init.d/docker start" >> ~/.bashrc

# docker compose
{
  echo
  echo "**************************************************"
  echo Install Docker Compose.
  echo "**************************************************"
  echo
}
sudo apt-get remove docker-compose
sudo rm /usr/local/bin/docker-compose

# docker compose v1
# compose_version=$(curl https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
# output='/usr/local/bin/docker-compose'
# sudo curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-$(uname -s)-$(uname -m) -o $output
# sudo chmod +x $output
# echo $(docker-compose version)

# docker compose v2
output=$(eval echo '$HOME/.docker/cli-plugins/docker-compose')
if [ ! -e $output ]; then
  compose_version=$(curl https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
  mkdir -p $HOME/.docker/cli-plugins
  sudo curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-$(uname -s)-$(uname -m) -o $output
  sudo chmod +x $output
  echo $(docker compose version)
fi

# docker rootless
docker_rootless=$(sudo cat /etc/sudoers | grep '%docker ALL=(ALL)  NOPASSWD: /etc/init.d/dockesr')
if [ -z "$docker_rootless" ]; then
  echo '%docker ALL=(ALL)  NOPASSWD: /etc/init.d/docker' | sudo EDITOR='tee -a' visudo
fi

# linuxbrew Install
{
  echo
  echo "**************************************************"
  echo Install linuxbrew.
  echo "**************************************************"
  echo
}
sudo apt-get update
sudo apt-get -y install build-essential curl file git
echo enter | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

brew install ghq peco

{
  echo 'function ghql() {'
  echo '  local selected_file=$(ghq list --full-path | peco --query "$LBUFFER")'
  echo '  if [ -n "$selected_file" ]; then'
  echo '    if [ -t 1 ]; then'
  echo '      code ${selected_file}'
  echo '    fi'
  echo '  fi'
  echo '}'
  echo ''
  echo 'bind -x '\''"\\201": ghql'\'''
  echo 'bind '\''"\C-g":"\\201\C-m"'\'''
} >> ~/.bashrc


# Git Setting (GitHub)
# {
#   echo
#   echo "**************************************************"
#   echo Install linuxbrew.
#   echo "**************************************************"
#   echo
# }
# sudo apt-get -y install openssh-client socat

# git config --global ghq.root "~/develop/src"

# ssh-keygen -t ed25519 -f ~/.ssh/github_key -C "" -N ""
# {
#   echo 'Host github github.com'
#   echo '  HostName github.com'
#   echo '  User git'
#   echo '  IdentityFile ~/.ssh/github_key'
# } >> ~/.ssh/config

# {
#   echo 'if [ -z "$SSH_AUTH_SOCK" ]; then'
#   echo '  RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"'
#   echo '  if [ "$RUNNING_AGENT" = "0" ]; then'
#   echo '    ssh-agent -s &> $HOME/.ssh/ssh-agent'
#   echo '  fi'
#   echo '  eval `cat $HOME/.ssh/ssh-agent`'
#   echo 'fi'
#   echo 'ssh-add $HOME/.ssh/github_key'
# } >> ~/.profile

{
  echo
  echo "**************************************************"
  echo The process is now complete.
  echo Please restart WSL.
  echo "**************************************************"
  echo
}