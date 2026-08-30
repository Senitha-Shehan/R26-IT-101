import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/regional_models_config.dart';
import '../models/region_model_config.dart';
import '../services/active_learning/active_learning_queue_service.dart';
import '../services/user_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/region_localizer.dart';
import 'profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RegionModelConfig _currentRegion = RegionalModelsConfig.defaultRegion;
  int _pendingCount = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final region = await UserPreferences.getSelectedRegion();
    final samples = await ActiveLearningQueueService().getAllSamples();
    final pending = samples.where((s) => s.status.name == 'pending').length;

    if (!mounted) return;
    setState(() {
      _currentRegion = region;
      _pendingCount = pending;
    });
    _triggerAutoSync();
  }

  Future<void> _triggerAutoSync() async {
    if (_pendingCount > 0) {
      setState(() => _isSyncing = true);
      final synced = await ActiveLearningQueueService().syncPendingSamples();
      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        if (synced > 0) {
          _pendingCount = (_pendingCount - synced).clamp(0, 999);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final regionName = RegionLocalizer.getDisplayName(
      context,
      _currentRegion.regionId,
      fallback: _currentRegion.displayName,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CropGuard',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.accentGreen, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            regionName,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
                        onPressed: () => widget.onNavigateToTab?.call(3),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.surfaceDark,
                          child: Icon(Icons.person_outline, color: AppTheme.accentGreen, size: 20),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                          ).then((_) => _loadState());
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hero CTA Card: Scan Your Crop
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F4220), Color(0xFF142915)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l?.scanYourCrop ?? 'Scan Your Crop',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l?.scanDesc ?? 'Detect possible diseases from a paddy leaf photo using offline AI.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD0E0D0),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => widget.onNavigateToTab?.call(1),
                      icon: const Icon(Icons.center_focus_strong_rounded),
                      label: Text(
                        l?.startScan ?? 'Start Scan',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Offline / Sync Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSyncing
                          ? Icons.sync_rounded
                          : (_pendingCount > 0 ? Icons.cloud_queue_rounded : Icons.check_circle_outline_rounded),
                      color: _pendingCount > 0 ? AppTheme.statusWarning : AppTheme.accentGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isSyncing
                            ? (l?.syncingOfflineSamples ?? 'Syncing offline samples...')
                            : (_pendingCount > 0
                                ? '${l?.offlineAIReady ?? '● Offline AI Ready'} • ${l?.samplesQueuedForSync(_pendingCount) ?? '$_pendingCount sample(s) queued for sync'}'
                                : (l?.allSamplesSynced ?? '✓ Offline AI Ready • All samples synced')),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Diagnoses Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l?.recentDiagnoses ?? 'Recent Diagnoses',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateToTab?.call(2),
                    child: Text(
                      l?.viewAll ?? 'View All',
                      style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () => widget.onNavigateToTab?.call(2),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.nature_rounded, color: AppTheme.accentGreen, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Leaf Blast',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l?.confidence ?? 'Confidence'}: 92.4% • $regionName',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Regional Alerts Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l?.regionalAlerts ?? 'Regional Alerts',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateToTab?.call(3),
                    child: Text(
                      l?.alertsHub ?? 'Alerts Hub',
                      style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.statusWarning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: AppTheme.statusWarning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l?.pestAdvisoryTitle ?? 'Pest Advisory: Rice Hispa Alert',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l?.pestAdvisoryDesc(regionName) ??
                                'High humidity reported in $regionName. Check young paddy leaves.',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
