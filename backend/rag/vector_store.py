"""
Local file-based vector store.

The index is two files under knowledge_base/index/:
  - embeddings.npy : (n, dim) float32, L2-normalized
  - chunks.json    : list of chunk metadata (aligned by row index)

Retrieval is an in-memory cosine similarity (dot product of normalized vectors).
For a few thousand chunks this is effectively instant and needs no external
vector database or manual index configuration.
"""
import json
import logging
import os
from dataclasses import asdict
from datetime import datetime, timezone
from typing import List, Optional, Tuple

import numpy as np

from rag import config
from rag.chunker import Chunk

logger = logging.getLogger("rag.vector_store")


def _normalize_name(text: str) -> str:
    """Lowercase and strip non-alphanumerics, e.g. 'Brown Spot' -> 'brownspot'."""
    return "".join(ch for ch in text.lower() if ch.isalnum())


# --------------------------------------------------------------------------- #
# Build / persist
# --------------------------------------------------------------------------- #
def save_index(embeddings: np.ndarray, chunks: List[Chunk]) -> None:
    """Persist embeddings + chunk metadata to disk."""
    os.makedirs(config.INDEX_DIR, exist_ok=True)
    np.save(config.EMBEDDINGS_FILE, embeddings.astype(np.float32))
    with open(config.CHUNKS_FILE, "w", encoding="utf-8") as f:
        json.dump([asdict(c) for c in chunks], f, ensure_ascii=False)
    meta = {
        "embedding_model": config.EMBEDDING_MODEL_NAME,
        "embedding_dim": int(embeddings.shape[1]) if embeddings.size else config.EMBEDDING_DIM,
        "num_chunks": len(chunks),
        "built_at": datetime.now(timezone.utc).isoformat(),
    }
    with open(config.META_FILE, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    logger.info("Saved index: %d chunks -> %s", len(chunks), config.INDEX_DIR)


# --------------------------------------------------------------------------- #
# Load (cached) / query
# --------------------------------------------------------------------------- #
class VectorStore:
    """In-memory view over the persisted index."""

    def __init__(self, embeddings: np.ndarray, chunks: List[dict], meta: dict):
        self.embeddings = embeddings
        self.chunks = chunks
        self.meta = meta

    @property
    def is_empty(self) -> bool:
        return self.embeddings.size == 0 or not self.chunks

    def search(
        self,
        query_vec: np.ndarray,
        top_k: int = config.TOP_K,
        crop: Optional[str] = None,
        disease_key: Optional[str] = None,
    ) -> List[Tuple[dict, float]]:
        """
        Return up to top_k (chunk_dict, similarity) pairs, highest similarity first.

        Two lightweight re-ranking boosts are applied on top of cosine similarity:
          - crop match: chunks whose crop_hint matches `crop` (e.g. rice).
          - disease/source match: chunks whose source filename contains the
            disease name (the RRDI PDFs are named per disease -> a strong signal).
        The returned score is always the true cosine similarity, not the boosted one.
        """
        if self.is_empty:
            return []
        sims = self.embeddings @ query_vec  # normalized vectors -> cosine
        ranking = sims.copy()
        if crop:
            crop_l = crop.lower()
            ranking = ranking + np.array(
                [0.05 if (c.get("crop_hint") or "").lower() == crop_l else 0.0 for c in self.chunks],
                dtype=np.float32,
            )
        if disease_key:
            ranking = ranking + np.array(
                [0.15 if disease_key in _normalize_name(c.get("source_file", "")) else 0.0
                 for c in self.chunks],
                dtype=np.float32,
            )

        k = min(top_k, len(self.chunks))
        top_idx = np.argpartition(-ranking, k - 1)[:k]
        top_idx = top_idx[np.argsort(-ranking[top_idx])]
        # Report the true cosine similarity (not the boosted ranking score).
        return [(self.chunks[i], float(sims[i])) for i in top_idx]


_store: Optional[VectorStore] = None


def index_exists() -> bool:
    return os.path.exists(config.EMBEDDINGS_FILE) and os.path.exists(config.CHUNKS_FILE)


def load_store(force_reload: bool = False) -> Optional[VectorStore]:
    """Load (and cache) the vector store. Returns None if no index is built."""
    global _store
    if _store is not None and not force_reload:
        return _store
    if not index_exists():
        logger.warning("No RAG index found at %s. Run rag.ingest first.", config.INDEX_DIR)
        return None
    embeddings = np.load(config.EMBEDDINGS_FILE)
    with open(config.CHUNKS_FILE, "r", encoding="utf-8") as f:
        chunks = json.load(f)
    meta = {}
    if os.path.exists(config.META_FILE):
        with open(config.META_FILE, "r", encoding="utf-8") as f:
            meta = json.load(f)
    _store = VectorStore(embeddings=embeddings, chunks=chunks, meta=meta)
    logger.info("Loaded RAG index: %d chunks (model=%s)", len(chunks), meta.get("embedding_model"))
    return _store
