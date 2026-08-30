"""
Grounded generation via a local Ollama model.

The model is instructed to produce a STRICT JSON object using ONLY the retrieved
Knowledge Base context. Any section not supported by the context must be returned
empty -- the model must not invent treatments. Output is requested in the user's
selected language where possible.
"""
import json
import logging
from typing import Dict, List, Optional

import requests

from rag import config

logger = logging.getLogger("rag.generator")


class OllamaUnavailableError(RuntimeError):
    """Raised when the local Ollama service cannot be reached or fails."""


# Keys the model must return. Lists hold plain strings; description is a string.
_LIST_FIELDS = ["symptoms", "treatment", "recommended_actions", "prevention", "warnings"]

_SYSTEM_PROMPT = """You are an agricultural extension assistant for Sri Lankan farmers.
You will be given CONTEXT extracted from official agricultural PDFs and a DISEASE name.
Your job is to write treatment and management guidance for that disease.

STRICT RULES:
- Use ONLY facts present in the CONTEXT. Never invent chemicals, dosages, or actions.
- If the CONTEXT does not cover a section, return an empty list (or empty string) for it. Do not guess.
- If the CONTEXT contains almost nothing about the disease, set "found" to false.
- Prefer concrete, actionable steps. Keep each list item a single short instruction.
- Write ALL text values in the requested OUTPUT LANGUAGE.
- Respond with a SINGLE JSON object and nothing else.

JSON shape:
{
  "found": true/false,
  "description": "one short paragraph: what the disease is",
  "symptoms": ["..."],
  "treatment": ["step 1", "step 2"],
  "recommended_actions": ["..."],
  "prevention": ["..."],
  "warnings": ["safety/precaution ..."]
}"""


def is_available() -> bool:
    """Best-effort check that the Ollama service is reachable."""
    try:
        resp = requests.get(f"{config.OLLAMA_BASE_URL}/api/tags", timeout=3)
        return resp.status_code == 200
    except requests.RequestException:
        return False


def generate(disease_name: str, context_blocks: List[str], language_name: str) -> Dict:
    """
    Call Ollama to produce the grounded structured recommendation.

    Raises OllamaUnavailableError on connectivity/timeout errors so the caller can
    return a clean 503 to the client.
    """
    context = "\n\n---\n\n".join(context_blocks)
    user_prompt = (
        f"OUTPUT LANGUAGE: {language_name}\n"
        f"DISEASE: {disease_name}\n\n"
        f"CONTEXT:\n{context}\n\n"
        "Produce the JSON object now."
    )

    payload = {
        "model": config.OLLAMA_MODEL,
        "messages": [
            {"role": "system", "content": _SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt},
        ],
        "stream": False,
        "format": "json",
        "options": {"temperature": 0.1},
    }

    try:
        resp = requests.post(
            f"{config.OLLAMA_BASE_URL}/api/chat",
            json=payload,
            timeout=config.OLLAMA_TIMEOUT_SECONDS,
        )
        resp.raise_for_status()
    except requests.RequestException as exc:
        logger.error("Ollama request failed: %s", exc)
        raise OllamaUnavailableError(str(exc)) from exc

    try:
        content = resp.json()["message"]["content"]
        parsed = json.loads(content)
    except (KeyError, ValueError) as exc:
        logger.error("Could not parse Ollama JSON output: %s", exc)
        raise OllamaUnavailableError(f"Malformed model output: {exc}") from exc

    return _normalize(parsed)


def _normalize(parsed: Dict) -> Dict:
    """Coerce the model output into the exact expected shape."""
    out: Dict[str, object] = {}
    out["found"] = bool(parsed.get("found", True))
    desc = parsed.get("description", "")
    out["description"] = desc.strip() if isinstance(desc, str) else ""
    for field in _LIST_FIELDS:
        value = parsed.get(field, [])
        out[field] = _as_str_list(value)
    return out


def _as_str_list(value) -> List[str]:
    if value is None:
        return []
    if isinstance(value, str):
        v = value.strip()
        return [v] if v else []
    if isinstance(value, list):
        result = []
        for item in value:
            if isinstance(item, str) and item.strip():
                result.append(item.strip())
            elif isinstance(item, dict):
                # Occasionally a model returns {"step": "..."}; flatten values.
                for sub in item.values():
                    if isinstance(sub, str) and sub.strip():
                        result.append(sub.strip())
        return result
    return []
