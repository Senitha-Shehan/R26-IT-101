import 'package:flutter/material.dart';
// import 'screens/notification_screen.dart';
import 'screens/onboarding_offline_screen.dart';

void main() {
  runApp(const CropDiseaseApp());
}

class CropDiseaseApp extends StatelessWidget {
  const CropDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingOfflineScreen(),
    );
  }
}