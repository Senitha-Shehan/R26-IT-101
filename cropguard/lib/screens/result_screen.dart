import 'dart:io';
import 'package:flutter/material.dart';
import 'treatment_guide_screen.dart';

class DetectionResult {
  final double confidence;
  final String diseaseName;
  final String cropName;
  final List<String> treatments;

  const DetectionResult({
    required this.confidence,
    required this.diseaseName,
    required this.cropName,
    required this.treatments,
  });
}

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final DetectionResult result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (result.confidence * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                    // IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF2A3A2A),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF4CAF50),
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // DISEASE + CONFIDENCE
                    Text(
                      '${result.diseaseName} ($confidencePercent%)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // CROP
                    Text(
                      result.cropName,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // TREATMENTS (MAX 3)
                    ...result.treatments
                        .take(3)
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      color: Color(0xFFCCCCCC),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    const SizedBox(height: 20),

                    // MORE DETAILS
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TreatmentGuideScreen(
                              diseaseName: result.diseaseName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: const Center(
                          child: Text(
                            'More details',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SCAN AGAIN BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF56C95F), Color(0xFF3DAF46)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Scan Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
