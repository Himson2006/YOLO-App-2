# 1. Base image with Python
FROM python:3.8-slim

# 2. System packages for OpenCV, ffmpeg & psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libgl1-mesa-glx \
      libglib2.0-0 \
      libpq-dev \
      ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 3. Set working dir
WORKDIR /usr/src/app

# 4. Copy & install Python deps
COPY requirements.txt ./
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 5. Copy app source
COPY . .

# 6. Ensure uploads/incoming exists
RUN mkdir -p app/uploads/incoming

# 7. Expose port
EXPOSE 5000

# 8. Entrypoint runs both watcher & Gunicorn
#    NOTE: runtime env (DATABASE_URL, WATCH_FOLDER, etc.) comes from docker-compose.yml
CMD ["sh", "-c", "\
    python watcher.py & \
    gunicorn --bind 0.0.0.0:5000 run:app --workers 2 --threads 4 \
"]
