#!/bin/bash
echo "Installiere ROCm 7.0 (Beta/Nightly Repo)..."
sudo apt update
sudo apt install -y wget gnupg2

# Repository für Version 7.0
wget -qO- https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/7.0 ubuntu main" | sudo tee /etc/apt/sources.list.d/rocm.list

sudo apt update
sudo apt install -y rocm-hip-sdk7.0.0 rocm-visualizer7.0.0 amdgpu-dkms
sudo usermod -a -G video,render $USER
