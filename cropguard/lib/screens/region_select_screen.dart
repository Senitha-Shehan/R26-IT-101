import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/regional_models_config.dart';
import '../models/region_model_config.dart';
import '../services/user_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/region_localizer.dart';
import 'all_set_screen.dart';

class RegionSelectScreen extends StatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  State<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends State<RegionSelectScreen> {
  int _selectedIndex = 0;
  bool _isPreparing = false;
  double _prepProgress = 0.0;
  RegionModelConfig? _preparingRegion;

  @override
  void initState() {
    super.initState();
    _loadCurrentRegion();
  }

  Future<void> _loadCurrentRegion() async {
    final selected = await UserPreferences.getSelectedRegion();
    final idx = RegionalModelsConfig.allRegions.indexWhere(
      (r) => r.regionId == selected.regionId,
    );
    if (idx != -1 && mounted) {
      setState(() => _selectedIndex = idx);
    }
  }

  Future<void> _onConfirmRegion() async {
    final region = RegionalModelsConfig.allRegions[_selectedIndex];
    setState(() {
      _isPreparing = true;
      _preparingRegion = region;
      _prepProgress = 0.1;
    });

    // Simulate preparing / pre-loading FP16 model assets
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() {
        _prepProgress = i / 10.0;
      });
    }

    await UserPreferences.setSelectedRegion(region.regionId);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AllSetScreen(selectedRegion: region),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: _isPreparing
            ? _buildPreparationView(l)
            : _buildRegionSelectionView(l),
      ),
    );
  }

  Widget _buildRegionSelectionView(AppLocalizations? l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l?.selectYourRegion ?? 'Select Your Region',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l?.regionSubtitle ??
                    'CropGuard automatically selects tuned FP16 AI models based on your Sri Lankan agricultural zone.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 9 Regional Models List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: RegionalModelsConfig.allRegions.length,
            itemBuilder: (context, i) {
              final region = RegionalModelsConfig.allRegions[i];
              final isSelected = i == _selectedIndex;
              final localizedRegionName = RegionLocalizer.getDisplayName(
                context,
                region.regionId,
                fallback: region.displayName,
              );

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1B3A1B) : AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentGreen : AppTheme.surfaceBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accentGreen.withValues(alpha: 0.2)
                              : Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.terrain_rounded,
                          color: isSelected ? AppTheme.accentGreen : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedRegionName,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l?.fp16LocalModel ?? 'FP16 TFLite Local Model',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.accentGreen, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Confirm Action Button
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _onConfirmRegion,
            child: Text(l?.confirmRegion ?? 'Confirm Region'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationView(AppLocalizations? l) {
    final localizedRegionName = _preparingRegion != null
        ? RegionLocalizer.getDisplayName(
            context,
            _preparingRegion!.regionId,
            fallback: _preparingRegion!.displayName,
          )
        : (l?.aiModel ?? 'Regional');

    final percentInt = (_prepProgress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.memory_rounded, color: AppTheme.accentGreen, size: 64),
          const SizedBox(height: 24),
          Text(
            l?.preparingCropGuard ?? 'Preparing CropGuard',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$localizedRegionName ${l?.aiModel ?? 'AI Model'}',
            style: const TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _prepProgress,
              minHeight: 10,
              backgroundColor: AppTheme.surfaceDark,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l?.preparingModel(percentInt) ??
                'Preparing model for offline use... ($percentInt%)',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}