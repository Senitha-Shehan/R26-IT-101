"""
Gemini-backed translation.

Calls the Gemini REST API (no extra SDK needed -- uses the existing `requests`
dependency). The API key is read from the backend environment (GEMINI_API_KEY)
and never leaves the server.
"""
import logging
import os

import requests
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("translation.gemini")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash").strip()
GEMINI_TIMEOUT_SECONDS = int(os.getenv("GEMINI_TIMEOUT_SECONDS", "45"))
GEMINI_ENDPOINT = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "{model}:generateContent"
)

# Supported language codes -> human-readable names used in the prompt.
SUPPORTED_LANGUAGES = {
    "en": "English",
    "si": "Sinhala",
    "ta": "Tamil",
}

# The strict, mandated translation instruction.
_INSTRUCTION = (
    "Translate the following crop disease information into the requested target "
    "language. Preserve the original meaning exactly. Do not add new information, "
    "remove information, diagnose anything new, or change treatment recommendations. "
    "Preserve headings, bullet points, numbered lists, dosage/measurement values, "
    "crop names, disease names, scientific names, and formatting where possible. Use "
    "natural and easy-to-understand language appropriate for farmers. Return only the "
    "translated content without explanations."
)

# Extra guardrail so the More Details section markers (e.g. §SYMPTOMS§) survive.
_MARKER_NOTE = (
    "Keep any special marker lines (for example lines wrapped in § symbols such as "
    "§SYMPTOMS§) exactly as they are, in English, untranslated, each on its own line."
)


class TranslationError(RuntimeError):
    """Raised when translation cannot be completed."""


class TranslationConfigError(TranslationError):
    """Raised when the service is misconfigured (e.g. missing API key)."""


def is_configured() -> bool:
    return bool(GEMINI_API_KEY)


def translate(text: str, target_language: str, source_language: str = "en") -> str:
    """
    Translate `text` into `target_language` (code). Returns the translated string.

    Raises TranslationConfigError if the API key is missing, or TranslationError on
    any Gemini/transport failure or unexpected response.
    """
    target_language = (target_language or "").lower()
    source_language = (source_language or "en").lower()

    if target_language not in SUPPORTED_LANGUAGES:
        raise TranslationError(f"Unsupported target language: {target_language!r}")

    # No-op: translating English -> English (client normally caches and skips this).
    if target_language == source_language:
        return text

    if not is_configured():
        raise TranslationConfigError(
            "GEMINI_API_KEY is not set in the backend environment."
        )

    source_name = SUPPORTED_LANGUAGES.get(source_language, "English")
    target_name = SUPPORTED_LANGUAGES[target_language]

    prompt = (
        f"{_INSTRUCTION}\n\n{_MARKER_NOTE}\n\n"
        f"Source language: {source_name}\n"
        f"Target language: {target_name}\n\n"
        f"Original content:\n{text}"
    )

    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0.2},
    }
    url = GEMINI_ENDPOINT.format(model=GEMINI_MODEL)

    try:
        resp = requests.post(
            url,
            params={"key": GEMINI_API_KEY},
            json=payload,
            timeout=GEMINI_TIMEOUT_SECONDS,
        )
    except requests.Timeout as exc:
        logger.error("Gemini request timed out: %s", exc)
        raise TranslationError("Translation timed out. Please try again.") from exc
    except requests.RequestException as exc:
        logger.error("Gemini request failed: %s", exc)
        raise TranslationError("Could not reach the translation service.") from exc

    if resp.status_code != 200:
        # Avoid leaking the key or full body; log status + short snippet.
        logger.error("Gemini HTTP %s: %s", resp.status_code, resp.text[:300])
        raise TranslationError(f"Translation provider error (HTTP {resp.status_code}).")

    try:
        data = resp.json()
        translated = data["candidates"][0]["content"]["parts"][0]["text"]
    except (KeyError, IndexError, ValueError) as exc:
        # Could be a safety block or an unexpected shape.
        logger.error("Unexpected Gemini response: %s", str(exc))
        raise TranslationError("Translation provider returned an unexpected response.") from exc

    translated = (translated or "").strip()
    if not translated:
        raise TranslationError("Translation provider returned empty content.")
    return translated
