"""
Extractive (no-LLM) answer builder.

Selects and organizes sentences taken VERBATIM from the retrieved Knowledge Base
chunks -- nothing is rewritten or invented. Used as an automatic fallback when a
local LLM (Ollama) is not available, so the treatment feature works fully offline
with zero extra installation.

Output matches the exact dict shape produced by rag.generator.generate():
    found, description, symptoms, treatment, recommended_actions, prevention, warnings
"""
import logging
import re
from typing import Dict, List, Tuple

from rag import config

logger = logging.getLogger("rag.extractive")

# Sentences containing any of these are boilerplate (contacts, copyright, links).
_BOILERPLATE = (
    "department of agriculture", "copyright", "all rights reserved", "address",
    "telephone", "e-mail", "email", "http", "www.", "@", "doa.gov", "fax",
    "figure", "table ", "printed", "isbn",
)

# Keyword cues per section. A sentence is assigned to the FIRST section (in this
# order) whose cues it matches, so safety/treatment win over generic symptom words.
_SECTION_CUES: List[Tuple[str, Tuple[str, ...]]] = [
    ("warnings", (
        "caution", "toxic", "poison", "harmful", "hazard", "danger", "gloves",
        "protective", "re-entry", "safety", "do not", "avoid contact", "wear ",
        "keep away", "ppe", "waiting period", "pre-harvest",
    )),
    ("treatment", (
        "apply", "spray", "spraying", "fungicide", "bactericide", "pesticide",
        "insecticide", "dose", "dosage", "treat", "chemical", "copper",
        "mancozeb", "carbendazim", "propiconazole", "tricyclazole", "validamycin",
        "seed treatment", "per hectare", "kg/ha", "g/ha", "ml/", "foliar",
    )),
    ("recommended_actions", (
        "remove", "rogue", "roguing", "destroy", "burn", "uproot", "monitor",
        "inspect", "scout", "drain", "adjust water", "plough", "plow", "deep",
        "collect and", "clean the field", "cut and",
    )),
    ("prevention", (
        "prevent", "avoid", "resistant variety", "resistant varieties", "rotation",
        "rotate", "drainage", "spacing", "sanitation", "field hygiene",
        "certified seed", "healthy seed", "balanced fertil", "avoid excess",
        "nitrogen", "weed", "intercultural", "well-drained",
    )),
    ("symptoms", (
        "symptom", "lesion", "spot", "spots", "yellow", "yellowing", "wilt",
        "wilting", "blight", "rot", "discolor", "chloros", "necro", "stunt",
        "streak", "pustule", "halo", "margin", "sheath", "panicle", "grain",
        "brown", "reddish", "spindle", "oval", "elongated", "patches", "drying",
    )),
]

_SECTIONS = ["symptoms", "treatment", "recommended_actions", "prevention", "warnings"]


def _split_sentences(text: str) -> List[str]:
    # Split on sentence-ending punctuation followed by whitespace.
    parts = re.split(r"(?<=[.!?])\s+", text)
    return [p.strip() for p in parts if p.strip()]


def _is_usable(sentence: str) -> bool:
    low = sentence.lower()
    if any(bp in low for bp in _BOILERPLATE):
        return False
    words = sentence.split()
    if len(words) < 5 or len(words) > 60:
        return False
    # Mostly alphabetic (drop dosage-table rows like "- - - 14 14 14").
    alpha_words = sum(1 for w in words if any(ch.isalpha() for ch in w))
    if alpha_words / len(words) < 0.6:
        return False
    return True


def _classify(sentence: str) -> str:
    low = sentence.lower()
    for section, cues in _SECTION_CUES:
        if any(cue in low for cue in cues):
            return section
    return ""  # unclassified -> description candidate


def extract(disease_name: str, hits: List[Tuple[dict, float]], language: str) -> Dict:
    """
    Build the structured recommendation from retrieved chunks without an LLM.
    `hits` is a list of (chunk_dict, similarity) ordered best-first.
    """
    max_per = config.EXTRACTIVE_MAX_PER_SECTION
    buckets: Dict[str, List[str]] = {s: [] for s in _SECTIONS}
    description_candidates: List[str] = []
    seen = set()

    for chunk, _sim in hits:
        for sentence in _split_sentences(chunk.get("text", "")):
            if not _is_usable(sentence):
                continue
            key = sentence.lower()
            if key in seen:  # overlap windows produce duplicates
                continue
            seen.add(key)

            section = _classify(sentence)
            if section:
                if len(buckets[section]) < max_per:
                    buckets[section].append(sentence)
            else:
                description_candidates.append(sentence)

    # Description: prefer a sentence that names the disease; else the first
    # relevant unclassified sentence; else fall back to a symptom sentence.
    disease_words = [w for w in disease_name.lower().split() if len(w) > 3]
    description = ""
    for cand in description_candidates:
        low = cand.lower()
        if any(w in low for w in disease_words):
            description = cand
            break
    if not description and description_candidates:
        description = description_candidates[0]
    if not description and buckets["symptoms"]:
        description = buckets["symptoms"][0]

    result = {
        "found": False,
        "description": description,
        "symptoms": buckets["symptoms"],
        "treatment": buckets["treatment"],
        "recommended_actions": buckets["recommended_actions"],
        "prevention": buckets["prevention"],
        "warnings": buckets["warnings"],
    }
    # Considered "found" if we salvaged any usable content at all.
    result["found"] = bool(
        description
        or any(buckets[s] for s in _SECTIONS)
    )
    logger.info(
        "Extractive result for '%s': found=%s sizes=%s",
        disease_name, result["found"], {s: len(buckets[s]) for s in _SECTIONS},
    )
    return result
