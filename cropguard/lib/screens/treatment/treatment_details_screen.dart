import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../models/treatment_recommendation.dart';
import '../../services/treatment/treatment_service.dart';
import '../../services/translation/translation_service.dart';

/// Shows RAG-generated, Knowledge-Base-grounded treatment details for an
/// identified disease. Handles loading, error/offline, not-found and content
/// states. Reached from the "More Details" button on the scan result screen.
class TreatmentDetailsScreen extends StatefulWidget {
  final String diseaseName;
  final double? confidence;
  final String? crop;
  final String language;

  const TreatmentDetailsScreen({
    super.key,
    required this.diseaseName,
    this.confidence,
    this.crop,
    this.language = 'en',
  });

  @override
  State<TreatmentDetailsScreen> createState() => _TreatmentDetailsScreenState();
}

class _TreatmentDetailsScreenState extends State<TreatmentDetailsScreen> {
  final TreatmentService _service = TreatmentService();
  final TranslationService _translation = TranslationService();

  bool _loading = true;
  bool _offline = false;
  String? _error;

  // English (from RAG) is the source of truth; translations are cached by code.
  final Map<String, TreatmentRecommendation> _cache = {};
  String _selectedLang = 'en';
  bool _translating = false;

  // Language selector: code -> button label (native script).
  static const List<MapEntry<String, String>> _languages = [
    MapEntry('en', 'English'),
    MapEntry('si', 'සිංහල'),
    MapEntry('ta', 'தமிழ்'),
  ];

  static const _bg = Color(0xFF141414);
  static const _card = Color(0xFF1F1F1F);
  static const _green = Color(0xFF4CAF50);

  TreatmentRecommendation? get _displayed => _cache[_selectedLang] ?? _cache['en'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// True when the device has no active network interface (WiFi / mobile both off).
  Future<bool> _isOffline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.isEmpty ||
          results.every((r) => r == ConnectivityResult.none);
    } catch (_) {
      // If the check itself fails, don't block the request; let it try.
      return false;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _offline = false;
    });

    // Device-level connectivity gate: if there is no network at all, prompt the
    // user to turn on data/WiFi instead of attempting an unreachable request.
    if (await _isOffline()) {
      if (!mounted) return;
      setState(() {
        _offline = true;
        _loading = false;
      });
      return;
    }

    try {
      final result = await _service.fetchTreatment(
        diseaseName: widget.diseaseName,
        confidence: widget.confidence,
        crop: widget.crop,
        language: 'en', // Always fetch the English source; translate on demand.
      );
      if (!mounted) return;
      setState(() {
        _cache
          ..clear()
          ..['en'] = result;
        _selectedLang = 'en';
        _loading = false;
      });
    } on TreatmentServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _onSelectLang(String code) async {
    if (code == _selectedLang || _translating) return; // ignore no-op / concurrent

    // Cached already (e.g. en -> si -> ta -> si): switch without calling Gemini.
    if (_cache.containsKey(code)) {
      setState(() => _selectedLang = code);
      return;
    }

    final source = _cache['en'];
    if (source == null) return;

    setState(() => _translating = true);
    try {
      final translated = await _translation.translateRecommendation(source, code);
      if (!mounted) return;
      setState(() {
        _cache[code] = translated;
        _selectedLang = code;
        _translating = false;
      });
    } on TranslationException catch (e) {
      if (!mounted) return;
      setState(() => _translating = false);
      // Keep the current content visible; show a friendly message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFF8A2E2E)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Treatment Details'),
        backgroundColor: _card,
        elevation: 0,
      ),
      body: SafeArea(child: _buildBody()),
      // Persistent action, mirroring the result screen. Hidden only during the
      // initial RAG fetch (before there is anything to act on).
      bottomNavigationBar: _loading ? null : _buildScanAnotherBar(),
    );
  }

  /// Returns to the scanning flow by popping both this page and the result page.
  void _scanAnotherCrop() {
    final nav = Navigator.of(context);
    nav.pop(); // close More Details
    if (nav.canPop()) {
      nav.pop(); // close Result -> back to the detection/scan screen
    }
  }

  Widget _buildScanAnotherBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _scanAnotherCrop,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text(
              'Scan Another Crop',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildLoading();
    if (_offline) return _buildOffline();
    if (_error != null) return _buildError(_error!);
    final data = _displayed;
    if (data == null || !data.found) return _buildNotFound(data?.message);

    return Column(
      children: [
        _buildLanguageBar(),
        Expanded(
          child: Stack(
            children: [
              _buildContent(data),
              if (_translating) _buildTranslatingOverlay(),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- language selector
  Widget _buildLanguageBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          for (final lang in _languages) ...[
            Expanded(child: _langButton(lang.key, lang.value)),
            if (lang.key != _languages.last.key) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _langButton(String code, String label) {
    final bool selected = _selectedLang == code;
    // Disable interaction while a translation is in flight.
    final bool enabled = !_translating;
    return Material(
      color: selected ? _green : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? () => _onSelectLang(code) : null,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _green : const Color(0xFF3A3A3A),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslatingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _green),
              SizedBox(height: 14),
              Text(
                'Translating...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ states
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _green),
          SizedBox(height: 16),
          Text(
            'Retrieving treatment information\nfrom the knowledge base...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOffline() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: 60),
            const SizedBox(height: 18),
            const Text(
              "You're offline",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Turn on Mobile data or Wi-Fi to view treatment details.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.orangeAccent, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, color: Colors.grey, size: 56),
            const SizedBox(height: 16),
            Text(
              message?.isNotEmpty == true
                  ? message!
                  : 'Treatment information is not available in the current knowledge base.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- content
  Widget _buildContent(TreatmentRecommendation data) {
    final confidencePercent =
        data.confidence != null ? '${(data.confidence! * 100).toStringAsFixed(1)}%' : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease Identified
          _sectionLabel('Disease Identified'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.diseaseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (confidencePercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green),
                  ),
                  child: Text(
                    confidencePercent,
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (data.description.isNotEmpty)
            _textSection(Icons.info_outline, 'What is it?', data.description),
          _listSection(Icons.coronavirus_outlined, 'Symptoms', data.symptoms),
          _listSection(Icons.healing, 'Treatment', data.treatment, numbered: true),
          _listSection(Icons.checklist, 'Recommended Actions', data.recommendedActions),
          _listSection(Icons.shield_outlined, 'Prevention', data.prevention),
          _listSection(
            Icons.warning_amber_rounded,
            'Warnings / Precautions',
            data.warnings,
            accent: const Color(0xFFFF9800),
          ),

          if (data.sources.isNotEmpty) _buildSources(data.sources),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      );

  Widget _cardWrap({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );

  Widget _header(IconData icon, String title, Color accent) => Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      );

  Widget _textSection(IconData icon, String title, String body) {
    return _cardWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(icon, title, _green),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _listSection(
    IconData icon,
    String title,
    List<String> items, {
    bool numbered = false,
    Color accent = _green,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return _cardWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(icon, title, accent),
          const SizedBox(height: 10),
          ...List.generate(items.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 22,
                    alignment: Alignment.centerLeft,
                    child: numbered
                        ? Text(
                            '${i + 1}.',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : Icon(Icons.circle, color: accent, size: 7),
                  ),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSources(List<TreatmentSource> sources) {
    return _cardWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(Icons.menu_book, 'Source', Colors.grey),
          const SizedBox(height: 10),
          ...sources.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${s.sourceFile} (p.${s.pageNumber})',
                style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'From verified agricultural knowledge base sources',
            style: TextStyle(color: Color(0xFF666666), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
