import 'package:flutter/material.dart';
import 'region_select_screen.dart';

class OnboardingOfflineScreen extends StatefulWidget {
  const OnboardingOfflineScreen({super.key});

  @override
  State<OnboardingOfflineScreen> createState() =>
      _OnboardingOfflineScreenState();
}

class _OnboardingOfflineScreenState extends State<OnboardingOfflineScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseCtrl;
  late AnimationController fadeCtrl;
  late Animation<double> pulse;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    pulse = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut),
    );

    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    fade = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    pulseCtrl.dispose();
    fadeCtrl.dispose();
    super.dispose();
  }

  Widget ring(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4CAF50).withOpacity(opacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Illustration
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: pulse,
                      builder: (_, __) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: pulse.value,
                              child: ring(200, 0.06),
                            ),
                            Transform.scale(
                              scale: pulse.value * 0.97,
                              child: ring(156, 0.10),
                            ),

                            // Phone
                            Container(
                              width: 72,
                              height: 110,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C1C),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade800),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.eco_rounded,
                                      color: Color(0xFF4CAF50), size: 22),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: 30,
                                    height: 3,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              top: 46,
                              right: 62,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF2A2A2A),
                                child: const Icon(
                                  Icons.thumb_up_alt_rounded,
                                  size: 14,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final active = i == 1;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 24 : 6,
                      height: 4,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 36),

                const Text(
                  'Detects diseases\noffline',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'No internet needed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888), height: 1.6),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegionSelectScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Skip setup',
                  style: TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}