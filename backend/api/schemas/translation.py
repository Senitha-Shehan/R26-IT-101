"""Pydantic schemas for the translation endpoint."""
from pydantic import BaseModel, Field


class TranslationRequest(BaseModel):
    text: str = Field(..., description="Original (English) content to translate")
    targetLanguage: str = Field(..., description="Target language code: en | si | ta")


class TranslationResponse(BaseModel):
    success: bool
    translatedText: str = ""
    language: str = ""
    message: str = Field("", description="Populated with an error note when success is false")
