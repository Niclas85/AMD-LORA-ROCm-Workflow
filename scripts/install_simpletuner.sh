#!/bin/bash
echo "Installiere SimpleTuner für ROCm..."

git clone https://github.com/bghira/SimpleTuner.git simpletuner
cd simpletuner

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# ROCm PyTorch Installation
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2

# SimpleTuner Dependencies
pip install -r requirements.txt
pip install optimum onnxruntime-rocm

# Bitsandbytes für ROCm (Wichtig für 8-bit Optimizer)
pip install bitsandbytes-rocm
