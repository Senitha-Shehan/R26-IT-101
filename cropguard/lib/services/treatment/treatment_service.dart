import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../models/treatment_recommendation.dart';

/// Thrown when the treatment service is unreachable or returns an error.
class TreatmentServiceException implements Exception {
  final String message;
  final bool isNetwork;
  const TreatmentServiceException(this.message, {this.isNetwork = false});

  @override
  String toString() => message;
}

/// Client for the backend RAG treatment endpoint.
/// Kept separate from detection logic so both remain maintainable.
class TreatmentService {
  final http.Client _client;
  TreatmentService({http.Client? client}) : _client = client ?? http.Client();

  Future<TreatmentRecommendation> fetchTreatment({
    required String diseaseName,
    double? confidence,
    String? crop,
    String language = 'en',
  }) async {
    final uri = Uri.parse(ApiConfig.treatmentEndpoint);
    final body = jsonEncode({
      'disease_name': diseaseName,
      'crop': ?crop,
      'confidence': ?confidence,
      'language': language,
    });

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 130));
    } catch (e) {
      debugPrint('TreatmentService network error: $e');
      throw const TreatmentServiceException(
        'Could not reach the treatment service. Check your network connection and try again.',
        isNetwork: true,
      );
    }

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return TreatmentRecommendation.fromJson(json);
      } catch (e) {
        debugPrint('TreatmentService parse error: $e');
        throw const TreatmentServiceException(
          'Received an unexpected response from the treatment service.',
        );
      }
    }

    if (response.statusCode == 503) {
      throw const TreatmentServiceException(
        'The treatment service is temporarily unavailable. Please try again in a moment.',
      );
    }

    debugPrint('TreatmentService HTTP ${response.statusCode}: ${response.body}');
    throw TreatmentServiceException(
      'Treatment request failed (HTTP ${response.statusCode}).',
    );
  }
}
