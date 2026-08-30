import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/regional_models_config.dart';
import '../../models/detection_result.dart';
import '../../models/region_model_config.dart';
import '../../services/tflite/detection_service.dart';
import '../../services/user_preferences.dart';
import '../../widgets/corner_brackets.dart';
import '../../widgets/camera_overlay.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/region_localizer.dart';
import '../result/result_screen.dart';

enum ScanStep { camera, preview, analyzing }

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final DetectionService _detectionService = DetectionService();

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  File? _selectedImage;
  RegionModelConfig _selectedRegion = RegionalModelsConfig.defaultRegion;
  ScanStep _currentStep = ScanStep.camera;
  String? _errorMessage;

  late AnimationController _bracketController;
  late Animation<double> _bracketAnimation;

  @override
  void initState() {
    super.initState();
    _bracketController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bracketAnimation = Tween(begin: 0.85, end: 1.0).animate(_bracketController);

    _loadRegion();
    _initCamera();
  }

  Future<void> _loadRegion() async {
    final region = await UserPreferences.getSelectedRegion();
    if (!mounted) return;
    setState(() => _selectedRegion = region);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _captureCameraImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(photo.path);
        _currentStep = ScanStep.preview;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _pickGalleryImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _currentStep = ScanStep.preview;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _runAnalysis() async {
    if (_selectedImage == null) return;

    setState(() {
      _currentStep = ScanStep.analyzing;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final DetectionResult result = await _detectionService.detectDisease(
        imageFile: _selectedImage!,
        regionConfig: _selectedRegion,
      );

      if (!mounted) return;
      setState(() => _currentStep = ScanStep.camera);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentStep = ScanStep.preview;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _bracketController.dispose();
    _detectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final regionName = RegionLocalizer.getDisplayName(
      context,
      _selectedRegion.regionId,
      fallback: _selectedRegion.displayName,
    );

    String appBarTitle;
    switch (_currentStep) {
      case ScanStep.preview:
        appBarTitle = l?.previewLeafPhoto ?? 'Preview Leaf Photo';
        break;
      case ScanStep.analyzing:
        appBarTitle = l?.analyzingTitle ?? 'Analyzing';
        break;
      default:
        appBarTitle = l?.scanCropLeaf ?? 'Scan Crop Leaf';
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: AppTheme.surfaceDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: AppTheme.accentGreen),
            tooltip: l?.chooseFromGallery ?? 'Choose from Gallery',
            onPressed: _pickGalleryImage,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Region Badge Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.surfaceDark,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.accentGreen, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l?.activeModel(regionName) ?? 'Active Model: $regionName',
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    l?.localFP16Engine ?? 'Local FP16 Engine',
                    style: const TextStyle(
                        color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildMainView(l, regionName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(AppLocalizations? l, String regionName) {
    switch (_currentStep) {
      case ScanStep.camera:
        return _buildCameraView(l);
      case ScanStep.preview:
        return _buildPreviewView(l);
      case ScanStep.analyzing:
        return _buildAnalyzingView(l, regionName);
    }
  }

  Widget _buildCameraView(AppLocalizations? l) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.accentGreen),
                        ),
                      ),
                CornerBrackets(opacity: _bracketAnimation.value),
                const CameraOverlay(),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.crop_free_rounded, color: AppTheme.accentGreen, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l?.positionLeaf ?? 'Position the paddy leaf inside the frame',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 32,
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.textPrimary),
              ),
              onPressed: _pickGalleryImage,
            ),
            GestureDetector(
              onTap: _captureCameraImage,
              child: Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentGreen, width: 4),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewView(AppLocalizations? l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: AppTheme.statusError, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = ScanStep.camera;
                    _selectedImage = null;
                  });
                },
                child: Text(l?.retake ?? 'Retake'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _pickGalleryImage,
                child: Text(l?.gallery ?? 'Gallery'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _runAnalysis,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(l?.analyzeLeaf ?? 'Analyze Leaf'),
        ),
      ],
    );
  }

  Widget _buildAnalyzingView(AppLocalizations? l, String regionName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentGreen, width: 2),
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.accentGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l?.analyzingOnDevice ?? 'Analyzing on your device...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l?.runningLocalModel(regionName) ?? 'Running local $regionName FP16 model',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, color: AppTheme.accentGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  l?.offlineAIInference ?? '100% Offline AI Inference',
                  style: const TextStyle(
                      color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
