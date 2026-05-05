import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2E6B30).withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Point at leaf',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hold steady for best result',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}