"""
RAG orchestration: disease name -> retrieve KB context -> grounded generation.

This is the single entry point the API layer calls. It is deliberately free of
FastAPI/HTTP concerns so it stays testable and reusable.
"""
import logging
from collections import OrderedDict
from copy import deepcopy
from typing import Dict, List, Optional

from rag import config, embeddings, extractive, generator
from rag.vector_store import load_store

logger = logging.getLogger("rag.service")

NOT_FOUND_MESSAGE = "Treatment information is not available in the current knowledge base."

# The current detection model is rice/paddy focused; used only as a retrieval hint.
_RICE_CLASSES = {
    "bacterial leaf blight",
    "brown spot",
    "leaf blast",
    "leaf scald",
    "narrow brown leaf spot",
    "rice hispa",
    "sheath blight",
    "healthy rice leaf",
}
_TREATMENT_CACHE: OrderedDict[tuple, Dict] = OrderedDict()
_TREATMENT_CACHE_MAX_SIZE = 64


def _infer_crop(disease_name: str, crop: Optional[str]) -> Optional[str]:
    if crop:
        return crop
    if disease_name.strip().lower() in _RICE_CLASSES:
        return "rice"
    return None


def _build_query(disease_name: str, crop: Optional[str]) -> str:
    parts = [disease_name]
    if crop:
        parts.append(crop)
    # Anchor the query on the sections we want to surface.
    parts.append("symptoms treatment control management prevention precautions")
    return " ".join(parts)


def _empty_response(disease_name: str, confidence: Optional[float], language: str) -> Dict:
    return {
        "found": False,
        "disease_name": disease_name,
        "confidence": confidence,
        "language": language,
        "message": NOT_FOUND_MESSAGE,
        "description": "",
        "symptoms": [],
        "treatment": [],
        "recommended_actions": [],
        "prevention": [],
        "warnings": [],
        "sources": [],
        "generation_mode": "none",
    }


def get_treatment(
    disease_name: str,
    crop: Optional[str] = None,
    confidence: Optional[float] = None,
    language: str = config.DEFAULT_LANGUAGE,
) -> Dict:
    """
    Retrieve + generate a grounded treatment recommendation.

    Returns a dict matching the API response schema. Raises
    generator.OllamaUnavailableError if the local LLM cannot be reached.
    """
    disease_name = (disease_name or "").strip()
    language = language if language in config.SUPPORTED_LANGUAGES else config.DEFAULT_LANGUAGE
    language_name = config.SUPPORTED_LANGUAGES[language]
    cache_key = (disease_name.lower(), crop.lower() if crop else None, confidence, language)
    cached = _TREATMENT_CACHE.get(cache_key)
    if cached is not None:
        _TREATMENT_CACHE.move_to_end(cache_key)
        logger.debug("Treatment cache hit for '%s'.", disease_name)
        return deepcopy(cached)

    store = load_store()
    if store is None or store.is_empty:
        logger.warning("RAG index unavailable/empty; returning not-found response.")
        response = _empty_response(disease_name, confidence, language)
        _cache_treatment(cache_key, response)
        return response

    crop = _infer_crop(disease_name, crop)
    query = _build_query(disease_name, crop)
    query_vec = embeddings.embed_query(query)
    # 'brown spot' -> 'brownspot' to match source filenames like RRDI_..._BrownSpot.pdf
    disease_key = "".join(ch for ch in disease_name.lower() if ch.isalnum())
    hits = store.search(
        query_vec, top_k=config.TOP_K, crop=crop, disease_key=disease_key or None
    )

    # Nothing sufficiently relevant in the KB -> do not fabricate.
    if not hits or hits[0][1] < config.MIN_SIMILARITY:
        best = hits[0][1] if hits else 0.0
        logger.info("Best similarity %.3f < %.3f for '%s'; treating as not found.",
                    best, config.MIN_SIMILARITY, disease_name)
        response = _empty_response(disease_name, confidence, language)
        _cache_treatment(cache_key, response)
        return response

    context_blocks: List[str] = []
    sources: List[Dict] = []
    seen = set()
    for chunk, sim in hits:
        context_blocks.append(chunk["text"])
        key = (chunk["source_file"], chunk["page_number"])
        if key not in seen:
            seen.add(key)
            sources.append(
                {
                    "source_file": chunk["source_file"],
                    "page_number": chunk["page_number"],
                    "similarity": round(sim, 3),
                }
            )

    generated, used_mode = _produce(disease_name, context_blocks, hits, language_name)

    if not generated.get("found", True):
        # Neither the LLM nor the extractor found usable info in the context.
        return _empty_response(disease_name, confidence, language)

    response = {
        "found": True,
        "disease_name": disease_name,
        "confidence": confidence,
        "language": language,
        "message": "",
        "description": generated.get("description", ""),
        "symptoms": generated.get("symptoms", []),
        "treatment": generated.get("treatment", []),
        "recommended_actions": generated.get("recommended_actions", []),
        "prevention": generated.get("prevention", []),
        "warnings": generated.get("warnings", []),
        "sources": sources,
        "generation_mode": used_mode,
    }
    _cache_treatment(cache_key, response)
    return response


def _cache_treatment(key: tuple, response: Dict) -> None:
    _TREATMENT_CACHE[key] = deepcopy(response)
    _TREATMENT_CACHE.move_to_end(key)
    while len(_TREATMENT_CACHE) > _TREATMENT_CACHE_MAX_SIZE:
        _TREATMENT_CACHE.popitem(last=False)


def _produce(disease_name, context_blocks, hits, language_name):
    """
    Produce the structured answer according to config.GENERATION_MODE.

    Returns (result_dict, used_mode). In "auto" mode an Ollama failure silently
    falls back to extractive; in "ollama" mode the failure propagates (503).
    """
    mode = config.GENERATION_MODE

    if mode in ("ollama", "auto"):
        if mode == "auto" and not generator.is_available():
            logger.info("Ollama unavailable; using extractive mode immediately.")
            return extractive.extract(disease_name, hits, language_name), "extractive"
        try:
            result = generator.generate(disease_name, context_blocks, language_name)
            return result, "ollama"
        except generator.OllamaUnavailableError:
            if mode == "ollama":
                raise
            logger.warning("Ollama unavailable; falling back to extractive mode.")

    # Extractive path ("extractive" mode, or "auto" after an Ollama failure).
    return extractive.extract(disease_name, hits, language_name), "extractive"
