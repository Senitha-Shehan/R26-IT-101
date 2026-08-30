import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/region_localizer.dart';
import '../services/user_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategoryKey = 'All'; // Internal key: 'All', 'Pest Alerts', 'Weather'
  String _regionId = 'central_highlands';
  String _regionFallback = 'Central Highlands';

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  Future<void> _loadRegion() async {
    final region = await UserPreferences.getSelectedRegion();
    if (!mounted) return;
    setState(() {
      _regionId = region.regionId;
      _regionFallback = region.displayName;
    });
  }

  List<Map<String, dynamic>> _getAlerts(BuildContext context, AppLocalizations? l, String localizedRegion) {
    return [
      {
        'id': '1',
        'type': 'Pest Alerts',
        'title': l?.pestAdvisoryTitle ?? '⚠ Pest Advisory: Rice Hispa Outbreak',
        'desc': l?.pestAdvisoryDesc(localizedRegion) ??
            'High humidity levels in $localizedRegion increase risk of Rice Hispa feeding damage on young paddy plants.',
        'time': '2h',
        'severity': 'high',
        'icon': Icons.warning_amber_rounded,
        'color': AppTheme.statusWarning,
      },
      {
        'id': '2',
        'type': 'Weather',
        'title': '🌧 Weather Warning: Heavy Rainfall Expected',
        'desc': 'Monsoon showers anticipated over the next 48 hours. Ensure proper paddy field drainage to prevent Sheath Blight.',
        'time': '5h',
        'severity': 'medium',
        'icon': Icons.thunderstorm_rounded,
        'color': AppTheme.statusInfo,
      },
      {
        'id': '3',
        'type': 'Pest Alerts',
        'title': '🌾 Leaf Blast Fungal Spore Notice',
        'desc': 'Fungal spore activity reported in neighboring agricultural sectors. Monitor leaf tips for diamond-shaped lesions.',
        'time': '1d',
        'severity': 'medium',
        'icon': Icons.bug_report_rounded,
        'color': AppTheme.statusWarning,
      },
      {
        'id': '4',
        'type': 'System',
        'title': '✓ Regional Model Sync Complete',
        'desc': 'FP16 TFLite model active for $localizedRegion zone. 100% offline inference verified.',
        'time': '2d',
        'severity': 'low',
        'icon': Icons.check_circle_rounded,
        'color': AppTheme.accentGreen,
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredAlerts(List<Map<String, dynamic>> alerts) {
    if (_selectedCategoryKey == 'Pest Alerts') {
      return alerts.where((a) => a['type'] == 'Pest Alerts').toList();
    } else if (_selectedCategoryKey == 'Weather') {
      return alerts.where((a) => a['type'] == 'Weather').toList();
    }
    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localizedRegion = RegionLocalizer.getDisplayName(
      context,
      _regionId,
      fallback: _regionFallback,
    );

    final allAlerts = _getAlerts(context, l, localizedRegion);
    final filtered = _getFilteredAlerts(allAlerts);

    final categories = [
      ('All', l?.catAll ?? 'All'),
      ('Pest Alerts', l?.catPestAlerts ?? 'Pest Alerts'),
      ('Weather', l?.catWeather ?? 'Weather'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(l?.alertsTitle ?? 'Regional Alerts & Notices'),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Pills
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surfaceDark,
              child: Row(
                children: categories.map((cat) {
                  final key = cat.$1;
                  final label = cat.$2;
                  final isSelected = _selectedCategoryKey == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppTheme.accentGreen,
                      backgroundColor: AppTheme.darkBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedCategoryKey = key),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Alerts List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final alert = filtered[index];
                  final Color color = alert['color'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(alert['icon'], color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert['title'],
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    alert['time'],
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                alert['desc'],
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}