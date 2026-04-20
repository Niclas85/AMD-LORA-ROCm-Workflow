#!/bin/bash
# Setup für AI-Toolkit (SimpleTuner Alternative) mit ROCm Support

git clone https://github.com/ostris/ai-toolkit.git
cd ai-toolkit
git submodule update --init --recursive

# Venv mit ROCm PyTorch
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0
pip install -r requirements.txt
pip install peft diffusers transformers
