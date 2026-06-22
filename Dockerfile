# 1. 完美匹配你 AutoDL 版本的地基（PyTorch 2.1.2 + CUDA 11.8 + C++编译工具链）
FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel
# 2. 设置环境变量，防止安装时卡在时区/键盘选择界面
ENV DEBIAN_FRONTEND=noninteractive

# 3. 安装必要的系统级底层依赖包
RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 4. 升级 pip
RUN pip install --upgrade pip

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

# 7. 终极 BOSS：编译安装状态空间模型架构库
# 由于我们使用了与你 AutoDL 完全一致的 devel 基础镜像，这里会自动触发完美的 CUDA 编译
RUN pip install --no-cache-dir causal-conv1d mamba-ssm
