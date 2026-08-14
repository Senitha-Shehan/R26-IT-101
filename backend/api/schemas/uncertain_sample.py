from typing import Optional
from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = "ok"


class UncertainSampleResponse(BaseModel):
    sample_id: str
    image_path: str
    predicted_disease: str
    confidence: float
    region: str
    model_id: str
    status: str
    created_at: str
    uploaded_at: str
    expert_label: Optional[str] = None
    is_duplicate: bool = False
