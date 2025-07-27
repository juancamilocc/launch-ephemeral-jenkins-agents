#!/bin/bash
set -euxo pipefail

# Install requirements
sudo apt update
sudo apt install -y \
  openjdk-${java_version}-jre-headless \
  default-jdk \
  maven \
  python3-pip \
  amazon-ecr-credential-helper \
  docker.io \
  git-all \
  jq \
  curl \
  unzip \
  apt-transport-https \
  ca-certificates \
  gnupg \
  software-properties-common

# Update CA certificates
sudo update-ca-certificates

# Install kubectl
curl -LO "https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl 

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
rm -rf awscliv2.zip aws 

# Configure EKS access
sudo mkdir -p /home/ubuntu/.kube
sudo chown ubuntu:ubuntu /home/ubuntu/.kube
sudo -u ubuntu /usr/local/bin/aws eks update-kubeconfig --name ${eks_cluster_name} --region ${aws_region} --kubeconfig /home/ubuntu/.kube/config

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

# Install yq and update kubernetes context
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
sudo -u ubuntu yq ".contexts[] |= select(.name == \"arn:aws:eks:${aws_region}:${aws_id}:cluster/${environment}\") .name = \"${environment}\"" -i /home/ubuntu/.kube/config

# ECR configuration
sudo mkdir -p /home/ubuntu/.docker
sudo chown ubuntu:ubuntu /home/ubuntu/.docker
sudo -u ubuntu bash -c "cat <<EOF > /home/ubuntu/.docker/config.json
{
  \"credHelpers\": {
       \"${aws_id}.dkr.ecr.${aws_region}.amazonaws.com\": \"ecr-login\"
  }
}
EOF"

# Configuration as jenkins agent
sudo mkdir -p ${remote_fs_root}
sudo chown ubuntu:ubuntu ${remote_fs_root}

# Get JAR Jenkins Agent
sudo -u ubuntu curl -sS "${jenkins_controller_url}/jnlpJars/agent.jar" -o "${remote_fs_root}/agent.jar"

# Create script to execute jenkins agent
sudo -u ubuntu bash -c "cat <<EOF > ${remote_fs_root}/start_agent.sh
#!/bin/bash
java -jar "${remote_fs_root}/agent.jar" \
  -url "${jenkins_controller_url}/" \
  -secret "${jenkins_agent_secret}" \
  -name "${jenkins_agent_name}" \
  -workDir "${remote_fs_root}"
EOF"

# Give permissions
sudo -u ubuntu chmod +x "${remote_fs_root}/start_agent.sh"

# Create a service to execute Jenkins Agent
cat <<EOF > /etc/systemd/system/jenkins-agent.service
[Unit]
Description=Jenkins Agent
After=network.target

[Service]
ExecStart=${remote_fs_root}/start_agent.sh
User=ubuntu 
Group=ubuntu
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
WorkingDirectory=${remote_fs_root}

Environment="MAVEN_OPTS=-Djdk.tls.client.protocols=TLSv1.2 -Djdk.tls.server.enableSessionTicketExtension=false -Djdk.tls.client.enableSessionTicketExtension=false"

[Install]
WantedBy=multi-user.target
EOF

# Run and enable docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Run and enable Jenkins agent
sudo systemctl daemon-reload
sudo systemctl enable jenkins-agent
sudo systemctl start jenkins-agent