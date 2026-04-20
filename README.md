# 🚀 AMD ROCm LoRA Workflow: Deep Dive Guide

Diese Anleitung beschreibt den ultimativen Workflow für LoRA-Training und Medien-Generierung auf AMD-Hardware (speziell optimiert für **AMD Strix Halo / Ryzen AI Max 395** mit 128GB Unified Memory).

---

## 🛠 1. Hardware & BIOS (Das Fundament)

Damit Flux.2-dev (ein 32B Parameter Modell) stabil trainiert, ist der VRAM-Flaschenhals entscheidend.

### BIOS-Einstellungen (APU)
- **UMA Framebuffer Size**: Setze diesen Wert auf **96GB** oder **112GB**.
- **Wichtig**: Nutze **KEIN "Auto"**, da die dynamische Zuweisung unter Linux/ROCm oft zu Crashes führt. Ein fester Wert garantiert, dass PyTorch den Speicher als "Dedicated VRAM" sieht.

### OS Tuning (GRUB)
AMD Treiber brauchen oft Zugriff auf den gesamten Systemspeicher ohne künstliche Limits:
```bash
# /etc/default/grub anpassen
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.no_system_mem_limit=1"
sudo update-grub
sudo reboot
```

---

## 🏗 2. Die Tool-Stack

In diesem Workflow nutzen wir folgende Profi-Tools:
1. **Training**: [AI-Toolkit (by Ostris)](https://github.com/ostris/ai-toolkit) - Aktuell das stabilste Tool für Flux-LoRAs.
2. **Bild-Inference**: [Wan2GP](https://github.com/DeepBeepMeep/Wan2GP) - Optimiert für AMD/ROCm (nutzt GGUF/Quanto Quantisierung).
3. **Video-Inference**: **Wan 2.2 (14B)** - Aktueller State-of-the-Art für Image-to-Video.
4. **Backend**: **ROCm 6.1.x** - Die AMD-Entsprechung zu Nvidias CUDA.

---

## 🧬 3. GPU Erzwingen (Der AMD-Secret-Hack)

Die Hardware (gfx1151 / Strix Halo) ist oft so neu, dass Software sie nicht erkennt. Wir "täuschen" PyTorch vor, es handele sich um eine bekannte Architektur.

### Die magischen Variablen:
Diese müssen **VOR** dem Start eines Trainings oder einer Generierung exportiert werden:

```bash
# Maskiert die APU als gfx1151 (Strix Halo Architektur)
export HSA_OVERRIDE_GFX_VERSION=11.5.1

# Erlaubt Zugriff auf Unified Memory (wichtig für APUs)
export HSA_XNACK=1

# Erzwingt, dass 100% der GPU-Zuweisung erlaubt sind
export GPU_MAX_ALLOC_PERCENT=100

# Aktiviert experimentelle Beschleunigung (AOTriton)
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1

# Schnellerer Suchmodus für GPU-Kernel
export MIOPEN_FIND_MODE=FAST
```

---

## 📥 4. Installation (Schritt für Schritt)

### ROCm 6.1 installieren
```bash
bash scripts/install_rocm.sh
```

### AI-Toolkit (Training) installieren
```bash
bash scripts/install_training.sh
```
*Hinweis: Das Skript installiert eine spezielle PyTorch-Version von den AMD-Servern.*

---

## 🏋️ 5. LoRA Training (Flux.2-dev)

### Datensatz vorbereiten
Erstelle einen Ordner `dataset/` mit:
- `bild1.jpg`, `bild1.txt` (Inhalt: "valentinamori, a woman...")
- `bild2.jpg`, `bild2.txt` ...

### Training-Config (`config/train_lora.yaml`)
Entscheidende Parameter für AMD:
- **optimizer: adamw8bit** (spart VRAM)
- **dtype: bf16** (beste Präzision für Flux)
- **gradient_checkpointing: true** (MUSS an sein, sonst VRAM-Overflow)

### Startbefehl:
```bash
source ai-toolkit/venv/bin/activate
export HSA_OVERRIDE_GFX_VERSION=11.5.1
python3 ai-toolkit/run.py config/train_lora.yaml
```

---

## 🎬 6. Video-Generierung (Wan 2.2)

Wan 2.2 ist ein extrem schweres Modell (14B Parameter). Auf der APU nutzen wir die **INT8-Quantisierung**.

### Workflow:
1. Erzeuge ein Startbild mit deinem neuen LoRA.
2. Nutze das Video-Skript:
```bash
# Video aus Bild erzeugen (Image-to-Video)
python3 scripts/generate_video.sh --start-image valentina_image.png --prompt "Valentina is smiling"
```

---

## 🚨 Troubleshooting

| Fehler | Lösung |
|---|---|
| `HIP error: unspecified launch failure` | GPU-Takt oder VRAM überlastet. Reduziere Auflösung oder Batch Size. |
| `Out of Memory (OOM)` | Prüfe ob `amdgpu.no_system_mem_limit=1` aktiv ist. |
| `Illegal Instruction` | `HSA_OVERRIDE_GFX_VERSION` wurde nicht korrekt gesetzt. |

