VOL_DIR="$NFS_VOLUME"
COMFY_DIR="$VOL_DIR/ComfyUI"
# Check if the ComfyUI directory exists
if [ ! -d "$COMFY_DIR" ]; then
    cd "$VOL_DIR"
    git clone https://github.com/comfyanonymous/ComfyUI.git && cd ComfyUI && git pull
    pip install -r requirements.txt
else
    cd "$COMFY_DIR" && git pull
fi

# Create necessary directories if they don't exist
mkdir -p "$COMFY_DIR/models/unet"
mkdir -p "$COMFY_DIR/models/clip"
mkdir -p "$COMFY_DIR/models/vae"
mkdir -p "$VOL_DIR/workflows"
# Function to download file with progress bar if it doesn't exist
download_file() {
    local url=$1
    local destination=$2
    local header=$3
    local filename=$(basename "$destination")

    if [ -f "$destination" ]; then
    else
        if [ -n "$header" ]; then
            wget --header="$header" --progress=bar:force -c -O "$destination" "$url"
        else
            wget --progress=bar:force -c -O "$destination" "$url"
        fi
    fi
}

# Authorization header for Hugging Face
AUTH_HEADER="Authorization: Bearer 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"

# Download UNET model with authorization header
download_file "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" "$COMFY_DIR/models/unet/flux1-dev.safetensors" "$AUTH_HEADER"

# Download CLIP models without authorization header
download_file "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" "$COMFY_DIR/models/clip/t5xxl_fp16.safetensors"
download_file "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "$COMFY_DIR/models/clip/clip_l.safetensors"
download_file "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors" "$COMFY_DIR/models/clip/t5xxl_fp8_e4m3fn.safetensors"

# Download VAE model without authorization header
download_file "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors" "$COMFY_DIR/models/vae/ae.safetensors"

# Download SD1.5 for workflow-2
download_file "https://huggingface.co/autismanon/modeldump/resolve/main/dreamshaper_8.safetensors" "$COMFY_DIR/models/checkpoints/dreamshaper_8.safetensors"

# Download the workflow files
download_file "https://github.com/rbgo404/ComfyUI-inferless-template/raw/main/workflows/flux_workflow.json" "$VOL_DIR/workflows/flux_workflow.json"
download_file "https://github.com/rbgo404/ComfyUI-inferless-template/raw/test-comfyui/workflows/sd1-5_workflow.json" "$VOL_DIR/workflows/sd1-5_workflow.json"