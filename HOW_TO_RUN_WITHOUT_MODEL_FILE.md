# 🚀 How Teammates Can Run Code Without `.pt` File

Your teammate has **3 options** to run the code without storing the model file locally:

---

## **Option 1: Download Model via Git LFS (RECOMMENDED) ⭐**

### Best for: Most developers who need the full system

```bash
# 1. Clone the repository
git clone https://github.com/STEMSight-Project/PIM.git
cd PIM

# 2. Install Git LFS
git lfs install

# 3. Pull the LFS files (includes model)
git lfs pull

# 4. Install dependencies
pip install -r Back-End/requirements.txt

# 5. Run the back-end
cd Back-End
python -m uvicorn main:app --reload
```

**Advantages:**
- ✅ Full model loaded, system fully functional
- ✅ Simple one-command setup
- ✅ Model automatically downloaded with repo

**Disadvantages:**
- ❌ Need to download 13.4 MB model file
- ❌ Git LFS not installed by default on all systems

---

## **Option 2: Download Model Separately (For Bandwidth-Limited)**

### Best for: Developers who want small clone, then download model later

```bash
# 1. Clone without LFS files (smaller repo)
git clone https://github.com/STEMSight-Project/PIM.git
cd PIM

# 2. Install dependencies
pip install -r Back-End/requirements.txt

# 3. Download model manually when needed
# Create this script: download_model.py
```

**Download Script:**

```python
# Back-End/download_model.py
import requests
import os
from pathlib import Path

def download_model():
    """Download model from CDN or repository"""
    
    model_url = "https://github.com/STEMSight-Project/PIM/releases/download/v2.0/pim_unik_model_10class_new-69-18200.pt"
    model_path = Path(__file__).parent / "services" / "ai" / "pim_unik_model_10class_new-69-18200.pt"
    
    # Create directory if not exists
    model_path.parent.mkdir(parents=True, exist_ok=True)
    
    if model_path.exists():
        print(f"✅ Model already exists at {model_path}")
        return
    
    print(f"⏳ Downloading model from {model_url}...")
    response = requests.get(model_url, stream=True)
    
    if response.status_code == 200:
        with open(model_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"✅ Model downloaded successfully to {model_path}")
    else:
        print(f"❌ Failed to download model. Status: {response.status_code}")

if __name__ == "__main__":
    download_model()
```

**Usage:**
```bash
# Download model when needed
python Back-End/download_model.py

# Then run the app
cd Back-End
python -m uvicorn main:app --reload
```

**Advantages:**
- ✅ Clone is small (~50 MB vs 400 MB with LFS)
- ✅ Download only when ready
- ✅ Can skip if only reading code

**Disadvantages:**
- ❌ Extra manual download step
- ❌ Requires internet at first run

---

## **Option 3: Lazy Loading - Download Only When API Called**

### Best for: Development team that doesn't need model loaded at startup

### Modify `pim_classifier_service.py`:

```python
# Add this at the top of the file
import urllib.request
import os

class PIMClassifier:
    """Lazy loading classifier - downloads model only when needed"""
    
    _instance = None
    _model_downloaded = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(PIMClassifier, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        self.model = None
        self.device = None
    
    def ensure_model_downloaded(self):
        """Download model if not already present"""
        
        model_path = Path(__file__).parent / "pim_unik_model_10class_new-69-18200.pt"
        
        # If model exists, we're good
        if model_path.exists():
            return True
        
        # Model not found, download it
        logger.info("📥 Model not found locally, downloading...")
        
        try:
            model_url = "https://github.com/STEMSight-Project/PIM/releases/download/v2.0/pim_unik_model_10class_new-69-18200.pt"
            
            # Create parent directory
            model_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Download with progress
            urllib.request.urlretrieve(
                model_url,
                model_path,
                reporthook=self._download_progress
            )
            
            logger.info(f"✅ Model downloaded to {model_path}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to download model: {e}")
            raise
    
    def _download_progress(self, block_num, block_size, total_size):
        """Show download progress"""
        downloaded = block_num * block_size
        percent = min(downloaded * 100 // total_size, 100)
        print(f"\r📥 Downloading model: {percent}%", end="")
    
    def load_model_if_needed(self):
        """Load model only when first API call comes in"""
        if self.model is None:
            self.ensure_model_downloaded()
            self.model, self.device = load_trained_model(
                Path(__file__).parent / "pim_unik_model_10class_new-69-18200.pt"
            )
```

**Usage:**
```bash
# Clone and run - no model needed at startup!
git clone https://github.com/STEMSight-Project/PIM.git
cd PIM
pip install -r Back-End/requirements.txt
python -m uvicorn main:app --reload

# First API call to /predict will trigger download
curl http://localhost:8000/predict -X POST -d '{"skeleton_data": [...]}'
```

**Advantages:**
- ✅ Instant startup, no wait time
- ✅ Clone is smallest possible (~50 MB)
- ✅ Download happens transparently on first use
- ✅ Perfect for CI/CD pipelines

**Disadvantages:**
- ❌ First API call is slow (includes download)
- ⚠️ Requires internet connection at runtime

---

## **Option 4: Use CPU Model Without GPU (Development Only)**

### Best for: Quick testing on machines without GPU

```python
# Use this environment variable to force CPU
import os
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

# Or modify load_trained_model():
def load_trained_model(checkpoint_path: str) -> Tuple[torch.nn.Module, torch.device]:
    # Force CPU for development
    device = torch.device("cpu")  # Always CPU
    
    # ... rest of loading code ...
```

**Trade-off:**
- ✅ No GPU needed
- ❌ Slower inference (CPU vs GPU: ~100ms vs ~10ms per frame)

---

## **Option 5: Docker Container (For Clean Environment)**

### Best for: Team consistency, guaranteed environment

**Create `Back-End/Dockerfile`:**

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Copy code
COPY . .

# Install Python dependencies
RUN pip install -r requirements.txt

# Pull Git LFS files
RUN git lfs pull

# Expose port
EXPOSE 8000

# Start API
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Usage:**
```bash
# Build image (includes model download)
docker build -t pim-backend .

# Run container
docker run -p 8000:8000 pim-backend

# Model is already in image - no need to download!
```

**Advantages:**
- ✅ Identical environment for all team members
- ✅ Model included in image
- ✅ No local Python version conflicts
- ✅ Easy deployment to servers

---

## **Recommended Setup for Your Team**

### For **Most Developers**: Option 1 (Git LFS)
```bash
# Simple, complete, one-command setup
git clone https://github.com/STEMSight-Project/PIM.git
cd PIM
git lfs install && git lfs pull
pip install -r Back-End/requirements.txt
python -m uvicorn main:app --reload
```

### For **CI/CD & Testing**: Option 3 (Lazy Loading)
- Servers download model only when needed
- Faster startup times
- Automatic on first API call

### For **Production Deployment**: Option 5 (Docker)
- Consistent environment across all machines
- Model pre-loaded in image
- One-command deployment

---

## **Current Setup Status**

```
✅ Git LFS configured for .pt files
✅ .gitignore excludes model (not committed)
✅ Model stored in: Back-End/services/ai/pim_unik_model_10class_new-69-18200.pt
✅ Alternate backup: AI_Training/UNIK/pim_unik_model_10class_new-69-18200.pt
```

### What's in Git:
- ✅ All Python code
- ✅ All configuration files
- ✅ Documentation
- ✅ Model POINTER (Git LFS)

### What's NOT in Git:
- ❌ Raw video files
- ❌ Python cache
- ❌ IDE files
- ❌ `.env` files

---

## **Troubleshooting**

### ❌ "Model file not found" error

**Solution 1: Install Git LFS**
```bash
git lfs install
git lfs pull
```

**Solution 2: Download model directly**
```bash
python Back-End/download_model.py
```

**Solution 3: Check file location**
```bash
ls -la Back-End/services/ai/pim_unik_model_10class_new-69-18200.pt
file Back-End/services/ai/pim_unik_model_10class_new-69-18200.pt
```

### ❌ "CUDA not available" error

**Use CPU instead:**
```bash
export CUDA_VISIBLE_DEVICES=-1
python -m uvicorn main:app --reload
```

---

## **Quick Reference Table**

| Option | Setup Time | Download Size | Model Load | Best For |
|--------|-----------|----------------|-----------|----------|
| 1. Git LFS | ~2 min | 400 MB | At startup | Most developers |
| 2. Manual Download | ~3 min | 50 MB + manual | At startup | Limited bandwidth |
| 3. Lazy Load | ~1 min | 50 MB | On first API call | CI/CD, testing |
| 4. CPU Mode | ~1 min | 50 MB | At startup | Quick testing |
| 5. Docker | ~5 min | Image size | In container | Production |

---

## **Recommended for Your Team Right Now**

**Tell your teammate:**

> "Clone the repo, run `git lfs pull` to get the model, then install dependencies and run the API. Takes 2 minutes total. If you don't want the model file locally, we can set up lazy loading so it downloads automatically on first API call."

This gives them options while keeping setup simple! 🚀
