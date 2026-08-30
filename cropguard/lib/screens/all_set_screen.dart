import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/region_model_config.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/region_localizer.dart';
import 'main_navigation_shell.dart';

class AllSetScreen extends StatelessWidget {
  final RegionModelConfig selectedRegion;

  const AllSetScreen({
    super.key,
    required this.selectedRegion,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localizedRegionName = RegionLocalizer.getDisplayName(
      context,
      selectedRegion.regionId,
      fallback: selectedRegion.displayName,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 54),
              ),

              const SizedBox(height: 32),

              Text(
                l?.readyForOfflineDetection ?? '✓ Ready for Offline Detection',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                l?.allSetDesc(localizedRegionName) ??
                    'FP16 local model loaded for $localizedRegionName. CropGuard is completely configured for offline field use.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              _buildCheckTile(l?.regionalModelInstalled ?? 'Regional FP16 Model Installed'),
              _buildCheckTile(l?.regionActive(localizedRegionName) ?? '$localizedRegionName Active'),
              _buildCheckTile(l?.offlineEngineReady ?? 'Offline Inference Engine Ready'),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationShell(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(l?.startUsingCropGuard ?? 'Start Using CropGuard'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckTile(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}