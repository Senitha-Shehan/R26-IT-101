import 'package:flutter/material.dart';

class TreatmentGuideScreen extends StatelessWidget {
  final String diseaseName;

  const TreatmentGuideScreen({super.key, required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text("Treatment Guide"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Name
            Text(
              diseaseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // CHEMICAL
            _buildCard(
              icon: Icons.science,
              title: "Chemical Treatment",
              description:
                  "Apply Copper oxychloride 0.3% early morning. Repeat every 7 days.",
              color: const Color(0xFF4A90D9),
            ),

            // ORGANIC
            _buildCard(
              icon: Icons.eco,
              title: "Organic Option",
              description: "Use neem oil spray weekly to reduce fungal spread.",
              color: const Color(0xFF4CAF50),
            ),

            // SAFETY
            _buildCard(
              icon: Icons.warning_amber_rounded,
              title: "Safety Notes",
              description:
                  "Wear gloves and avoid contact for 24 hours after spraying.",
              color: const Color(0xFFFF9800),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                "From verified Sri Lankan agricultural sources",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ),

            const SizedBox(height: 30),

            // BACK BUTTON
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF252525),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: const Center(
                  child: Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
