enum SampleSyncStatus {
  pending,
  synced,
  failed,
}

class ActiveLearningSample {
  final String id;
  final String localImagePath;
  final String predictedDisease;
  final double confidence;
  final String regionId;
  final String regionDisplayName;
  final String modelName;
  final DateTime timestamp;
  final SampleSyncStatus status;
  final String? syncErrorMessage;

  const ActiveLearningSample({
    required this.id,
    required this.localImagePath,
    required this.predictedDisease,
    required this.confidence,
    required this.regionId,
    required this.regionDisplayName,
    required this.modelName,
    required this.timestamp,
    this.status = SampleSyncStatus.pending,
    this.syncErrorMessage,
  });

  ActiveLearningSample copyWith({
    String? id,
    String? localImagePath,
    String? predictedDisease,
    double? confidence,
    String? regionId,
    String? regionDisplayName,
    String? modelName,
    DateTime? timestamp,
    SampleSyncStatus? status,
    String? syncErrorMessage,
  }) {
    return ActiveLearningSample(
      id: id ?? this.id,
      localImagePath: localImagePath ?? this.localImagePath,
      predictedDisease: predictedDisease ?? this.predictedDisease,
      confidence: confidence ?? this.confidence,
      regionId: regionId ?? this.regionId,
      regionDisplayName: regionDisplayName ?? this.regionDisplayName,
      modelName: modelName ?? this.modelName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localImagePath': localImagePath,
      'predictedDisease': predictedDisease,
      'confidence': confidence,
      'regionId': regionId,
      'regionDisplayName': regionDisplayName,
      'modelName': modelName,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'syncErrorMessage': syncErrorMessage,
    };
  }

  factory ActiveLearningSample.fromJson(Map<String, dynamic> json) {
    return ActiveLearningSample(
      id: json['id'] as String,
      localImagePath: json['localImagePath'] as String,
      predictedDisease: json['predictedDisease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      regionId: json['regionId'] as String,
      regionDisplayName: json['regionDisplayName'] as String? ?? json['regionId'] as String,
      modelName: json['modelName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: SampleSyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SampleSyncStatus.pending,
      ),
      syncErrorMessage: json['syncErrorMessage'] as String?,
    );
  }
}
