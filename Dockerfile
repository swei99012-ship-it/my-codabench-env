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

# 7. 再次迎战终极 BOSS
# 加了 MAX_JOBS=1 后，系统会慢条斯理地安全编译，绝不会再崩溃
RUN pip install --no-cache-dir causal-conv1d mamba-ssm
