"""Pydantic schemas for the disease treatment (RAG) endpoint."""
from typing import List, Optional

from pydantic import BaseModel, Field


class TreatmentRequest(BaseModel):
    disease_name: str = Field(..., description="Identified disease class name from the scan")
    crop: Optional[str] = Field(None, description="Optional crop hint, e.g. 'rice'")
    confidence: Optional[float] = Field(
        None, ge=0.0, le=1.0, description="Scan confidence score (0.0 - 1.0), if available"
    )
    language: Optional[str] = Field(
        "en", description="Preferred output language code: en | si | ta"
    )


class TreatmentSource(BaseModel):
    source_file: str
    page_number: int
    similarity: float


class TreatmentResponse(BaseModel):
    found: bool = Field(..., description="True if grounded treatment info was retrieved")
    disease_name: str
    confidence: Optional[float] = None
    language: str
    message: str = Field("", description="Populated with a note when found is false")
    description: str = ""
    symptoms: List[str] = []
    treatment: List[str] = []
    recommended_actions: List[str] = []
    prevention: List[str] = []
    warnings: List[str] = []
    sources: List[TreatmentSource] = []
    generation_mode: str = Field(
        "", description="How the answer was produced: 'ollama' | 'extractive' | 'none'"
    )
