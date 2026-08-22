"""
Translation subsystem.

Translates already-generated More Details / treatment content into the app's
supported languages via the Gemini API. Kept separate from the RAG and detection
logic: translation happens strictly AFTER the RAG system produces the English
content. The Gemini API key lives only in the backend environment and is never
exposed to the Flutter client.
"""
