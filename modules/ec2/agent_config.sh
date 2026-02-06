#!/bin/bash
set -euxo pipefail

mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add GitHub Private Key
cat > /root/.ssh/id_rsa << 'EOF'
${github_deploy_key}
EOF
chmod 600 /root/.ssh/id_rsa

# Add to known_hosts
ssh-keyscan -H github.com >> /root/.ssh/known_hosts 2>/dev/null
chmod 644 /root/.ssh/known_hosts

# Install Ansible
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Run Ansible Pull to configure the Jenkins agent
ansible-pull \
  -U git@github.com:juancamilocc/launch-ephemeral-jenkins-agents.git \
  ansible/playbooks/jenkins-agent.yaml \
  -e jenkins_controller_url=${jenkins_controller_url} \
  -e jenkins_agent_name=${jenkins_agent_name} \
  -e jenkins_agent_secret=${jenkins_agent_secret} \
  -e remote_fs_root=${remote_fs_root} \
  -e java_version=${java_version} \
  -e eks_cluster_name=${eks_cluster_name} \
  -e aws_region=${aws_region} \
  -e aws_id=${aws_id} \
  -e environment=${environment}  