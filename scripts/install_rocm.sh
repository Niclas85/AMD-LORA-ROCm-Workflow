#!/bin/bash
# ROCm 6.1 Installation für Ubuntu 22.04/24.04

echo "Starte ROCm Installation..."
sudo apt update
sudo apt install -y wget gnupg2 shellinabox

# AMD Repo hinzufügen
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.1.1/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/amdgpu.list
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.1.1 $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/rocm.list

# Installation
sudo apt update
sudo apt install -y amdgpu-dkms rocm-hip-sdk rocm-visualizer
sudo usermod -a -G video,render $USER

echo "Installation fertig. Bitte REBOOT ausführen!"
