FROM python:3.10-slim-bullseye AS builder

# 1. Install EXACT build toolchain
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-10 \
    g++-10 \
    git \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Set alternative GCC version
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100

WORKDIR /app
COPY . .

# 3. Install PRECISE versions
RUN pip install --no-cache-dir \
    Cython==0.29.32 \
    numpy==1.21.6 \
    pandas==1.3.5 \
    && pip install -e .

# 4. Modified build command
RUN python setup.py build_ext --inplace -j 2 --verbose 2>&1 | tee build.log

# ------------------------
FROM python:3.10-slim-bullseye

# 5. Runtime environment
RUN apt-get update && apt-get install -y \
    libgomp1 \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app
WORKDIR /app

CMD ["python", "hummingbot.py", "start"]
