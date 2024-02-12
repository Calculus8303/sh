#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y linux-headers-generic

WSL2_VERSION=$(uname -r)
echo "WSL2_VERSION = $WSL2_VERSION"

WSL2_LINK="/lib/modules/$WSL2_VERSION"
if [ -L "${WSL2_LINK}" ]; then
    if [ -e "${WSL2_LINK}" ]; then
        echo "Good link"
        exit 0
    else
        echo "Broken link"
        rm "${WSL2_LINK}"
    fi
elif [ -e "${WSL2_LINK}" ]; then
    echo "Not a link"
    exit 1
else
    echo "Missing"
fi

shopt -s nullglob
for filename in /lib/modules/*; do
    echo "$filename"
    if [ -z "$HEADERS_DIR" ]; then
        HEADERS_DIR="$filename"
    else
        echo "HEADERS_DIR already set to $HEADERS_DIR, fail"
        exit 1
    fi
done

if [ -n "$HEADERS_DIR" ]; then
    echo "Create symbolic link $WSL2_LINK => $HEADERS_DIR"
    ln -s "$HEADERS_DIR" "$WSL2_LINK"
fi

sudo usermod -a -G render,video $LOGNAME
wget https://repo.radeon.com/amdgpu-install/6.0.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb
sudo apt update && sudo apt install amdgpu-dkms rocm-hip-libraries ffmpeg libsm6 libxext6  libgl1 python3-venv  -y
git clone https://github.com/lllyasviel/Fooocus.git && cd Fooocus && python3 -m venv fooocus_env && source fooocus_env/bin/activate
pip install -r requirements_versions.txt && pip uninstall torch torchvision torchaudio torchtext functorch xformers && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.7
HSA_OVERRIDE_GFX_VERSION=10.3.0 HCC_AMDGPU_TARGET=gfx1030 python3 entry_with_update.py --preset realistic
