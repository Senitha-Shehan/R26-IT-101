import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../models/treatment_recommendation.dart';

/// Thrown when translation cannot be completed. The UI keeps showing the
/// original content and surfaces [message].
class TranslationException implements Exception {
  final String message;
  const TranslationException(this.message);
  @override
  String toString() => message;
}

/// Calls the backend translation endpoint (which calls Gemini server-side).
///
/// The More Details content is serialized into a single marker-delimited text,
/// translated in ONE request, then parsed back into a structured
/// [TreatmentRecommendation] so the sectioned UI is preserved. The English
/// response is always the source of truth and is never re-translated.
class TranslationService {
  final http.Client _client;
  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  // Section markers kept verbatim (the backend prompt tells Gemini to preserve them).
  static const _mDisease = '§DISEASE§';
  static const _mDescription = '§DESCRIPTION§';
  static const _mSymptoms = '§SYMPTOMS§';
  static const _mTreatment = '§TREATMENT§';
  static const _mRecommended = '§RECOMMENDED§';
  static const _mPrevention = '§PREVENTION§';
  static const _mWarnings = '§WARNINGS§';

  // ------------------------------------------------------------------ public
  /// Core text translation via the backend.
  Future<String> translateText({
    required String text,
    required String targetLanguage,
  }) async {
    final uri = Uri.parse(ApiConfig.translationEndpoint);
    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text, 'targetLanguage': targetLanguage}),
          )
          .timeout(const Duration(seconds: 60));
    } catch (e) {
      debugPrint('TranslationService network error: $e');
      throw const TranslationException('Translation failed. Please try again.');
    }

    if (response.statusCode != 200) {
      debugPrint('TranslationService HTTP ${response.statusCode}: ${response.body}');
      throw const TranslationException('Translation failed. Please try again.');
    }

    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['success'] == true) {
        return (json['translatedText'] ?? '').toString();
      }
      throw TranslationException(
        (json['message'] ?? 'Translation failed. Please try again.').toString(),
      );
    } on TranslationException {
      rethrow;
    } catch (e) {
      debugPrint('TranslationService parse error: $e');
      throw const TranslationException('Translation failed. Please try again.');
    }
  }

  /// Translate a full recommendation into [targetLanguage] ('en' returns [source]).
  Future<TreatmentRecommendation> translateRecommendation(
    TreatmentRecommendation source,
    String targetLanguage,
  ) async {
    if (targetLanguage == 'en') return source;
    final serialized = _serialize(source);
    final translated = await translateText(text: serialized, targetLanguage: targetLanguage);
    return _parse(translated, source, targetLanguage);
  }

  Future<TreatmentRecommendation> translateToEnglish(TreatmentRecommendation source) async =>
      source; // English is the source of truth.

  Future<TreatmentRecommendation> translateToSinhala(TreatmentRecommendation source) =>
      translateRecommendation(source, 'si');

  Future<TreatmentRecommendation> translateToTamil(TreatmentRecommendation source) =>
      translateRecommendation(source, 'ta');

  // ----------------------------------------------------------- serialization
  String _serialize(TreatmentRecommendation r) {
    final b = StringBuffer();
    b.writeln(_mDisease);
    b.writeln(r.diseaseName);
    if (r.description.trim().isNotEmpty) {
      b.writeln(_mDescription);
      b.writeln(r.description.trim());
    }
    void section(String marker, List<String> items) {
      if (items.isEmpty) return;
      b.writeln(marker);
      for (final it in items) {
        b.writeln('- ${it.trim()}');
      }
    }

    section(_mSymptoms, r.symptoms);
    section(_mTreatment, r.treatment);
    section(_mRecommended, r.recommendedActions);
    section(_mPrevention, r.prevention);
    section(_mWarnings, r.warnings);
    return b.toString().trim();
  }

  // ------------------------------------------------------------------ parsing
  TreatmentRecommendation _parse(
    String translated,
    TreatmentRecommendation source,
    String language,
  ) {
    final markers = <String>{
      _mDisease, _mDescription, _mSymptoms, _mTreatment,
      _mRecommended, _mPrevention, _mWarnings,
    };

    String disease = source.diseaseName;
    String description = '';
    final symptoms = <String>[];
    final treatment = <String>[];
    final recommended = <String>[];
    final prevention = <String>[];
    final warnings = <String>[];

    final diseaseBuf = <String>[];
    final descBuf = <String>[];
    String? current;
    bool sawAnyMarker = false;

    for (final rawLine in translated.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (markers.contains(line)) {
        current = line;
        sawAnyMarker = true;
        continue;
      }

      // List item? Accept '-', '*', '•' or "1." / "1)" numbered prefixes.
      final listMatch = RegExp(r'^([-*•]|\d+[.)])\s+(.*)$').firstMatch(line);
      final itemText = listMatch != null ? listMatch.group(2)!.trim() : line;

      switch (current) {
        case _mDisease:
          diseaseBuf.add(line);
          break;
        case _mDescription:
          descBuf.add(line);
          break;
        case _mSymptoms:
          if (itemText.isNotEmpty) symptoms.add(itemText);
          break;
        case _mTreatment:
          if (itemText.isNotEmpty) treatment.add(itemText);
          break;
        case _mRecommended:
          if (itemText.isNotEmpty) recommended.add(itemText);
          break;
        case _mPrevention:
          if (itemText.isNotEmpty) prevention.add(itemText);
          break;
        case _mWarnings:
          if (itemText.isNotEmpty) warnings.add(itemText);
          break;
        default:
          // Text before any marker -> treat as description fallback.
          descBuf.add(line);
      }
    }

    if (diseaseBuf.isNotEmpty) disease = diseaseBuf.join(' ').trim();
    if (descBuf.isNotEmpty) description = descBuf.join('\n').trim();

    // Robustness: if Gemini dropped all markers, show the whole translation as
    // the description rather than losing content.
    if (!sawAnyMarker) {
      return _rebuild(
        source, language,
        disease: source.diseaseName,
        description: translated.trim(),
        symptoms: const [],
        treatment: const [],
        recommended: const [],
        prevention: const [],
        warnings: const [],
      );
    }

    return _rebuild(
      source, language,
      disease: disease,
      description: description,
      symptoms: symptoms,
      treatment: treatment,
      recommended: recommended,
      prevention: prevention,
      warnings: warnings,
    );
  }

  TreatmentRecommendation _rebuild(
    TreatmentRecommendation source,
    String language, {
    required String disease,
    required String description,
    required List<String> symptoms,
    required List<String> treatment,
    required List<String> recommended,
    required List<String> prevention,
    required List<String> warnings,
  }) {
    // Preserve non-translatable fields from the English source.
    return TreatmentRecommendation(
      found: source.found,
      diseaseName: disease,
      confidence: source.confidence,
      language: language,
      message: source.message,
      description: description,
      symptoms: symptoms,
      treatment: treatment,
      recommendedActions: recommended,
      prevention: prevention,
      warnings: warnings,
      sources: source.sources,
    );
  }
}
