"""
Disease treatment recommendation endpoint (RAG).

Farmer-facing (unauthenticated, like the other Flutter-client endpoints such as
/api/uncertain-samples). It takes an identified disease name and returns a
structured recommendation built ONLY from the multilingual PDF Knowledge Base.
"""
import logging
import os
import sys
from typing import Optional

from fastapi import APIRouter, HTTPException, Path, Query, status

# Ensure backend root is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.schemas.treatment import TreatmentRequest, TreatmentResponse
from rag import service
from rag.generator import OllamaUnavailableError

logger = logging.getLogger("api.treatment")

router = APIRouter(prefix="/api/disease", tags=["Treatment (RAG)"])


def _run(disease_name: str, crop: Optional[str], confidence: Optional[float], language: str) -> TreatmentResponse:
    disease_name = (disease_name or "").strip()
    if not disease_name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="disease_name cannot be empty.",
        )
    try:
        result = service.get_treatment(
            disease_name=disease_name,
            crop=crop,
            confidence=confidence,
            language=language or "en",
        )
    except OllamaUnavailableError as exc:
        logger.error("RAG generation unavailable: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Treatment service is temporarily unavailable. Please try again later.",
        )
    except Exception as exc:  # defensive: never leak stack traces to the client
        logger.exception("Unexpected RAG error for '%s': %s", disease_name, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate treatment recommendation.",
        )
    return TreatmentResponse(**result)


@router.post("/treatment", response_model=TreatmentResponse)
def get_treatment_post(payload: TreatmentRequest):
    """Primary endpoint for the Flutter client (JSON body)."""
    return _run(payload.disease_name, payload.crop, payload.confidence, payload.language or "en")


@router.get("/{disease_name}/treatment", response_model=TreatmentResponse)
def get_treatment_get(
    disease_name: str = Path(..., description="Identified disease class name"),
    crop: Optional[str] = Query(None),
    confidence: Optional[float] = Query(None, ge=0.0, le=1.0),
    language: str = Query("en"),
):
    """Convenience path-style variant: GET /api/disease/{disease_name}/treatment."""
    return _run(disease_name, crop, confidence, language)
