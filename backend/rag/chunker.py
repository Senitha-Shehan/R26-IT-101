"""
Split extracted page text into overlapping word-window chunks with metadata.

Each chunk carries enough metadata (source file, page, crop/disease hints,
language) to (a) filter/boost during retrieval and (b) cite as a source in the
final response.
"""
import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional

from rag import config
from rag.pdf_loader import PageText

# Lightweight hints inferred from the source filename. These are only used to
# gently boost retrieval relevance and to attach a human-readable source; they
# never inject treatment content themselves.
_CROP_HINTS = {
    "paddy": "rice",
    "rice": "rice",
    "brinjal": "brinjal",
    "vegetable": "vegetable",
    "field-crop": "field crop",
    "food-crop": "food crop",
}


@dataclass
class Chunk:
    id: int
    text: str
    source_file: str
    page_number: int
    crop_hint: Optional[str] = None
    language: str = "unknown"
    extra: Dict = field(default_factory=dict)


def _crop_hint_for(source_file: str) -> Optional[str]:
    name = source_file.lower()
    for key, crop in _CROP_HINTS.items():
        if key in name:
            return crop
    return None


def _is_low_value(text: str) -> bool:
    """
    Heuristic filter for boilerplate chunks (navigation link lists, contact/address
    blocks, tables of reference codes) that pollute retrieval. These carry generic
    crop terms but no actual disease guidance, so they otherwise rank highly for
    every query.
    """
    # Dense navigation/reference link lists, e.g. "Bg 358 (../rrdi_rice_bg358)".
    if text.count("(../") >= 3 or text.lower().count("http") >= 4:
        return True
    words = text.split()
    if not words:
        return True
    # Chunks that are mostly numbers / symbols (e.g. dosage tables ripped of context).
    alpha_words = sum(1 for w in words if any(ch.isalpha() for ch in w))
    if alpha_words / len(words) < 0.55:
        return True
    return False


def _detect_language(text: str) -> str:
    """
    Cheap script-based language detection (no extra dependency):
    Sinhala and Tamil have dedicated Unicode blocks; otherwise assume English.
    """
    if re.search(r"[඀-෿]", text):  # Sinhala block
        return "si"
    if re.search(r"[஀-௿]", text):  # Tamil block
        return "ta"
    return "en"


def chunk_pages(pages: List[PageText]) -> List[Chunk]:
    """Turn page texts into overlapping word-window chunks."""
    size = config.CHUNK_SIZE_WORDS
    overlap = config.CHUNK_OVERLAP_WORDS
    step = max(1, size - overlap)

    chunks: List[Chunk] = []
    next_id = 0
    for page in pages:
        words = page.text.split()
        if not words:
            continue
        crop_hint = _crop_hint_for(page.source_file)
        for start in range(0, len(words), step):
            window = words[start : start + size]
            if len(window) < 20 and chunks:
                # Skip tiny trailing fragments (they rarely add value).
                break
            text = " ".join(window)
            if _is_low_value(text):
                if start + size >= len(words):
                    break
                continue
            chunks.append(
                Chunk(
                    id=next_id,
                    text=text,
                    source_file=page.source_file,
                    page_number=page.page_number,
                    crop_hint=crop_hint,
                    language=_detect_language(text),
                )
            )
            next_id += 1
            if start + size >= len(words):
                break
    return chunks
