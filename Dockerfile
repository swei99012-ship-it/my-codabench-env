# 1. 稳固的地基
FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive

# 🚀 新增安全锁：显式指定 CUDA 路径，防止编译时找不到 nvcc 编译器
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}

# 2. 安装系统级底层依赖包
RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 3. 升级 pip
RUN pip install --upgrade pip

# 🚀 核心修改：必须在安装任何大包之前，先安装编译“三剑客”
# Ninja 负责多线程加速编译 CUDA，packaging 负责处理版本，wheel 负责打包
RUN pip install --no-cache-dir packaging ninja wheel

# 4. 安装常规深度学习与图像处理库
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

# 5. 从 GitHub 源码拉取 CLIP
RUN pip install --no-cache-dir git+https://github.com/openai/CLIP.git

# 6. 再次挑战终极 BOSS
# 此时因为有了前面 ninja 的加持，系统会开启多线程顺畅编译，绝不会再轻易报错
RUN pip install --no-cache-dir causal-conv1d mamba-ssm
