FROM python:3.10-slim-bullseye AS builder

# 1. Install EXACT build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    git \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone fresh (avoids cache issues)
WORKDIR /app
COPY . .

# 3. PRECISE dependency installation
RUN pip install --no-cache-dir \
    Cython==0.29.32 \
    numpy==1.21.6 \
    && pip install -e .

# 4. SAFE build command
RUN python setup.py build_ext --inplace -j 4 --verbose

# ------------------------
FROM python:3.10-slim-bullseye

# 5. Runtime essentials only
RUN apt-get update && apt-get install -y \
    libgomp1 \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app
WORKDIR /app

CMD ["python", "hummingbot.py", "start"]

# Set the default command to run when starting the container

CMD conda activate hummingbot && ./bin/hummingbot_quickstart.py 2>> ./logs/errors.log
