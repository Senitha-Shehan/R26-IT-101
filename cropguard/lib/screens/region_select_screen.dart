import 'package:flutter/material.dart';
import 'all_set_screen.dart';

class RegionSelectScreen extends StatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  State<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends State<RegionSelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController fadeCtrl;
  late Animation<double> fade;

  int selected = 0;

  final regions = const [
    ('Colombo', 'Western'),
    ('Kandy', 'Central'),
    ('Jaffna', 'Northern'),
    ('Galle', 'Southern'),
    ('Kurunegala', 'North Western'),
    ('Anuradhapura', 'North Central'),
  ];

  @override
  void initState() {
    super.initState();
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    fade = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Icon(Icons.location_on,
                  color: Color(0xFF4CAF50), size: 50),

              const SizedBox(height: 20),

              const Text(
                'Select your region',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'We adapt detection based on location',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: regions.length,
                  itemBuilder: (context, i) {
                    final r = regions[i];
                    final isSelected = selected == i;

                    return GestureDetector(
                      onTap: () => setState(() => selected = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1B3A1B)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade800,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${r.$1} - ${r.$2}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check,
                                  color: Color(0xFF4CAF50)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllSetScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}