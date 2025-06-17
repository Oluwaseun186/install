#!/bin/bash

#install jenkins
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins



sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version
openjdk version "21.0.3" 2024-04-16
OpenJDK Runtime Environment (build 21.0.3+11-Debian-2)
OpenJDK 64-Bit Server VM (build 21.0.3+11-Debian-2, mixed mode, sharing)


sudo systemctl enable jenkins

sudo systemctl start jenkins

sudo systemctl status jenkins

#agent nodes optional
#curl -sO http://localhost:8080/jnlpJars/agent.jar;java -jar agent.jar -url http://localhost:8080/ -secret 3a32f8f0e8742e6782cdf7e817a918f64da1c5ee2507cd5c9a61151303844721 -name node1 -webSocket -workDir "/home/bimpe/INSTALLATION/jenkins"


#set up grafana dashbard using docker
#docker run -d  -p 3000:3000 grafana/grafana

#set up prometheus dashboard 
  #docker run -d -p 9090:9090  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus


#install grafana  using SUDO
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server


#install prometheus using SUDO
# Extract and install with proper permissions
sudo systemctl stop prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar xvf prometheus-*.tar.gz
sudo cp prometheus-*/prometheus /usr/local/bin/
sudo systemctl start prometheus

# Install in your home directory instead
mkdir -p ~/prometheus
tar xvf prometheus-*.tar.gz -C ~/prometheus --strip-components=1
echo 'export PATH=$PATH:~/prometheus' >> ~/.bashrc
source ~/.bashrc
prometheus --version


#node_exporter for grafana 

sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 644 /etc/systemd/system/node_exporter.service

#Temporarily disable web security to test:
sudo systemctl stop prometheus
sudo -u prometheus /usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.enable-lifecycle \
  --web.enable-admin-api
sudo systemctl restart prometheus

#INSTALL ALAERT-MANAGER
# Download and install
wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
tar xvf alertmanager-*.tar.gz
sudo mv alertmanager-*/alertmanager /usr/local/bin/
sudo mv alertmanager-*/amtool /usr/local/bin/
sudo mkdir -p /etc/alertmanager
sudo mkdir -p /var/lib/alertmanager

