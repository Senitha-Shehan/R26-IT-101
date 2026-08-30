"""
Local, free, multilingual sentence embeddings via sentence-transformers.

The model is loaded lazily and cached process-wide so the (large) model load
cost is paid once. Embeddings are L2-normalized so that a dot product equals
cosine similarity.
"""
import logging
from typing import List

import numpy as np

from rag import config

logger = logging.getLogger("rag.embeddings")

import os

_model = None


def _get_model():
    global _model
    if _model is None:
        # Enforce PyTorch backend for sentence-transformers to avoid TF/Keras 3 conflicts
        os.environ["USE_TF"] = "0"
        os.environ["USE_TORCH"] = "1"
        from sentence_transformers import SentenceTransformer

        logger.info("Loading embedding model '%s' ...", config.EMBEDDING_MODEL_NAME)
        _model = SentenceTransformer(config.EMBEDDING_MODEL_NAME)
        logger.info("Embedding model loaded.")
    return _model


def embed_texts(texts: List[str], batch_size: int = 32) -> np.ndarray:
    """Embed a list of texts -> (n, dim) float32 array, L2-normalized."""
    if not texts:
        return np.zeros((0, config.EMBEDDING_DIM), dtype=np.float32)
    model = _get_model()
    vectors = model.encode(
        texts,
        batch_size=batch_size,
        convert_to_numpy=True,
        normalize_embeddings=True,
        show_progress_bar=len(texts) > 64,
    )
    return vectors.astype(np.float32)


def embed_query(text: str) -> np.ndarray:
    """Embed a single query string -> (dim,) float32 vector, L2-normalized."""
    return embed_texts([text])[0]
