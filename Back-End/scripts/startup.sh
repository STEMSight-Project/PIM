#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/home/site/wwwroot/Back-End"   # <- change if your app lives elsewhere
PORT_TO_USE="${PORT:-8000}"

# Prefer the App Service virtualenv if present
if [ -d "/home/site/wwwroot/antenv/bin" ]; then
  export PATH="/home/site/wwwroot/antenv/bin:$PATH"
elif [ -d "/home/site/wwwroot/venv/bin" ]; then
  export PATH="/home/site/wwwroot/venv/bin:$PATH"
fi

# Optional FFmpeg install (non-fatal if it fails)
{
  FFMPEG_DIR="/home/site/ffmpeg"
  FFMPEG_BIN="$FFMPEG_DIR/ffmpeg"
  if [ ! -x "$FFMPEG_BIN" ]; then
    mkdir -p "$FFMPEG_DIR"
    cd /tmp
    # More reliable mirror; if this fails, we skip without blocking boot
    curl -fsSL https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.tar.xz -o ffmpeg.tar.xz
    tar -xJf ffmpeg.tar.xz
    FOUND_DIR="$(find . -maxdepth 1 -type d -name 'ffmpeg-*' | head -n1 || true)"
    if [ -n "${FOUND_DIR:-}" ]; then
      if [ -x "$FOUND_DIR/bin/ffmpeg" ]; then
        cp "$FOUND_DIR/bin/ffmpeg" "$FOUND_DIR/bin/ffprobe" "$FFMPEG_DIR" 2>/dev/null || true
      else
        cp "$FOUND_DIR/ffmpeg" "$FOUND_DIR/ffprobe" "$FFMPEG_DIR" 2>/dev/null || true
      fi
      chmod +x "$FFMPEG_DIR/"* || true
    fi
  fi
  export PATH="$FFMPEG_DIR:$PATH"
} || echo "FFmpeg install skipped (non-fatal)."

# Ensure we can import gunicorn + uvicorn (clear error message if not)
python - <<'PY'
import importlib
importlib.import_module("gunicorn")
importlib.import_module("uvicorn")
PY

# Enter your app directory (must exist) and start gunicorn
cd "$APP_DIR"
exec python -m gunicorn \
  -k uvicorn.workers.UvicornWorker \
  -w 1 \
  -b "0.0.0.0:${PORT_TO_USE}" \
  main:app \
  --access-logfile - \
  --error-logfile - \
  --timeout 120 \
  --log-level info
