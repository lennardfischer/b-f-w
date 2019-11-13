#!/bin/env bash
sudo dnf update -y
sudo dnf install -y ansible
sudo dnf install grubby
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
exec ./provision.sh

