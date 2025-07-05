# Stage 1: Build environment
FROM nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04 AS builder

RUN apt-get update -yq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config wget cmake curl git vim

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -u -p /root/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/root/miniconda3/bin:$PATH"

# Create environment and install dependencies
RUN conda create -n nerfstream python=3.10 -y
COPY requirements.txt ./
RUN /root/miniconda3/bin/conda run -n nerfstream pip install -r requirements.txt
RUN /root/miniconda3/bin/conda run -n nerfstream pip install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN /root/miniconda3/bin/conda run -n nerfstream pip install tensorflow-gpu==2.8.0
RUN /root/miniconda3/bin/conda run -n nerfstream pip uninstall -y protobuf
RUN /root/miniconda3/bin/conda run -n nerfstream pip install protobuf==3.20.1
RUN /root/miniconda3/bin/conda run -n nerfstream conda install ffmpeg -y

# Copy your code
COPY . /nerfstream

# Stage 2: Minimal runtime image
FROM nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04

RUN apt-get update -yq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config wget cmake curl git vim

# Copy Miniconda and environment from builder
COPY --from=builder /root/miniconda3 /root/miniconda3
COPY --from=builder /nerfstream /nerfstream

ENV PATH="/root/miniconda3/bin:$PATH"

WORKDIR /nerfstream
CMD ["/root/miniconda3/envs/nerfstream/bin/python", "app.py"] 