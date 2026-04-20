# AMD ROCm LoRA Workflow (Flux.2-dev & Wan2.2)

Dieses Repository enthält eine vollständige Anleitung und Skripte zur Installation von ROCm, zum Training von LoRAs mit **SimpleTuner / AI-Toolkit** und zur Generierung von Bildern und Videos auf **AMD GPUs (ROCm)**.

Optimiert für: **AMD Strix Halo (Ryzen AI Max 395)** und andere Radeon GPUs.

---

## 1. System-Vorbereitung (BIOS & OS)

### BIOS / VRAM (für APUs wie Strix Halo)
Für das Training von Flux.2-dev (32B Modell) werden mindestens **64GB bis 96GB VRAM** empfohlen.
- Setze im BIOS den **UMA Framebuffer Size** auf einen festen Wert (z.B. 96GB oder 112GB).
- Deaktiviere "Auto" VRAM, um Instabilitäten zu vermeiden.

### GRUB-Parameter
Optimierung des Speichermanagements für AMD GPUs:
```bash
# Edit /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.no_system_mem_limit=1"
sudo update-grub
sudo reboot
```

---

## 2. Installation von ROCm (AMD Treiber)

Führe das Installationsskript aus:
```bash
bash scripts/install_rocm.sh
```
Dieses Skript installiert den AMD GPU-Treiber und den ROCm 6.x Stack.

---

## 3. LoRA Training (SimpleTuner / AI-Toolkit)

### Installation
```bash
bash scripts/install_training.sh
```

### GPU-Nutzung erzwingen
Damit PyTorch die AMD GPU korrekt anspricht (insbesondere bei neuen Architekturen wie gfx1151), müssen folgende Umgebungsvariablen gesetzt sein:
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1  # Für Strix Halo (gfx1151)
export HSA_XNACK=1
export GPU_MAX_ALLOC_PERCENT=100
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
```

### Training starten
```bash
cd ai-toolkit
python3 run.py config/train_lora.yaml
```

---

## 4. Bild- und Video-Generierung

### Bilder (Flux.2-dev + LoRA)
Nutze das mitgelieferte Python-Skript:
```bash
python3 scripts/generate_image.py "Valentina Mori, portrait, cinematic lighting" --lora_path path/to/lora.safetensors
```

### Videos (Wan2.2)
Videos werden lokal über Wan2GP generiert:
```bash
bash scripts/generate_video.sh "A woman smiling" --start_image image.png
```

---

## Lizenz
Dieses Projekt ist für die private Nutzung und Forschung optimiert.
