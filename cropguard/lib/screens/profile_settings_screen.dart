import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/regional_models_config.dart';
import '../models/region_model_config.dart';
import '../services/user_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/region_localizer.dart';
import 'language_select_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  RegionModelConfig _selectedRegion = RegionalModelsConfig.defaultRegion;
  String _currentLocaleCode = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final region = await UserPreferences.getSelectedRegion();
    final localeCode = await UserPreferences.getLocaleCode();
    if (!mounted) return;
    setState(() {
      _selectedRegion = region;
      _currentLocaleCode = localeCode;
      _isLoading = false;
    });
  }

  Future<void> _updateRegion(RegionModelConfig region) async {
    await UserPreferences.setSelectedRegion(region.regionId);
    if (!mounted) return;
    setState(() {
      _selectedRegion = region;
    });
    final l = AppLocalizations.of(context);
    final localizedRegion = RegionLocalizer.getDisplayName(
      context,
      region.regionId,
      fallback: region.displayName,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l?.activeAIModelSet(localizedRegion) ?? 'Active AI Model set to $localizedRegion'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  String _getLanguageDisplayName(String code, AppLocalizations? l) {
    switch (code) {
      case 'si':
        return l?.langSinhala ?? 'සිංහල';
      case 'ta':
        return l?.langTamil ?? 'தமிழ்';
      default:
        return l?.langEnglish ?? 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localizedCurrentRegion = RegionLocalizer.getDisplayName(
      context,
      _selectedRegion.regionId,
      fallback: _selectedRegion.displayName,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(l?.profileSettings ?? 'Profile & Settings'),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User / App Profile Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primaryGreen,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l?.farmerProfile ?? 'Farmer Profile',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppTheme.accentGreen, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      localizedCurrentRegion,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Language Section
                  Text(
                    l?.sectionLanguage ?? 'LANGUAGE',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.language_rounded, color: AppTheme.accentGreen),
                      title: Text(
                        l?.language ?? 'Language',
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _getLanguageDisplayName(_currentLocaleCode, l),
                        style: const TextStyle(color: AppTheme.accentGreen, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageSelectScreen(),
                          ),
                        );
                        _loadPreferences();
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AI & Offline Models Section
                  Text(
                    l?.sectionAiEngine ?? 'AI & OFFLINE ENGINE',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l?.activeAgriculturalRegion ?? 'Active Agricultural Region',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l?.activeRegionDesc ??
                              'Loads regional FP16 TFLite model tuned for local disease factors.',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<RegionModelConfig>(
                            value: _selectedRegion,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF242B24),
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.accentGreen),
                            items: RegionalModelsConfig.allRegions.map((region) {
                              final localizedName = RegionLocalizer.getDisplayName(
                                context,
                                region.regionId,
                                fallback: region.displayName,
                              );
                              return DropdownMenuItem<RegionModelConfig>(
                                value: region,
                                child: Text(
                                  localizedName,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newRegion) {
                              if (newRegion != null) {
                                _updateRegion(newRegion);
                              }
                            },
                          ),
                        ),
                        const Divider(color: AppTheme.surfaceBorder, height: 24),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l?.nineRegionalModelsInstalled ?? '9 Regional FP16 Models Installed',
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                              ),
                            ),
                            Text(
                              l?.ready ?? 'Ready',
                              style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Information & About Section
                  Text(
                    l?.sectionInformation ?? 'INFORMATION',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline, color: AppTheme.accentGreen),
                          title: Text(
                            l?.aboutCropGuard ?? 'About CropGuard',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                          ),
                          subtitle: Text(
                            l?.versionInfo ?? 'AI Paddy Disease Detection v1.0.0',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                        const Divider(color: AppTheme.surfaceBorder, height: 1),
                        ListTile(
                          leading: const Icon(Icons.help_outline, color: AppTheme.accentGreen),
                          title: Text(
                            l?.fieldScanningGuide ?? 'Field Scanning Guide',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                          ),
                          subtitle: Text(
                            l?.fieldScanningGuideSub ?? 'Tips for best camera lighting and leaf positioning',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: AppTheme.surfaceDark,
                                title: Text(
                                  l?.fieldScanningTips ?? 'Field Scanning Tips',
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l?.tip1 ?? '• Position leaf directly inside the scan frame.',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l?.tip2 ?? '• Ensure adequate natural sunlight daylight.',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l?.tip3 ?? '• Avoid severe shadows or extremely blurry photos.',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l?.tip4 ?? '• Predictions under 80% confidence are automatically saved for expert review.',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      l?.gotIt ?? 'Got it',
                                      style: const TextStyle(color: AppTheme.accentGreen),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      l?.cropGuardFooter ?? 'CropGuard Sri Lanka • Offline-First Agricultural AI',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
