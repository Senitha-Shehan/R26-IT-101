import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../services/locale_provider.dart';

/// Polished language selection screen.
/// Can be used during onboarding and from the Profile Settings screen.
class LanguageSelectScreen extends StatefulWidget {
  final LocaleProvider? localeProvider;
  final bool isOnboarding;

  const LanguageSelectScreen({
    super.key,
    this.localeProvider,
    this.isOnboarding = false,
  });

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  static const List<_LangOption> _options = [
    _LangOption('en', 'English', 'English'),
    _LangOption('si', 'සිංහල', 'Sinhala'),
    _LangOption('ta', 'தமிழ்', 'Tamil'),
  ];

  late LocaleProvider _provider;
  late String _selected;

  @override
  void initState() {
    super.initState();
    _provider = widget.localeProvider ?? LocaleProvider.instance;
    _selected = _provider.locale.languageCode;
  }

  Future<void> _select(String code) async {
    setState(() => _selected = code);
    await _provider.setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              title: Text(l?.language ?? 'Language'),
              backgroundColor: AppTheme.surfaceDark,
              elevation: 0,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isOnboarding) ...[
                const SizedBox(height: 32),
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
              ],

              // Title (always in all 3 languages so every farmer can read it)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Choose Language  •  භාෂාව  •  மொழி',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Select your language  •  ඔබේ භාෂාව  •  உங்கள் மொழி',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Language options
              ...List.generate(_options.length, (i) {
                final opt = _options[i];
                final isSelected = _selected == opt.code;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GestureDetector(
                    onTap: () => _select(opt.code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1B3A1B) : AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.accentGreen : AppTheme.surfaceBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Native script name — large, always visible
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.nativeName,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.accentGreen : AppTheme.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt.englishName,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.accentGreen,
                                    size: 28,
                                    key: ValueKey('check'),
                                  )
                                : const Icon(
                                    Icons.radio_button_unchecked_rounded,
                                    color: AppTheme.textSecondary,
                                    size: 28,
                                    key: ValueKey('uncheck'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              if (widget.isOnboarding)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: const Text(
                    'Continue  •  ඉදිරියට  •  தொடரவும்',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String nativeName;
  final String englishName;

  const _LangOption(this.code, this.nativeName, this.englishName);
}
