import '../../models/active_learning_sample.dart';

/// Abstract interface for future Active Learning sync providers (Phase 5).
/// Phase 4 uses this abstraction without adding any network or API dependencies.
abstract class ActiveLearningSyncService {
  /// Synchronizes pending offline active learning samples with remote backend API.
  /// Returns count of successfully uploaded samples.
  Future<int> syncPendingSamples(List<ActiveLearningSample> pendingSamples);

  /// Checks if backend server is reachable.
  Future<bool> checkConnection();
}

/// Offline-only placeholder implementation for Phase 4.
/// Zero network calls, zero API credentials.
class OfflineSyncServicePlaceholder implements ActiveLearningSyncService {
  const OfflineSyncServicePlaceholder();

  @override
  Future<int> syncPendingSamples(List<ActiveLearningSample> pendingSamples) async {
    // Offline mode: No remote synchronization performed in Phase 4.
    return 0;
  }

  @override
  Future<bool> checkConnection() async {
    return false;
  }
}
