"""
One-time (re-runnable) ingestion: PDFs -> text -> chunks -> embeddings -> index.

Usage (from the backend/ directory, with the venv active):
    python -m rag.ingest

Re-run this whenever the PDFs in knowledge_base/ change. It overwrites the
existing index under knowledge_base/index/.
"""
import logging
import sys

from rag import config, embeddings
from rag.chunker import chunk_pages
from rag.pdf_loader import extract_all
from rag.vector_store import save_index

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger("rag.ingest")


def main() -> int:
    logger.info("Knowledge base: %s", config.KNOWLEDGE_BASE_DIR)
    logger.info("Embedding model: %s", config.EMBEDDING_MODEL_NAME)

    pages = extract_all()
    if not pages:
        logger.error("No extractable text found in any PDF. Nothing to index.")
        return 1
    logger.info("Extracted %d text pages total.", len(pages))

    chunks = chunk_pages(pages)
    if not chunks:
        logger.error("Chunking produced 0 chunks. Aborting.")
        return 1
    logger.info("Produced %d chunks.", len(chunks))

    # Language distribution (helpful sanity check for the multilingual KB).
    by_lang: dict = {}
    for c in chunks:
        by_lang[c.language] = by_lang.get(c.language, 0) + 1
    logger.info("Chunk language distribution: %s", by_lang)

    logger.info("Embedding %d chunks (first run downloads the model)...", len(chunks))
    vectors = embeddings.embed_texts([c.text for c in chunks])
    logger.info("Embeddings shape: %s", vectors.shape)

    save_index(vectors, chunks)
    logger.info("Ingestion complete. Index written to %s", config.INDEX_DIR)
    return 0


if __name__ == "__main__":
    sys.exit(main())
