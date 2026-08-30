"""
Central configuration for the RAG subsystem.

All tunables are read from environment variables (with sensible defaults) so the
same code runs on a developer laptop and in a deployed environment without edits.
"""
import os

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
RAG_DIR = os.path.abspath(os.path.dirname(__file__))
BACKEND_ROOT = os.path.abspath(os.path.join(RAG_DIR, ".."))
KNOWLEDGE_BASE_DIR = os.path.join(BACKEND_ROOT, "knowledge_base")
# Built vector index lives next to the source PDFs.
INDEX_DIR = os.path.join(KNOWLEDGE_BASE_DIR, "index")
EMBEDDINGS_FILE = os.path.join(INDEX_DIR, "embeddings.npy")
CHUNKS_FILE = os.path.join(INDEX_DIR, "chunks.json")
META_FILE = os.path.join(INDEX_DIR, "index_meta.json")

# ---------------------------------------------------------------------------
# Embeddings (local, free, multilingual: English + Sinhala + Tamil)
# ---------------------------------------------------------------------------
EMBEDDING_MODEL_NAME = os.getenv(
    "RAG_EMBEDDING_MODEL", "paraphrase-multilingual-MiniLM-L12-v2"
)
# Dimensions of the model above; validated against the built index at load time.
EMBEDDING_DIM = int(os.getenv("RAG_EMBEDDING_DIM", "384"))

# ---------------------------------------------------------------------------
# Chunking
# ---------------------------------------------------------------------------
CHUNK_SIZE_WORDS = int(os.getenv("RAG_CHUNK_SIZE_WORDS", "220"))
CHUNK_OVERLAP_WORDS = int(os.getenv("RAG_CHUNK_OVERLAP_WORDS", "40"))
# Pages whose extracted text is shorter than this are treated as scanned/empty
# and skipped (they would need OCR, which is out of scope for this pipeline).
MIN_PAGE_CHARS = int(os.getenv("RAG_MIN_PAGE_CHARS", "40"))

# ---------------------------------------------------------------------------
# Retrieval
# ---------------------------------------------------------------------------
TOP_K = int(os.getenv("RAG_TOP_K", "5"))
# Cosine similarity below this for the best hit => treat as "not in knowledge base".
# Kept modest because the multilingual embedding model yields lower absolute cosine
# values than English-only models; the LLM's own "found" self-check is a second guard.
MIN_SIMILARITY = float(os.getenv("RAG_MIN_SIMILARITY", "0.25"))

# ---------------------------------------------------------------------------
# Generation
# ---------------------------------------------------------------------------
# How the final structured answer is produced:
#   "auto"       -> try Ollama; if it is not running, fall back to extractive.
#   "ollama"     -> require Ollama (503 to the client if unavailable).
#   "extractive" -> never call an LLM; select sentences straight from the KB.
GENERATION_MODE = os.getenv("RAG_GENERATION_MODE", "auto").lower()

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.1")
OLLAMA_TIMEOUT_SECONDS = int(os.getenv("OLLAMA_TIMEOUT_SECONDS", "120"))

# Extractive mode: max sentences kept per section.
EXTRACTIVE_MAX_PER_SECTION = int(os.getenv("RAG_EXTRACTIVE_MAX_PER_SECTION", "6"))

# ---------------------------------------------------------------------------
# Languages
# ---------------------------------------------------------------------------
# Map short app language codes -> human names used in the generation prompt.
SUPPORTED_LANGUAGES = {
    "en": "English",
    "si": "Sinhala",
    "ta": "Tamil",
}
DEFAULT_LANGUAGE = os.getenv("RAG_DEFAULT_LANGUAGE", "en")
