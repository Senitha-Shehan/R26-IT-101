import os
import re
import sys
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status
from fastapi.responses import JSONResponse

# Ensure backend root is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from database.mongodb import get_uncertain_collection
from api.schemas.uncertain_sample import HealthResponse, UncertainSampleResponse

router = APIRouter(prefix="/api", tags=["Uncertain Samples"])

UPLOAD_DIR = os.path.join(PROJECT_ROOT, "uploaded_samples")
os.makedirs(UPLOAD_DIR, exist_ok=True)

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB limit


@router.get("/health", response_model=HealthResponse)
def health_check():
    """
    Health check endpoint for checking API status.
    Does not expose any secrets or environment variables.
    """
    return HealthResponse(status="ok")


@router.post(
    "/uncertain-samples",
    response_model=UncertainSampleResponse,
    status_code=status.HTTP_201_CREATED,
)
async def upload_uncertain_sample(
    sample_id: str = Form(..., description="Unique client-side sample identifier"),
    predicted_disease: str = Form(..., description="Predicted disease class name"),
    confidence: float = Form(..., description="Prediction confidence score between 0.0 and 1.0"),
    region: str = Form(..., description="Agricultural region identifier"),
    model_id: str = Form(..., description="Model filename or identifier"),
    timestamp: Optional[str] = Form(None, description="ISO timestamp of detection"),
    image: UploadFile = File(..., description="Uncertain leaf image file"),
):
    """
    Upload an uncertain sample (< 0.80 confidence) to the backend.
    Stores the leaf image on the backend filesystem and records metadata in MongoDB Atlas.
    Implements idempotent behavior using unique sample_id.
    """
    # ---------------------------------------------------------
    # 1. Input Validation
    # ---------------------------------------------------------
    sample_id = sample_id.strip()
    if not sample_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="sample_id cannot be empty.",
        )

    # Sanitize sample_id to prevent path traversal or injection
    if not re.match(r"^[a-zA-Z0-9_-]+$", sample_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="sample_id contains invalid characters.",
        )

    if not predicted_disease or not predicted_disease.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="predicted_disease cannot be empty.",
        )

    if not region or not region.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="region cannot be empty.",
        )

    if confidence < 0.0 or confidence > 1.0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="confidence must be between 0.0 and 1.0.",
        )

    # Validate image extension
    filename = image.filename or "sample.jpg"
    ext = os.path.splitext(filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file extension '{ext}'. Allowed extensions: {', '.join(sorted(ALLOWED_EXTENSIONS))}",
        )

    # Validate image size & contents
    content = await image.read()
    if len(content) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded image file is empty.",
        )

    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image size exceeds maximum limit of 10 MB.",
        )

    # ---------------------------------------------------------
    # 2. Database Connection & Idempotency Check
    # ---------------------------------------------------------
    collection = get_uncertain_collection()
    if collection is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="MongoDB database connection unavailable.",
        )

    # Ensure unique index on sample_id if not created
    try:
        collection.create_index("sample_id", unique=True, sparse=True)
    except Exception:
        pass

    # Check for existing sample_id (Duplicate Protection)
    existing_sample = collection.find_one({"sample_id": sample_id})
    if existing_sample:
        # Return existing document with 200 OK (Idempotent response)
        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content={
                "sample_id": existing_sample.get("sample_id", sample_id),
                "image_path": existing_sample.get("image_path", ""),
                "predicted_disease": existing_sample.get("predicted_disease", predicted_disease),
                "confidence": float(existing_sample.get("confidence", confidence)),
                "region": existing_sample.get("region", region),
                "model_id": existing_sample.get("model_id", model_id),
                "status": existing_sample.get("status", "pending_review"),
                "created_at": str(existing_sample.get("created_at", "")),
                "uploaded_at": str(existing_sample.get("uploaded_at", "")),
                "expert_label": existing_sample.get("expert_label", None),
                "is_duplicate": True,
            },
        )

    # ---------------------------------------------------------
    # 3. File System Storage (Safe Server-Side Filename)
    # ---------------------------------------------------------
    safe_filename = f"{sample_id}{ext}"
    target_filepath = os.path.join(UPLOAD_DIR, safe_filename)
    relative_image_path = f"uploaded_samples/{safe_filename}"

    try:
        with open(target_filepath, "wb") as f:
            f.write(content)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save image file on server: {str(e)}",
        )

    # ---------------------------------------------------------
    # 4. MongoDB Record Creation
    # ---------------------------------------------------------
    uploaded_at_dt = datetime.now(timezone.utc)
    uploaded_at_iso = uploaded_at_dt.isoformat()

    created_at_str = timestamp.strip() if timestamp and timestamp.strip() else uploaded_at_iso

    doc = {
        "sample_id": sample_id,
        "image_path": relative_image_path,
        "predicted_disease": predicted_disease.strip(),
        "confidence": float(confidence),
        "region": region.strip(),
        "model_id": model_id.strip(),
        "status": "pending_review",
        "created_at": created_at_str,
        "uploaded_at": uploaded_at_iso,
        "expert_label": None,
    }

    try:
        collection.insert_one(doc)
    except Exception as e:
        # Check if race condition inserted same sample_id
        duplicate_check = collection.find_one({"sample_id": sample_id})
        if duplicate_check:
            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content={
                    "sample_id": sample_id,
                    "image_path": relative_image_path,
                    "predicted_disease": predicted_disease,
                    "confidence": float(confidence),
                    "region": region,
                    "model_id": model_id,
                    "status": "pending_review",
                    "created_at": created_at_str,
                    "uploaded_at": uploaded_at_iso,
                    "expert_label": None,
                    "is_duplicate": True,
                },
            )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to insert record in MongoDB: {str(e)}",
        )

    return UncertainSampleResponse(
        sample_id=sample_id,
        image_path=relative_image_path,
        predicted_disease=predicted_disease.strip(),
        confidence=float(confidence),
        region=region.strip(),
        model_id=model_id.strip(),
        status="pending_review",
        created_at=created_at_str,
        uploaded_at=uploaded_at_iso,
        expert_label=None,
        is_duplicate=False,
    )
