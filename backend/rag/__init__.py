"""
CropGuard RAG (Retrieval-Augmented Generation) package.

Provides treatment & management recommendations grounded ONLY in the
multilingual PDF Knowledge Base under backend/knowledge_base/.

This package is intentionally decoupled from the disease-detection logic:
the API layer passes an identified disease name (+ optional crop / language)
and receives a structured, source-cited recommendation built exclusively from
retrieved Knowledge Base content.
"""
