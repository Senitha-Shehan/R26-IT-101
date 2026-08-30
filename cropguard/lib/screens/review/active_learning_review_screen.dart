import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/active_learning_sample.dart';
import '../../services/active_learning/active_learning_queue_service.dart';
import '../../core/constants/regional_models_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/disease_localizer.dart';
import '../../core/utils/region_localizer.dart';

class ActiveLearningReviewScreen extends StatefulWidget {
  const ActiveLearningReviewScreen({super.key});

  @override
  State<ActiveLearningReviewScreen> createState() =>
      _ActiveLearningReviewScreenState();
}

class _ActiveLearningReviewScreenState
    extends State<ActiveLearningReviewScreen> {
  final ActiveLearningQueueService _queueService = ActiveLearningQueueService();
  List<ActiveLearningSample> _samples = [];
  bool _isLoading = true;
  String _selectedFilterKey = 'All'; // internal key, not displayed

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    setState(() => _isLoading = true);
    final samples = await _queueService.getAllSamples();
    if (!mounted) return;
    setState(() {
      _samples = samples;
      _isLoading = false;
    });
  }

  Future<void> _syncSamples() async {
    setState(() => _isLoading = true);
    final synced = await _queueService.syncPendingSamples();
    await _loadSamples();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(synced > 0
            ? (l?.syncedSamples(synced) ?? 'Synced $synced sample(s)')
            : (l?.allSamplesUpToDate ?? 'All samples up to date')),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  // ignore: unused_element
  Future<void> _deleteSample(String id) async {
    await _queueService.deleteSample(id);
    await _loadSamples();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l?.sampleRemovedFromQueue ?? 'Sample removed from queue')),
    );
  }

  void _showCorrectionDialog(ActiveLearningSample sample) {
    String selectedDisease = sample.predictedDisease;
    final l = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l?.helpImproveDiagnosis ?? 'Help Improve Diagnosis',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(sample.localImagePath),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 160,
                        color: AppTheme.darkBg,
                        child: const Center(
                          child: Icon(Icons.eco_rounded,
                              color: AppTheme.accentGreen, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l?.aiPredicted(
                          sample.predictedDisease,
                          (sample.confidence * 100).toStringAsFixed(1),
                        ) ??
                        'AI Predicted: ${sample.predictedDisease} (${(sample.confidence * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(
                        color: AppTheme.statusWarning,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l?.selectCorrectDisease ?? 'Select Correct Disease Label:',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: RegionalModelsConfig.globalClassLabels.contains(selectedDisease)
                        ? selectedDisease
                        : RegionalModelsConfig.globalClassLabels.first,
                    dropdownColor: const Color(0xFF252D25),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppTheme.surfaceBorder),
                      ),
                    ),
                    // Dropdown shows localized names but stores original class name
                    items: RegionalModelsConfig.globalClassLabels.map((disease) {
                      return DropdownMenuItem<String>(
                        value: disease,
                        child: Text(
                          DiseaseLocalizer.getDisplayName(context, disease),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedDisease = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l?.correctedLabelSaved(
                                  DiseaseLocalizer.getDisplayName(
                                      context, selectedDisease)) ??
                              '✓ Corrected label saved as "$selectedDisease"'),
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      );
                    },
                    child: Text(l?.submitCorrection ?? 'Submit Correction'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<ActiveLearningSample> get _filteredSamples {
    if (_selectedFilterKey == 'Confirmed') {
      return _samples
          .where((s) => s.status == SampleSyncStatus.synced)
          .toList();
    } else if (_selectedFilterKey == 'Needs Review') {
      return _samples
          .where((s) => s.status == SampleSyncStatus.pending)
          .toList();
    }
    return _samples;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filtered = _filteredSamples;

    // Filter entries: key (internal) -> localized label
    final filters = [
      ('All', l?.filterAll ?? 'All'),
      ('Confirmed', l?.filterConfirmed ?? 'Confirmed'),
      ('Needs Review', l?.filterNeedsReview ?? 'Needs Review'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(l?.diagnosisHistory ?? 'Diagnosis History'),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppTheme.accentGreen),
            tooltip: l?.syncQueue ?? 'Sync Queue',
            onPressed: _syncSamples,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surfaceDark,
              child: Row(
                children: filters.map((entry) {
                  final key = entry.$1;
                  final label = entry.$2;
                  final isSelected = _selectedFilterKey == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppTheme.accentGreen,
                      backgroundColor: AppTheme.darkBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedFilterKey = key),
                    ),
                  );
                }).toList(),
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentGreen))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history_toggle_off_rounded,
                                  size: 64, color: AppTheme.textSecondary),
                              const SizedBox(height: 16),
                              Text(
                                l?.noDiagnosesFound ?? 'No diagnoses found',
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l?.noDiagnosesDesc ??
                                    'Scanned crops and uncertain predictions will appear here',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final sample = filtered[index];
                            final confPercent =
                                (sample.confidence * 100).toStringAsFixed(1);
                            final isUncertain = sample.confidence < 0.80;
                            final localizedDisease = DiseaseLocalizer
                                .getDisplayName(context, sample.predictedDisease);
                            final localizedRegion =
                                RegionLocalizer.getDisplayName(
                              context,
                              sample.regionId,
                              fallback: sample.regionDisplayName,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isUncertain
                                      ? AppTheme.statusWarning
                                          .withValues(alpha: 0.5)
                                      : AppTheme.surfaceBorder,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 54,
                                    height: 54,
                                    child: Image.file(
                                      File(sample.localImagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          Container(
                                        color: AppTheme.darkBg,
                                        child: const Icon(Icons.eco,
                                            color: AppTheme.accentGreen,
                                            size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  localizedDisease,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$localizedRegion • ${l?.confLabel(confPercent) ?? 'Conf: $confPercent%'}',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isUncertain
                                        ? AppTheme.statusWarning
                                            .withValues(alpha: 0.15)
                                        : AppTheme.accentGreen
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isUncertain
                                        ? (l?.needsReview ?? 'Needs Review')
                                        : (l?.confirmed ?? 'Confirmed'),
                                    style: TextStyle(
                                      color: isUncertain
                                          ? AppTheme.statusWarning
                                          : AppTheme.accentGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () => _showCorrectionDialog(sample),
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
