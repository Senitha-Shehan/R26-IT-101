import os
import sys
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

# Ensure backend root is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.routes.uncertain_samples import router as uncertain_samples_router

app = FastAPI(
    title="CropGuard Active Learning REST API",
    description="Python REST API providing health check and uncertain sample synchronization for CropGuard Edge AI system.",
    version="1.0.0",
)

# CORS configuration for future Expert Web Application (Phase 6)
ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# Mount uploaded_samples static directory to serve images for expert review
UPLOADED_SAMPLES_DIR = os.path.join(PROJECT_ROOT, "uploaded_samples")
os.makedirs(UPLOADED_SAMPLES_DIR, exist_ok=True)
app.mount("/uploaded_samples", StaticFiles(directory=UPLOADED_SAMPLES_DIR), name="uploaded_samples")

# Register routers
app.include_router(uncertain_samples_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)
