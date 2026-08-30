# CropGuard RAG — Treatment Recommendation Subsystem

Retrieval-Augmented Generation that turns an identified disease name into
**treatment & management recommendations grounded ONLY in the multilingual PDF
Knowledge Base** (`backend/knowledge_base/*.pdf`). It never hardcodes or
hallucinates treatments — if the Knowledge Base has nothing relevant, the API
returns a clear "not available" response.

The subsystem is deliberately decoupled from the disease-detection logic: the
API passes a disease name (+ optional crop / confidence / language) and receives
structured, source-cited JSON.

```
disease name ──▶ embed query ──▶ vector search (local) ──▶ top chunks ──▶ Ollama (local) ──▶ structured JSON
```

## Components (`backend/rag/`)
| File | Responsibility |
|------|----------------|
| `config.py` | All tunables (model names, chunking, thresholds, Ollama URL) via env vars |
| `pdf_loader.py` | Extract text per page; skip scanned/image pages |
| `chunker.py` | Word-window chunks + metadata; drops boilerplate/nav chunks |
| `embeddings.py` | Local multilingual embeddings (sentence-transformers) |
| `vector_store.py` | Local numpy cosine index: build / save / load / search + boosts |
| `generator.py` | Grounded generation via local Ollama (strict JSON, `found` flag) |
| `service.py` | Orchestration entry point used by the API |
| `ingest.py` | One-time (re-runnable) CLI to build the index |

The built index lives in `backend/knowledge_base/index/` (git-ignored, regenerable).

## One-time setup

**1. Install Python dependencies** (already in `requirements.txt`):
```bash
cd backend
source .venv/bin/activate        # Windows: .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt  # pulls sentence-transformers + torch (large first download)
```

**2. Install Ollama and pull the model** (local, free generation):
```bash
# Install from https://ollama.com , then:
ollama pull llama3.1
# Ollama serves on http://localhost:11434 by default.
```

**3. Build the Knowledge Base index** (run whenever the PDFs change):
```bash
cd backend
python -m rag.ingest
```
This extracts text from every readable PDF, chunks + embeds it, and writes the
index. 2 of the 15 PDFs are scanned images and are skipped (they'd need OCR).

## Running
Start the API as usual (`python api/main.py`). The treatment endpoints:

- `POST /api/disease/treatment` — body: `{ "disease_name", "crop?", "confidence?", "language?" }`
- `GET  /api/disease/{disease_name}/treatment?language=en` — convenience variant

Both return the same `TreatmentResponse` JSON (see `api/schemas/treatment.py`):
`found`, `disease_name`, `confidence`, `language`, `message`, `description`,
`symptoms[]`, `treatment[]`, `recommended_actions[]`, `prevention[]`,
`warnings[]`, `sources[]`.

## Generation modes (Ollama optional)

The final answer is produced according to `RAG_GENERATION_MODE`:

- **`auto`** (default) — try Ollama; if it is not running, automatically fall back
  to **extractive** mode. The feature therefore works with **no LLM installed**.
- **`ollama`** — require Ollama; return 503 if unavailable.
- **`extractive`** — never call an LLM.

**Extractive mode** selects sentences taken *verbatim* from the retrieved KB
chunks and buckets them into sections using keyword cues (see `extractive.py`).
It is fully offline and 100% grounded (it cannot hallucinate — it only copies KB
text), but reads like book excerpts and cannot translate. Installing Ollama later
upgrades the same endpoint to polished, translated prose with zero code changes.
The response field `generation_mode` (`ollama` \| `extractive` \| `none`) reports
which path produced each answer.

## Configuration (env vars, all optional)
| Var | Default | Notes |
|-----|---------|-------|
| `RAG_GENERATION_MODE` | `auto` | `auto` \| `ollama` \| `extractive` |
| `RAG_EMBEDDING_MODEL` | `paraphrase-multilingual-MiniLM-L12-v2` | 384-dim, EN/SI/TA |
| `RAG_TOP_K` | `5` | chunks passed to the generator |
| `RAG_MIN_SIMILARITY` | `0.25` | coarse "not in KB" gate |
| `RAG_EXTRACTIVE_MAX_PER_SECTION` | `6` | max sentences/section in extractive mode |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | local Ollama server |
| `OLLAMA_MODEL` | `llama3.1` | any pulled Ollama model |
| `RAG_DEFAULT_LANGUAGE` | `en` | `en` \| `si` \| `ta` |

## Notes / future work
- **Out-of-KB diseases & the rice-specialized KB:** the detection model only ever
  emits its 8 fixed rice classes, and all 8 are covered by the Knowledge Base, so
  the not-found path is effectively for a missing/empty index. Note that because
  the KB is rice-specialized, an *arbitrary* non-rice disease name sent directly to
  the API (e.g. "Potato Late Blight") can still score as highly as real rice
  classes and retrieve rice-adjacent content — similarity alone cannot separate
  them without also rejecting real classes like "Sheath Blight"/"Rice Hispa". When
  Ollama is enabled, its `found=false` self-check filters these; extractive mode has
  no such semantic guard. If the model's class set later expands beyond rice, add a
  per-class source/crop filter at retrieval time.
- **Languages:** the index holds English, Sinhala and Tamil content; the LLM is
  asked to answer in the requested language. The Flutter app currently sends
  `en`; wire its language selector to the `language` field when localization lands.
- **Scanned PDFs:** `Additional-food-crop.compressed.pdf`,
  `fieldhyginebrinjal-English-1.pdf` and `Paddy-pest.pdf` yield no extractable
  text. Add an OCR pass (e.g. `pytesseract`) to include them.
- **Vector store:** in-memory numpy cosine over ~1k chunks (instant, no external
  DB). Swap `vector_store.py` for MongoDB Atlas Vector Search if the KB grows large.
