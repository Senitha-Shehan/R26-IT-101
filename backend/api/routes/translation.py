"""
Translation endpoint.

Translates already-generated More Details / treatment content into a supported
language via Gemini. Runs strictly after the RAG system has produced the English
content -- it does not touch detection or RAG logic. Farmer-facing (unauthenticated,
matching the other Flutter-client endpoints).
"""
import logging
import os
import sys

from fastapi import APIRouter, HTTPException, status

# Ensure backend root is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.schemas.translation import TranslationRequest, TranslationResponse
from translation import gemini
from translation.gemini import TranslationConfigError, TranslationError

logger = logging.getLogger("api.translation")

router = APIRouter(prefix="/api/translation", tags=["Translation"])

MAX_TEXT_CHARS = 20000  # guard against oversized payloads


@router.post("/translate", response_model=TranslationResponse)
def translate(payload: TranslationRequest):
    text = payload.text or ""
    target = (payload.targetLanguage or "").strip().lower()

    # ---- Validation -------------------------------------------------------
    if not text.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="text cannot be empty.",
        )
    if len(text) > MAX_TEXT_CHARS:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"text exceeds the maximum of {MAX_TEXT_CHARS} characters.",
        )
    if target not in gemini.SUPPORTED_LANGUAGES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported targetLanguage '{target}'. Use one of: "
            f"{', '.join(sorted(gemini.SUPPORTED_LANGUAGES))}.",
        )

    # English target is a no-op (client caches the original), but handle it cleanly.
    if target == "en":
        return TranslationResponse(success=True, translatedText=text, language="en")

    # ---- Translate --------------------------------------------------------
    try:
        translated = gemini.translate(text=text, target_language=target, source_language="en")
    except TranslationConfigError as exc:
        logger.error("Translation not configured: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Translation service is not configured on the server.",
        )
    except TranslationError as exc:
        # Provider/transport error -> report failure without a stack trace.
        logger.error("Translation failed: %s", exc)
        return TranslationResponse(
            success=False, translatedText="", language=target, message=str(exc)
        )

    return TranslationResponse(success=True, translatedText=translated, language=target)
