# 🚀 AMD ROCm 7.0 + SimpleTuner: Flux.2-dev LoRA Workflow

Diese Anleitung beschreibt den exakten Workflow für das Training von **Flux.2-dev** LoRAs auf AMD Hardware (Strix Halo) mit **ROCm 7.0**.

---

## 🛠 1. Modell-Konfiguration: Flux.2-dev

Wir verwenden das volle **Flux.2-dev** Modell. Aufgrund der Größe (32B Parameter) nutzen wir spezifische Optimierungen für ROCm:

- **Modell-Typ**: `flux`
- **Precision**: `bf16` (für Training), `int8/quanto` (für Inference)
- **VRAM-Bedarf**: ca. 80-90GB (daher BIOS-Zuweisung von 96GB+ zwingend!)

---

## 🏗 2. SimpleTuner Setup (ROCm 7.0)

Installiere SimpleTuner und erzwinge die ROCm-Kompatibilität:
```bash
bash scripts/install_simpletuner.sh
```

---

## 🧬 3. GPU-Force & Flux-Spezifika

Um die AMD-GPU für das Flux-Training zu erzwingen, müssen diese Variablen aktiv sein:
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export HSA_XNACK=1
export GPU_MAX_ALLOC_PERCENT=100
```

### Wichtig für Flux.2-dev:
In SimpleTuner nutzen wir den **Direct-to-GPU** Load-Modus. Das bedeutet, das Modell wird in Shards direkt auf die GPU geladen, um den System-RAM nicht zu sprengen.

---

## 🏋️ 4. Der Trainings-Befehl (Exakt)

Führe das Training mit diesen exakten Parametern für Flux.2-dev aus:

```bash
source simpletuner/venv/bin/activate

python train.py \
  --model_type flux \
  --model_name_or_path "black-forest-labs/FLUX.1-dev" \
  --dataset_type multidataset \
  --data_backend_config config/dataset.json \
  --resolution 1024 \
  --train_batch_size 1 \
  --gradient_accumulation_steps 4 \
  --max_train_steps 1500 \
  --learning_rate 1e-4 \
  --mixed_precision bf16 \
  --gradient_checkpointing \
  --optimizer "adamw8bit" \
  --output_dir "output/flux2_dev_lora" \
  --push_to_hub False \
  --report_to "tensorboard"
```

---

## 🎬 5. Bild-Generierung (Flux.2-dev + LoRA)

Nach dem Training generieren wir Bilder mit dem INT8-quantisierten Dev-Modell, um VRAM zu sparen:

```bash
# Nutzt das lokale Flux.2-dev GGUF/Quanto Modell
python scripts/generate_image.py --prompt "valentinamori in Barcelona" --strength 0.8
```

---

## 🔍 Zusammenfassung der Tools
- **SimpleTuner**: Trainer
- **Flux.2-dev**: Das Basis-Modell
- **ROCm 7.0**: Der Treiber-Stack
- **Bitsandbytes-ROCm**: Für den 8-bit Optimizer
