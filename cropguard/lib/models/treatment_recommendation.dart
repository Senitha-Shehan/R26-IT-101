/// Structured treatment recommendation returned by the backend RAG endpoint
/// (POST /api/disease/treatment). All content is grounded in the PDF Knowledge
/// Base; [found] is false when the KB has no relevant information.
class TreatmentSource {
  final String sourceFile;
  final int pageNumber;
  final double similarity;

  const TreatmentSource({
    required this.sourceFile,
    required this.pageNumber,
    required this.similarity,
  });

  factory TreatmentSource.fromJson(Map<String, dynamic> json) {
    return TreatmentSource(
      sourceFile: (json['source_file'] ?? '').toString(),
      pageNumber: (json['page_number'] ?? 0) as int,
      similarity: (json['similarity'] ?? 0).toDouble(),
    );
  }
}

class TreatmentRecommendation {
  final bool found;
  final String diseaseName;
  final double? confidence;
  final String language;
  final String message;
  final String description;
  final List<String> symptoms;
  final List<String> treatment;
  final List<String> recommendedActions;
  final List<String> prevention;
  final List<String> warnings;
  final List<TreatmentSource> sources;

  const TreatmentRecommendation({
    required this.found,
    required this.diseaseName,
    required this.confidence,
    required this.language,
    required this.message,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.recommendedActions,
    required this.prevention,
    required this.warnings,
    required this.sources,
  });

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  factory TreatmentRecommendation.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];
    return TreatmentRecommendation(
      found: json['found'] == true,
      diseaseName: (json['disease_name'] ?? '').toString(),
      confidence: json['confidence'] == null ? null : (json['confidence']).toDouble(),
      language: (json['language'] ?? 'en').toString(),
      message: (json['message'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      symptoms: _stringList(json['symptoms']),
      treatment: _stringList(json['treatment']),
      recommendedActions: _stringList(json['recommended_actions']),
      prevention: _stringList(json['prevention']),
      warnings: _stringList(json['warnings']),
      sources: rawSources is List
          ? rawSources
              .map((e) => TreatmentSource.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
