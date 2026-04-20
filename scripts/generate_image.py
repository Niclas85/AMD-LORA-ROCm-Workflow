import os
import torch
from diffusers import FluxPipeline

# Force ROCm GPU
os.environ["HSA_OVERRIDE_GFX_VERSION"] = "11.5.1"

def generate(prompt, lora_path=None):
    pipe = FluxPipeline.from_pretrained("black-forest-labs/FLUX.1-dev", torch_dtype=torch.bfloat16)
    pipe.to("cuda")
    
    if lora_path:
        pipe.load_lora_weights(lora_path)
        
    image = pipe(prompt, num_inference_steps=25, guidance_scale=3.5).images[0]
    image.save("output.png")
    print("Bild gespeichert unter output.png")

if __name__ == "__main__":
    generate("A test image")
