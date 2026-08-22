import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/detection_result.dart';
import '../review/active_learning_review_screen.dart';
import '../treatment/treatment_details_screen.dart';

class ResultScreen extends StatelessWidget {
  final DetectionResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Detection Result'),
        backgroundColor: const Color(0xFF1F1F1F),
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
                    // Image Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: Image.file(
                          File(result.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF2A2A2A),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Low Confidence Active Learning Banner
                    if (result.isUncertain) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade600, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Uncertain Prediction (< 80%)',
                                    style: TextStyle(
                                      color: Colors.amber.shade400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade900.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.shade600),
                                  ),
                                  child: const Text(
                                    'Saved Offline',
                                    style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Low confidence — sample saved for expert review.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ActiveLearningReviewScreen()),
                                );
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    'View Pending Active Learning Queue',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, color: Color(0xFF4CAF50), size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Disease & Confidence Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            result.diseaseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: result.isUncertain
                                ? Colors.amber.withValues(alpha: 0.2)
                                : const Color(0xFF4CAF50).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: result.isUncertain
                                  ? Colors.amber
                                  : const Color(0xFF4CAF50),
                            ),
                          ),
                          child: Text(
                            '$confidencePercent%',
                            style: TextStyle(
                              color: result.isUncertain
                                  ? Colors.amber
                                  : const Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Agricultural Region Tag
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Region: ${result.regionDisplayName}',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),

                    // Prediction Probabilities Breakdown
                    const Text(
                      'Model Class Probabilities (Local FP16)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(
                      result.allProbabilities.length,
                      (index) {
                        final label = (index < 8)
                            ? [
                                'Bacterial Leaf Blight',
                                'Brown Spot',
                                'Healthy Rice Leaf',
                                'Leaf Blast',
                                'Leaf Scald',
                                'Narrow Brown Leaf Spot',
                                'Rice Hispa',
                                'Sheath Blight'
                              ][index]
                            : 'Class $index';
                        final prob = result.allProbabilities[index];
                        final probPercent = (prob * 100).toStringAsFixed(1);
                        final isTop = label == result.diseaseName;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 170,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isTop ? Colors.white : Colors.grey,
                                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: prob.clamp(0.0, 1.0),
                                  backgroundColor: const Color(0xFF2A2A2A),
                                  color: isTop
                                      ? (result.isUncertain ? Colors.amber : const Color(0xFF4CAF50))
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
                                    color: isTop ? Colors.white : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.right,
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
            ),

            // Action Buttons: More Details (RAG treatment) + Scan Another Crop
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // More Details -> RAG treatment recommendation screen
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TreatmentDetailsScreen(
                              diseaseName: result.diseaseName,
                              confidence: result.confidence,
                              language: 'en',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_outlined, color: Color(0xFF4CAF50)),
                      label: const Text(
                        'More Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Scan Another Crop (unchanged behavior)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Scan Another Crop',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
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
