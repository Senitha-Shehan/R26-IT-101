import os
import sys
import mimetypes
from datetime import datetime, timezone
from typing import Optional, List, Any, Dict
from pydantic import BaseModel, Field, validator
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import FileResponse
from bson import ObjectId

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from database.mongodb import get_uncertain_collection
from api.auth.security import get_current_expert

router = APIRouter(prefix="/api", tags=["Expert Reviews"])

ALLOWED_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight",
]

UPLOAD_DIR = os.path.abspath(os.path.join(PROJECT_ROOT, "uploaded_samples"))


try:
    from pydantic import field_validator
    
    class ExpertReviewSubmission(BaseModel):
        sample_id: str
        expert_label: str
        expert_notes: Optional[str] = Field(None, max_length=2000)

        @field_validator("sample_id")
        @classmethod
        def validate_sample_id(cls, v: str) -> str:
            v = v.strip()
            if not v:
                raise ValueError("sample_id cannot be empty")
            return v

        @field_validator("expert_label")
        @classmethod
        def validate_expert_label(cls, v: str) -> str:
            v = v.strip()
            if v not in ALLOWED_CLASSES:
                raise ValueError(f"Invalid disease label '{v}'. Allowed classes: {', '.join(ALLOWED_CLASSES)}")
            return v
except ImportError:
    from pydantic import validator

    class ExpertReviewSubmission(BaseModel):
        sample_id: str
        expert_label: str
        expert_notes: Optional[str] = Field(None, max_length=2000)

        @validator("sample_id")
        def validate_sample_id(cls, v):
            v = v.strip()
            if not v:
                raise ValueError("sample_id cannot be empty")
            return v

        @validator("expert_label")
        def validate_expert_label(cls, v):
            v = v.strip()
            if v not in ALLOWED_CLASSES:
                raise ValueError(f"Invalid disease label '{v}'. Allowed classes: {', '.join(ALLOWED_CLASSES)}")
            return v



def _serialize_doc(doc: Dict[str, Any]) -> Dict[str, Any]:
    """Helper to convert MongoDB BSON document to JSON-safe dictionary."""
    serialized = {}
    for key, value in doc.items():
        if key == "_id":
            serialized["id"] = str(value)
        elif isinstance(value, datetime):
            serialized[key] = value.isoformat()
        else:
            serialized[key] = value
    return serialized


@router.get("/expert/disease-classes", response_model=List[str])
async def get_disease_classes(current_expert: dict = Depends(get_current_expert)):
    """Returns official rice disease classes for expert selection."""
    return ALLOWED_CLASSES


@router.get("/expert/dashboard-stats")
async def get_dashboard_stats(current_expert: dict = Depends(get_current_expert)):
    """Returns summary stats: pending_review count, reviewed count, and total count."""
    collection = get_uncertain_collection()
    if collection is None:
        return {"pending_review": 0, "reviewed": 0, "total": 0}

    pending_count = collection.count_documents({"status": {"$in": ["pending_review", "pending"]}})
    reviewed_count = collection.count_documents({"status": {"$in": ["reviewed", "annotated"]}})
    total_count = collection.count_documents({})

    return {
        "pending_review": pending_count,
        "reviewed": reviewed_count,
        "total": total_count,
    }


@router.get("/expert/pending-samples")
async def get_pending_samples(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    region: Optional[str] = None,
    disease: Optional[str] = None,
    min_confidence: Optional[float] = Query(None, ge=0.0, le=1.0),
    max_confidence: Optional[float] = Query(None, ge=0.0, le=1.0),
    current_expert: dict = Depends(get_current_expert),
):
    """Retrieve paginated list of pending uncertain samples for expert review."""
    collection = get_uncertain_collection()
    if collection is None:
        return {"items": [], "total": 0, "page": page, "pages": 0}

    query: Dict[str, Any] = {"status": {"$in": ["pending_review", "pending"]}}

    if region and region.strip():
        query["region"] = region.strip()
    if disease and disease.strip():
        query["predicted_disease"] = disease.strip()

    if min_confidence is not None or max_confidence is not None:
        conf_query = {}
        if min_confidence is not None:
            conf_query["$gte"] = min_confidence
        if max_confidence is not None:
            conf_query["$lte"] = max_confidence
        query["confidence"] = conf_query

    total_items = collection.count_documents(query)
    total_pages = (total_items + limit - 1) // limit if total_items > 0 else 0
    skip = (page - 1) * limit

    cursor = (
        collection.find(query)
        .sort([("created_at", -1), ("uploaded_at", -1)])
        .skip(skip)
        .limit(limit)
    )

    items = [_serialize_doc(doc) for doc in cursor]

    return {
        "items": items,
        "total": total_items,
        "page": page,
        "pages": total_pages,
    }


@router.get("/expert/reviewed-samples")
async def get_reviewed_samples(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    region: Optional[str] = None,
    ai_disease: Optional[str] = None,
    expert_disease: Optional[str] = None,
    reviewer: Optional[str] = None,
    current_expert: dict = Depends(get_current_expert),
):
    """Retrieve paginated history of reviewed samples."""
    collection = get_uncertain_collection()
    if collection is None:
        return {"items": [], "total": 0, "page": page, "pages": 0}

    query: Dict[str, Any] = {"status": {"$in": ["reviewed", "annotated"]}}

    if region and region.strip():
        query["region"] = region.strip()
    if ai_disease and ai_disease.strip():
        query["predicted_disease"] = ai_disease.strip()
    if expert_disease and expert_disease.strip():
        query["expert_label"] = expert_disease.strip()
    if reviewer and reviewer.strip():
        query["reviewed_by"] = reviewer.strip()

    total_items = collection.count_documents(query)
    total_pages = (total_items + limit - 1) // limit if total_items > 0 else 0
    skip = (page - 1) * limit

    cursor = (
        collection.find(query)
        .sort([("reviewed_at", -1), ("uploaded_at", -1)])
        .skip(skip)
        .limit(limit)
    )

    items = [_serialize_doc(doc) for doc in cursor]

    return {
        "items": items,
        "total": total_items,
        "page": page,
        "pages": total_pages,
    }


@router.get("/uncertain-samples/{sample_id}")
async def get_sample_detail(
    sample_id: str,
    current_expert: dict = Depends(get_current_expert),
):
    """Retrieve complete sample details for an expert review session."""
    collection = get_uncertain_collection()
    if collection is None:
        raise HTTPException(
            status_code=status.HTTP_533_SERVICE_UNAVAILABLE if hasattr(status, "HTTP_533") else status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection unavailable",
        )

    # Search by sample_id string or BSON ObjectId
    query = {"sample_id": sample_id.strip()}
    doc = collection.find_one(query)
    if not doc and ObjectId.is_valid(sample_id.strip()):
        doc = collection.find_one({"_id": ObjectId(sample_id.strip())})

    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Sample with ID '{sample_id}' not found.",
        )

    return _serialize_doc(doc)


@router.get("/uncertain-samples/{sample_id}/image")
async def get_sample_image(
    sample_id: str,
    current_expert: dict = Depends(get_current_expert),
):
    """
    Securely serves the image file for an uncertain sample.
    Validates token, looks up sample path, and enforces directory traversal checks.
    """
    collection = get_uncertain_collection()
    if collection is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection unavailable",
        )

    query = {"sample_id": sample_id.strip()}
    doc = collection.find_one(query)
    if not doc and ObjectId.is_valid(sample_id.strip()):
        doc = collection.find_one({"_id": ObjectId(sample_id.strip())})

    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Sample '{sample_id}' not found.",
        )

    raw_path = doc.get("image_path", "")
    if not raw_path:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No image path recorded for this sample.",
        )

    # Normalize relative path to backend root
    if raw_path.startswith("uploaded_samples/"):
        filename = os.path.basename(raw_path)
        resolved_path = os.path.abspath(os.path.join(UPLOAD_DIR, filename))
    else:
        resolved_path = os.path.abspath(os.path.join(PROJECT_ROOT, raw_path))

    # Path traversal protection
    try:
        common = os.path.commonpath([resolved_path, UPLOAD_DIR])
        if common != UPLOAD_DIR:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied: Directory traversal detected.",
            )
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied: Invalid file path.",
        )

    if not os.path.exists(resolved_path) or not os.path.isfile(resolved_path):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Image file not found on server filesystem.",
        )

    media_type, _ = mimetypes.guess_type(resolved_path)
    if not media_type:
        media_type = "image/jpeg"

    return FileResponse(resolved_path, media_type=media_type)


@router.post("/expert/reviews", status_code=status.HTTP_200_OK)
async def submit_expert_review(
    review: ExpertReviewSubmission,
    current_expert: dict = Depends(get_current_expert),
):
    """
    Submits an expert ground-truth review for an uncertain sample.
    Updates expert_label, expert_notes, status='reviewed', reviewed_at, and reviewed_by.
    PRESERVES original AI prediction, confidence, region, model_id, image_path, created_at.
    Prevents double review (returns 409 Conflict if already reviewed).
    """
    collection = get_uncertain_collection()
    if collection is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection unavailable",
        )

    sample_id = review.sample_id.strip()
    query = {"sample_id": sample_id}
    doc = collection.find_one(query)
    if not doc and ObjectId.is_valid(sample_id):
        doc = collection.find_one({"_id": ObjectId(sample_id)})

    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Sample with ID '{sample_id}' not found.",
        )

    current_status = doc.get("status", "pending_review")
    if current_status in ["reviewed", "annotated"]:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This sample has already been reviewed.",
        )

    now_iso = datetime.now(timezone.utc).isoformat()
    reviewer_email = current_expert.get("email", "expert@cropguard.org")

    update_fields = {
        "expert_label": review.expert_label,
        "expert_notes": review.expert_notes.strip() if review.expert_notes else "",
        "status": "reviewed",
        "reviewed_at": now_iso,
        "reviewed_by": reviewer_email,
    }

    result = collection.update_one({"_id": doc["_id"]}, {"$set": update_fields})

    if result.modified_count == 0:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to record expert review in database.",
        )

    # Fetch updated doc
    updated_doc = collection.find_one({"_id": doc["_id"]})
    return {
        "message": "Expert label submitted successfully.",
        "sample": _serialize_doc(updated_doc),
    }
