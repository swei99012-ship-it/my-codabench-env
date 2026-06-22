# 1. 基础镜像：PyTorch 2.1.2 + CUDA 11.8 + cuDNN8 + devel 编译环境
FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}

# 防止某些包意外源码编译时把 GitHub Runner 内存打爆
ENV MAX_JOBS=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# 2. 系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    build-essential \
    ninja-build \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 3. 确认基础镜像里的 Python / Torch / CUDA
RUN python - <<'PY'
import sys
import torch
print("Python:", sys.version)
print("Torch:", torch.__version__)
print("Torch CUDA:", torch.version.cuda)
assert sys.version_info[:2] == (3, 10), "This wheel requires Python 3.10 / cp310"
assert torch.__version__.startswith("2.1.2"), "Expected torch 2.1.2 from base image"
assert torch.version.cuda == "11.8", "Expected CUDA 11.8"
PY

# 4. 升级基础安装工具
RUN python -m pip install --upgrade pip setuptools wheel packaging ninja

# 5. 安装测试所需 Python 包
# 注意：这里不写 torch / torchvision，因为基础镜像已经包含匹配版本
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

# 6. 安装 OpenAI CLIP
# 用 --no-deps，避免它重新解析依赖，把 torch / torchvision 搞乱
RUN pip install --no-deps git+https://github.com/openai/CLIP.git

# 7. 安装 causal-conv1d 预编译 wheel
# 匹配：CUDA 11.8 + Torch 2.1 + Python 3.10 + Linux x86_64
RUN pip install \
    "https://github.com/Dao-AILab/causal-conv1d/releases/download/v1.1.1/causal_conv1d-1.1.1+cu118torch2.1cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"

# 8. 安装 mamba-ssm 预编译 wheel
# 匹配：CUDA 11.8 + Torch 2.1 + Python 3.10 + Linux x86_64
RUN pip install \
    "https://github.com/state-spaces/mamba/releases/download/v1.1.1/mamba_ssm-1.1.1+cu118torch2.1cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"

# 9. 最后做一次 import 检查
# 注意：这里不要跑 .cuda()，因为 GitHub Docker build 阶段通常没有 GPU
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
print("mamba_ssm:", mamba_ssm.__version__ if hasattr(mamba_ssm, "__version__") else "import ok")
PY
