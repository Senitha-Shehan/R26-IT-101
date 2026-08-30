import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/regional_models_config.dart';
import '../../models/detection_result.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/disease_localizer.dart';
import '../../core/utils/region_localizer.dart';
import '../review/active_learning_review_screen.dart';
import '../treatment/treatment_details_screen.dart';

class ResultScreen extends StatefulWidget {
  final DetectionResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _userConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final confidencePercent = (widget.result.confidence * 100).toStringAsFixed(1);
    final isHighConfidence = !widget.result.isUncertain;

    // Localized display name (backend still uses original English class name)
    final localizedDiseaseName =
        DiseaseLocalizer.getDisplayName(context, widget.result.diseaseName);
    final localizedRegion = RegionLocalizer.getDisplayName(
      context,
      widget.result.regionId,
      fallback: widget.result.regionDisplayName,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(l?.detectionResult ?? 'Detection Result'),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leaf Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: Image.file(
                          File(widget.result.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.surfaceDark,
                            child: const Center(
                              child: Icon(Icons.eco_rounded, color: AppTheme.accentGreen, size: 54),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confidence Banner
                    if (isHighConfidence)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              l?.highConfidencePrediction ?? '✓ High Confidence Prediction',
                              style: const TextStyle(
                                color: AppTheme.accentGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.statusWarning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.statusWarning),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: AppTheme.statusWarning, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l?.uncertainPrediction ?? 'Uncertain Prediction (< 80%)',
                                    style: const TextStyle(
                                      color: AppTheme.statusWarning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusWarning.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l?.savedForExpertReview ?? '✓ Saved for Expert Review',
                                    style: const TextStyle(
                                        color: AppTheme.statusWarning,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l?.uncertainDesc ??
                                  'This prediction is uncertain and has been automatically saved for expert review.',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Disease Title & Confidence Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizedDiseaseName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: AppTheme.textSecondary, size: 14),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      l?.regionLabel(localizedRegion) ??
                                          'Region: $localizedRegion',
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isHighConfidence
                                ? AppTheme.accentGreen.withValues(alpha: 0.15)
                                : AppTheme.statusWarning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isHighConfidence
                                  ? AppTheme.accentGreen
                                  : AppTheme.statusWarning,
                            ),
                          ),
                          child: Text(
                            '$confidencePercent%',
                            style: TextStyle(
                              color: isHighConfidence
                                  ? AppTheme.accentGreen
                                  : AppTheme.statusWarning,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.surfaceBorder),
                    const SizedBox(height: 12),

                    // Probabilities Breakdown
                    Text(
                      l?.modelClassProbabilities ?? 'Model Class Probabilities (Local FP16)',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(widget.result.allProbabilities.length, (index) {
                      final englishLabel = index < RegionalModelsConfig.globalClassLabels.length
                          ? RegionalModelsConfig.globalClassLabels[index]
                          : 'Class $index';
                      final localizedLabel =
                          DiseaseLocalizer.getDisplayName(context, englishLabel);
                      final prob = widget.result.allProbabilities[index];
                      final probPercent = (prob * 100).toStringAsFixed(1);
                      final isTop = englishLabel == widget.result.diseaseName;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 160,
                              child: Text(
                                localizedLabel,
                                style: TextStyle(
                                  color: isTop ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontWeight:
                                      isTop ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: prob.clamp(0.0, 1.0),
                                backgroundColor: AppTheme.surfaceDark,
                                color: isTop
                                    ? (isHighConfidence
                                        ? AppTheme.accentGreen
                                        : AppTheme.statusWarning)
                                    : Colors.grey.shade700,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 45,
                              child: Text(
                                '$probPercent%',
                                style: TextStyle(
                                  color: isTop ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight:
                                      isTop ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Active Learning Feedback
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l?.helpImproveDiagnosis ?? 'Help Improve This Diagnosis',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l?.isDiagnosisAccurate ??
                                'Is this disease prediction accurate for your crop?',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => _userConfirmed = true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(l?.thankyouConfirmed ??
                                              '✓ Thank you! Diagnosis confirmed.')),
                                    );
                                  },
                                  icon: Icon(
                                    _userConfirmed
                                        ? Icons.check_circle
                                        : Icons.thumb_up_alt_outlined,
                                    color: AppTheme.accentGreen,
                                    size: 18,
                                  ),
                                  label: Text(_userConfirmed
                                      ? (l?.confirmed ?? 'Confirmed')
                                      : (l?.looksRight ?? 'Looks Right')),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ActiveLearningReviewScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_note_rounded,
                                      color: AppTheme.statusWarning, size: 18),
                                  label: Text(l?.reviewCorrect ?? 'Review / Correct'),
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
            ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TreatmentDetailsScreen(
                            diseaseName: widget.result.diseaseName,
                            confidence: widget.result.confidence,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(l?.viewTreatmentGuide ?? 'View Treatment Guide'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l?.scanAnotherCrop ?? 'Scan Another Crop'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
