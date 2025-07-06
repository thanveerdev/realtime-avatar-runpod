FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel

# Install extra system dependencies
RUN apt-get update -yq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    ffmpeg libgl1-mesa-glx libsm6 libxext6 libxrender1 ca-certificates

# Copy your code
COPY . /nerfstream

WORKDIR /nerfstream

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install "git+https://github.com/facebookresearch/pytorch3d.git" && \
    pip install tensorflow-gpu==2.8.0 && \
    pip uninstall -y protobuf && \
    pip install protobuf==3.20.1

CMD ["python", "app.py"] 