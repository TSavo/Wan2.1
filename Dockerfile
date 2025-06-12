FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python 3.11 and essential packages
RUN apt-get update && \
    apt-get install -y git curl python3.11 python3.11-venv python3.11-distutils && \
    ln -s /usr/bin/python3.11 /usr/local/bin/python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install uv for fast pip
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Copy project
COPY . /app

# Create virtual environment and install dependencies
RUN uv venv --python 3.11 && \
    . .venv/bin/activate && \
    uv pip install setuptools torch nvitop && \
    uv pip install -r requirements.txt --no-build-isolation && \
    uv pip install "huggingface_hub[cli]"

# Prepare HuggingFace cache directory
ENV HF_HOME=/hf_download/huggingface
RUN mkdir -p "$HF_HOME"

EXPOSE 7860

CMD ["bash", "-c", ". .venv/bin/activate && python gradio/t2v_1.3B_singleGPU.py --prompt_extend_method local_qwen --prompt_extend_model Qwen/Qwen2.5-7B-Instruct --ckpt_dir /hf_download/Wan2.1-T2V-1.3B"]
