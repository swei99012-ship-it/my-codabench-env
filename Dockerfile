FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV MAX_JOBS=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    build-essential \
    ninja-build \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel packaging ninja

RUN python - <<'PY'
import sys
import torch
print("Python:", sys.version)
print("Torch:", torch.__version__)
print("CUDA:", torch.version.cuda)
assert sys.version_info[:2] == (3, 10)
assert torch.__version__.startswith("2.1.2")
assert torch.version.cuda == "11.8"
PY

RUN pip install \
    numpy==1.26.4 \
    pillow \
    timm \
    einops \
    PyWavelets \
    ftfy \
    regex \
    tqdm \
    transformers==4.44.2 \
    huggingface-hub==0.24.7

RUN pip install --no-deps git+https://github.com/openai/CLIP.git

RUN pip install \
    "https://github.com/Dao-AILab/causal-conv1d/releases/download/v1.1.1/causal_conv1d-1.1.1+cu118torch2.1cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"

RUN pip install \
    "https://github.com/state-spaces/mamba/releases/download/v1.1.1/mamba_ssm-1.1.1+cu118torch2.1cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"

RUN python - <<'PY'
import torch
import torchvision
import numpy
import PIL
import timm
import einops
import pywt
import ftfy
import regex
import tqdm
import transformers
import huggingface_hub
import clip
import causal_conv1d
import mamba_ssm
from mamba_ssm import Mamba

print("===== ENV CHECK OK =====")
print("torch:", torch.__version__)
print("torchvision:", torchvision.__version__)
print("cuda:", torch.version.cuda)
print("numpy:", numpy.__version__)
print("transformers:", transformers.__version__)
print("huggingface_hub:", huggingface_hub.__version__)
print("mamba_ssm import ok")
PY
