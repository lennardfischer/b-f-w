#!/bin/env bash
sudo dnf update -y
sudo dnf install -y ansible
mkdir /etc/docker /etc/containers

tee /etc/containers/registries.conf<<EOF
[registries.insecure]
registries = ['172.30.0.0/16']
EOF

tee /etc/docker/daemon.json<<EOF
{
   "insecure-registries": [
     "172.30.0.0/16"
   ]
}
EOF

systemctl daemon-reload
systemctl restart docker

systemctl enable docker

echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
sysctl -p


DOCKER_BRIDGE=`docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
firewall-cmd --permanent --new-zone dockerc
firewall-cmd --permanent --zone dockerc --add-source $DOCKER_BRIDGE
firewall-cmd --permanent --zone dockerc --add-port={80,443,8443}/tcp
firewall-cmd --permanent --zone dockerc --add-port={53,8053}/udp
firewall-cmd --reload
sudo dnf install grubby
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
exec ./provision.sh

