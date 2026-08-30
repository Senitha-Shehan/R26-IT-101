import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'screens/onboarding_offline_screen.dart';
import 'services/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load persisted locale before app renders
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  runApp(CropDiseaseApp(localeProvider: localeProvider));
}

class CropDiseaseApp extends StatefulWidget {
  final LocaleProvider localeProvider;

  const CropDiseaseApp({super.key, required this.localeProvider});

  @override
  State<CropDiseaseApp> createState() => _CropDiseaseAppState();
}

class _CropDiseaseAppState extends State<CropDiseaseApp> {
  @override
  void initState() {
    super.initState();
    widget.localeProvider.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() => setState(() {});

  @override
  void dispose() {
    widget.localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: widget.localeProvider.locale,
      supportedLocales: LocaleProvider.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: OnboardingOfflineScreen(localeProvider: widget.localeProvider),
    );
  }
}