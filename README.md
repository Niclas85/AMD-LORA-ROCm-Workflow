# 🚀 AMD ROCm 7.0 + SimpleTuner LoRA Workflow

Diese Anleitung beschreibt den exakten Workflow für das Training von Flux.2-dev LoRAs mit **SimpleTuner** auf **ROCm 7.0**. Optimiert für High-End AMD Hardware wie den **Ryzen AI Max 395 (Strix Halo)**.

---

## 🛠 1. Hardware & ROCm 7.0 Setup

### VRAM & BIOS
- **Zuweisung**: 96GB bis 112GB fixer UMA VRAM im BIOS.
- **GRUB**: `amdgpu.no_system_mem_limit=1` muss aktiv sein.

### Installation ROCm 7.0
ROCm 7 bietet verbesserte Unterstützung für die gfx1151 Architektur.
```bash
bash scripts/install_rocm7.sh
```

---

## 🏗 2. SimpleTuner Installation

SimpleTuner ist das leistungsfähigste Tool für Multi-GPU und APU Training von Flux Modellen.

```bash
bash scripts/install_simpletuner.sh
```

---

## 🧬 3. GPU Erzwingen beim Training

SimpleTuner muss explizit angewiesen werden, die Hardware-ID zu überschreiben, da ROCm 7 die Strix Halo APU (gfx1151) zwar unterstützt, viele Bibliotheken aber noch auf gfx1100-Pfaden laufen.

**Diese Variablen sind Pflicht:**
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export HSA_XNACK=1
export GPU_MAX_ALLOC_PERCENT=100
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
export MIOPEN_FIND_MODE=FAST
```

---

## 🏋️ 4. LoRA Training mit SimpleTuner

### Konfiguration
SimpleTuner nutzt eine `.env` Datei und ein JSON/YAML-Backend für Datensätze.

1. **Datensatz**: Lege deine Bilder in `dataset/` ab.
2. **Konfiguration**: Nutze die Vorlage in `config/simpletuner_flux.json`.

### Training starten
```bash
source simpletuner/venv/bin/activate
# Erzwinge GPU
export HSA_OVERRIDE_GFX_VERSION=11.5.1
# Starte SimpleTuner
python train.py \
  --model_type flux \
  --model_name_or_path black-forest-labs/FLUX.1-dev \
  --dataset_type multidataset \
  --data_backend_config config/dataset.json \
  --resolution 1024 \
  --train_batch_size 1 \
  --gradient_accumulation_steps 4 \
  --max_train_steps 1500 \
  --learning_rate 1e-4 \
  --mixed_precision bf16 \
  --gradient_checkpointing \
  --output_dir output/valentina_lora
```

---

## 🎬 5. Bild- & Video-Generierung

### Bilder (Local Flux + LoRA)
```bash
python scripts/generate_image.py "valentinamori, a woman smiling"
```

### Videos (Wan 2.2 i2v)
Nutze das Wan2GP Backend (Port 8188) oder das lokale Skript:
```bash
bash scripts/generate_video.sh --start-image output.png
```

---

## 🚨 Troubleshooting ROCm 7
- **HIP Error**: Wenn das Training abstürzt, prüfe `rocm-smi`.
- **Inkompatibilität**: Stelle sicher, dass `bitsandbytes` für ROCm korrekt installiert ist (in `install_simpletuner.sh` enthalten).

