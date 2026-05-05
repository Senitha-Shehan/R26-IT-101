import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/scan_button.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/corner_brackets.dart';
import './result_screen.dart';
import './undetected_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _isReady = false;

  late AnimationController _bracketController;
  late Animation<double> _bracketAnimation;

  @override
  void initState() {
    super.initState();

    _bracketController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bracketAnimation =
        Tween(begin: 0.85, end: 1.0).animate(_bracketController);

    _initCamera();
  }

  Future<void> _initCamera() async {
    final cams = await availableCameras();
    _controller = CameraController(
      cams.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (!mounted) return;
    setState(() => _isReady = true);
  }

  Future<void> _capture() async {
    if (!_isReady) return;
    final img = await _controller!.takePicture();
    debugPrint("Captured: ${img.path}");
  }

  @override
  void dispose() {
    _controller?.dispose();
    _bracketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text("Scan",
                      style: TextStyle(color: Colors.white)),
                  const Spacer(),
                ],
              ),
            ),

            // Camera area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _isReady
                          ? CameraPreview(_controller!)
                          : Container(color: Colors.black),

                      CornerBrackets(opacity: _bracketAnimation.value),

                      const CameraOverlay(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            // 👇 REPLACE OLD BUTTON WITH THIS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LowConfidenceResultScreen(
                            imagePath: '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),

                  ScanButton(onTap: _capture),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(
                            imagePath: '',
                            result: const DetectionResult(
                              confidence: 0.91,
                              diseaseName: 'Leaf Blight',
                              cropName: 'Paddy',
                              treatments: [
                                'Apply fungicide',
                                'Remove infected leaves',
                                'Avoid excess watering',
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}