# 🚀 AMD ROCm 7.0 + SimpleTuner: Flux.2-dev LoRA Workflow

Diese Anleitung beschreibt den exakten Workflow für das Training von **Flux.2-dev** LoRAs auf AMD Hardware (Strix Halo) mit **ROCm 7.0**. 

---

## 🛠 1. Modell-Konfiguration: Flux.2-dev

Wir verwenden das volle **Flux.2-dev** Modell. Aufgrund der Größe (32B Parameter) nutzen wir spezifische Optimierungen für ROCm:

- **Modell-Typ**: `flux`
- **Precision**: `bf16` (für Training)
- **VRAM-Bedarf**: ca. 80-90GB (daher BIOS-Zuweisung von 96GB+ zwingend!)

---

## 🏗 2. SimpleTuner Setup (ROCm 7.0)

Installiere SimpleTuner und erzwinge die ROCm-Kompatibilität:
```bash
bash scripts/install_simpletuner.sh
```

---

## 🧬 3. GPU-Force & System-Hacks (Die Lebensretter)

Um die AMD-GPU (Strix Halo) für das Flux-Training fehlerfrei zu nutzen, müssen diese Variablen **zwingend** aktiv sein, um Abstürze zu verhindern:
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export HSA_XNACK=1
export GPU_MAX_ALLOC_PERCENT=100
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
# Verhindert CUDA Out-Of-Memory durch Fragmentierung auf AMD APUs:
export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"
```

---

## 🏋️ 4. Der Trainings-Befehl (Sicher & Stabil)

Führe das Training mit diesen exakten Parametern für Flux.2-dev aus.

**Wichtige Erkenntnisse für das Training:**
1. **Unbuffered Logging (`-u`)**: Beim Start im Hintergrund (`nohup`) immer `python -u` nutzen, da sonst die Logs bei riesigen Modellen gepuffert werden und es fälschlicherweise so aussieht, als sei der Prozess eingefroren.
2. **Base Model Precision**: Nutze `--base_model_precision bf16` anstatt `int8-quanto`, um Speicher-Fragmentierungs-Abstürze beim Laden des 45GB-Modells zu vermeiden.
3. **Projekt-Isolation**: Vergib immer einen eindeutigen `--project_name` und `--output_dir`, und nutze `--resume_from_checkpoint="null"`, da SimpleTuner sonst alte Caches lädt und sofort abbricht, weil es denkt, es sei fertig.

```bash
source simpletuner/venv/bin/activate

# Umgebungsvariablen setzen
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export HSA_XNACK=1
export GPU_MAX_ALLOC_PERCENT=100
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"
export HIP_VISIBLE_DEVICES=0

# Sicherer Hintergrund-Start
nohup python -u train.py \
  --model_type flux \
  --model_name_or_path "/home/niklaus/flux2-dev-local" \
  --project_name "mein_neues_lora_projekt" \
  --dataset_type multidataset \
  --data_backend_config config/dataset.json \
  --resolution 1024 \
  --train_batch_size 1 \
  --gradient_accumulation_steps 4 \
  --max_train_steps 2000 \
  --save_every 100 \
  --learning_rate 1e-4 \
  --mixed_precision bf16 \
  --base_model_precision bf16 \
  --gradient_checkpointing \
  --optimizer "adamw8bit" \
  --output_dir "output/mein_neues_lora" \
  --resume_from_checkpoint="null" > training.log 2>&1 &
```

---

## 🚨 5. Troubleshooting (Lessons Learned)

Falls das System crasht, prüfe diese häufigen Fallen:
- **"Process exits immediately"**: SimpleTuner hat einen alten Cache gefunden. Lösung: Neuen `project_name` setzen und den alten `output`-Ordner aufräumen.
- **"CUDA out of memory" (obwohl genug VRAM da ist)**: Das ist Speicherfragmentierung auf der APU. Lösung: `PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"` zwingend setzen.
- **Log bleibt leer**: Python puffert Ausgaben. Lösung: `python -u train.py` verwenden.
- **"ModuleList is not supported" (PEFT)**: Wenn man nicht über SimpleTuner trainiert, sondern manuell peft anwendet, muss man die Layer manuell filtern (z.B. `to_out.0` statt `to_out`), da neuere Flux-Architekturen die Weights in ModuleLists verpacken.

---

## 🎬 6. Bild-Generierung (Flux.2-dev + LoRA)

```bash
# Nutzt das lokale Modell
python scripts/generate_image.py --prompt "portrait in Barcelona" --strength 0.8
```

## 🔍 Zusammenfassung der Tools
- **SimpleTuner**: Trainer
- **Flux.2-dev**: Das Basis-Modell
- **ROCm 7.0**: Der Treiber-Stack
- **Bitsandbytes-ROCm**: Für den 8-bit Optimizer
