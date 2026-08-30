import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'detection/detection_screen.dart';
import 'review/active_learning_review_screen.dart';
import 'notification_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final List<Widget> pages = [
      HomeScreen(onNavigateToTab: _onTabTapped),
      const DetectionScreen(),
      const ActiveLearningReviewScreen(),
      const NotificationScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceDark,
        selectedItemColor: AppTheme.accentGreen,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            activeIcon: const Icon(Icons.home_rounded, color: AppTheme.accentGreen),
            label: l?.navHome ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt_outlined),
            activeIcon: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentGreen),
            label: l?.navScan ?? 'Scan',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_rounded),
            activeIcon: const Icon(Icons.history_rounded, color: AppTheme.accentGreen),
            label: l?.navHistory ?? 'History',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications_rounded, color: AppTheme.accentGreen),
            label: l?.navAlerts ?? 'Alerts',
          ),
        ],
      ),
    );
  }
}
