"""
PDF text extraction for the Knowledge Base.

Extracts page-level text from every PDF in the knowledge base. PDFs (or pages)
that are scanned images yield little/no text and are skipped with a warning --
those would require OCR, which is intentionally out of scope here.
"""
import glob
import logging
import os
from dataclasses import dataclass
from typing import List

from pypdf import PdfReader

from rag import config

logger = logging.getLogger("rag.pdf_loader")


@dataclass
class PageText:
    source_file: str  # basename of the PDF, e.g. "Paddy-disease-1.pdf"
    page_number: int  # 1-indexed
    text: str


def list_pdf_files(kb_dir: str = config.KNOWLEDGE_BASE_DIR) -> List[str]:
    """Return absolute paths of all PDFs in the knowledge base directory."""
    return sorted(glob.glob(os.path.join(kb_dir, "*.pdf")))


def extract_pages(pdf_path: str) -> List[PageText]:
    """
    Extract text from a single PDF, one PageText per page that has usable text.
    Pages with fewer than MIN_PAGE_CHARS characters are skipped (likely scanned).
    """
    pages: List[PageText] = []
    source_file = os.path.basename(pdf_path)
    try:
        reader = PdfReader(pdf_path)
    except Exception as exc:  # corrupt / unreadable file
        logger.warning("Could not open PDF %s: %s", source_file, exc)
        return pages

    for idx, page in enumerate(reader.pages):
        try:
            raw = page.extract_text() or ""
        except Exception as exc:
            logger.warning("Text extraction failed on %s p.%d: %s", source_file, idx + 1, exc)
            continue
        text = _normalize_whitespace(raw)
        if len(text) < config.MIN_PAGE_CHARS:
            continue
        pages.append(PageText(source_file=source_file, page_number=idx + 1, text=text))

    if not pages:
        logger.warning(
            "No extractable text in %s (likely a scanned/image PDF -> needs OCR, skipped).",
            source_file,
        )
    return pages


def extract_all(kb_dir: str = config.KNOWLEDGE_BASE_DIR) -> List[PageText]:
    """Extract text from every PDF in the knowledge base directory."""
    all_pages: List[PageText] = []
    for pdf_path in list_pdf_files(kb_dir):
        page_texts = extract_pages(pdf_path)
        logger.info("Extracted %d text pages from %s", len(page_texts), os.path.basename(pdf_path))
        all_pages.extend(page_texts)
    return all_pages


def _normalize_whitespace(text: str) -> str:
    # Collapse runs of whitespace but preserve single newlines as spaces.
    return " ".join(text.split())
