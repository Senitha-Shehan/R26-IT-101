import 'package:flutter/material.dart';
import 'detection/detection_screen.dart';
import 'review/active_learning_review_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // CENTERED LOGO
            Image.asset(
              'assets/cropguard_logo.png',
              width: 180,
              height: 160,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.energy_savings_leaf_rounded,
                size: 100,
                color: Color(0xFF4CAF50),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'CropGuard AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Offline TFLite FP16 regional detection ready',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const Spacer(),

            // SCAN CROP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DetectionScreen()),
                      );
                    },
                    child: const Text(
                      'Scan Crop (TFLite FP16)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ACTIVE LEARNING QUEUE REVIEW BUTTON
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.grey.shade800),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActiveLearningReviewScreen()),
                      );
                    },
                    icon: const Icon(Icons.inventory_2_outlined, color: Colors.amber, size: 20),
                    label: const Text(
                      'Review Offline Samples Queue',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
