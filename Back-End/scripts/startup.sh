#!/bin/bash
set -euo pipefail

FFMPEG_VER=6.1.1
INSTALL_DIR=/home/site/ffmpeg
mkdir -p "$INSTALL_DIR"

if [ ! -f "$INSTALL_DIR/ffmpeg" ]; then
  cd /tmp
  curl -L "https://johnvansickle.com/ffmpeg/releases/ffmpeg-${FFMPEG_VER}-linux64-static.tar.xz" -o ffmpeg.tar.xz
  tar -xf ffmpeg.tar.xz
  cp ffmpeg-${FFMPEG_VER}-linux64-static/{ffmpeg,ffprobe} "$INSTALL_DIR"
  chmod +x "$INSTALL_DIR/"*
fi

export PATH="$INSTALL_DIR:$PATH"
cd /home/site/wwwroot/Back-End
exec gunicorn -k uvicorn.workers.UvicornWorker -w 1 -b 0.0.0.0:${PORT:-8000} main:app --access-logfile - --timeout 120