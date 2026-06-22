# 1. 稳固的地基
FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}

# 🚀 终极防崩溃锁：强制单核排队编译，防止 GitHub 的 7GB 内存爆满被强杀！
ENV MAX_JOBS=1

# 2. 安装系统级底层依赖包
RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 3. 升级 pip
RUN pip install --upgrade pip

# 4. 编译三剑客
RUN pip install --no-cache-dir packaging ninja wheel

# 5. 安装常规深度学习与图像处理库
RUN pip install --no-cache-dir \
    timm \
    einops \
    transformers \
    numpy \
    pillow \
    opencv-python \
    PyWavelets \
    thop \
    tqdm \
    ftfy \
    regex \
    lpips

# 6. 从 GitHub 源码拉取 CLIP
RUN pip install --no-cache-dir git+https://github.com/openai/CLIP.git

# 7. 终极逃课大法：直接安装官方预编译的 Wheel 包（彻底跳过编译阶段！）
# 以下链接完美匹配咱们的底层环境：PyTorch 2.1 + CUDA 11.8 + Python 3.10
RUN pip install https://github.com/Dao-AILab/causal-conv1d/releases/download/v1.1.1/causal_conv1d-1.1.1+cu118torch2.1cxx11abiFALSE-cp310-cp310-linux_x86_64.whl
RUN pip install https://github.com/state-spaces/mamba/releases/download/v1.1.1/mamba_ssm-1.1.1+cu118torch2.1cxx11abiFALSE-cp310-cp310-linux_x86_64.whl
