import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../services/locale_provider.dart';
import 'region_select_screen.dart';

class OnboardingOfflineScreen extends StatefulWidget {
  final LocaleProvider? localeProvider;

  const OnboardingOfflineScreen({super.key, this.localeProvider});

  @override
  State<OnboardingOfflineScreen> createState() => _OnboardingOfflineScreenState();
}

class _OnboardingOfflineScreenState extends State<OnboardingOfflineScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 3 pages: 0 = Language, 1 = Welcome, 2 = Features
  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegionSelectScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco_rounded, color: AppTheme.accentGreen, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'CropGuard',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  // Skip only visible on welcome+feature pages
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegionSelectScreen()),
                        );
                      },
                      child: Text(
                        l?.skip ?? 'Skip',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  // Page 0: Language Selection (inline, no nav)
                  _buildLanguagePage(),
                  // Page 1: Welcome
                  _buildWelcomePage(l),
                  // Page 2: Features
                  _buildFeaturesPage(l),
                ],
              ),
            ),

            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.accentGreen : AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Primary Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(
                  _currentPage == _pageCount - 1
                      ? (l?.getStarted ?? 'Get Started')
                      : (l?.continueBtn ?? 'Continue'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Page 0: Inline language selection (no separate screen, immediate effect)
  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 24),
          // Trilingual title — understandable before language is chosen
          const Text(
            'Choose Language\nභාෂාව තෝරන්න\nமொழியை தேர்ந்தெடுங்கள்',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _buildLangTile('en', 'English', 'English'),
          const SizedBox(height: 12),
          _buildLangTile('si', 'සිංහල', 'Sinhala'),
          const SizedBox(height: 12),
          _buildLangTile('ta', 'தமிழ்', 'Tamil'),
        ],
      ),
    );
  }

  Widget _buildLangTile(String code, String nativeName, String englishName) {
    final provider = widget.localeProvider ?? LocaleProvider.instance;
    final isSelected = provider.locale.languageCode == code;
    return GestureDetector(
      onTap: () => provider.setLocale(Locale(code)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B3A1B) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.accentGreen : AppTheme.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      color: isSelected ? AppTheme.accentGreen : AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    englishName,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppTheme.accentGreen, size: 26, key: ValueKey('c'))
                  : const Icon(Icons.radio_button_unchecked_rounded,
                      color: AppTheme.textSecondary, size: 26, key: ValueKey('u')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations? l) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.eco_rounded, color: AppTheme.accentGreen, size: 72),
          ),
          const SizedBox(height: 36),
          Text(
            l?.appName ?? 'CropGuard',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l?.onboardingSubtitle1 ?? 'AI-Powered Paddy Disease Detection',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l?.onboardingDesc1 ??
                'Instantly diagnose rice crop diseases using local AI models for Sri Lankan agricultural zones.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(AppLocalizations? l) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.center_focus_strong_rounded,
                color: AppTheme.accentGreen, size: 72),
          ),
          const SizedBox(height: 36),
          Text(
            l?.onboardingTitle2 ?? 'Scan Your Crop',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.camera_alt_rounded,
              l?.onboardingFeature1 ?? 'Use live camera or select from gallery'),
          const SizedBox(height: 12),
          _buildFeatureRow(Icons.wifi_off_rounded,
              l?.onboardingFeature2 ?? 'Runs 100% offline — no internet connection required'),
          const SizedBox(height: 12),
          _buildFeatureRow(Icons.verified_rounded,
              l?.onboardingFeature3 ?? 'Instant local TFLite FP16 disease classification'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Icon(icon, color: AppTheme.accentGreen, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}