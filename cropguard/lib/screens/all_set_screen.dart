import 'package:flutter/material.dart';

class AllSetScreen extends StatefulWidget {
  const AllSetScreen({super.key});

  @override
  State<AllSetScreen> createState() => _AllSetScreenState();
}

class _AllSetScreenState extends State<AllSetScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseCtrl;
  late AnimationController fadeCtrl;

  late Animation<double> pulse;
  late Animation<double> fade;

  final items = const [
    'Offline model ready',
    'Region set',
    'System configured',
  ];

  @override
  void initState() {
    super.initState();

    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fade = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    pulse = Tween(begin: 0.93, end: 1.0).animate(pulseCtrl);
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    pulseCtrl.dispose();
    super.dispose();
  }

  Widget checkItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: Color(0xFF4CAF50), size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: FadeTransition(
        opacity: fade,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  return Transform.scale(
                    scale: pulse.value,
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF4CAF50),
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "You're all set",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ...items.map(checkItem),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to scan screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text('Start Scanning'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}