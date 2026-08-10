import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';
import '../errors/detection_exceptions.dart';

class ImageUtils {
  /// Preprocesses an image file for MobileNetV2 TFLite inference.
  /// 1. Validates image file existence and size.
  /// 2. Reads & decodes image format (JPEG/PNG/WebP/BMP).
  /// 3. Resizes to 224x224.
  /// 4. Normalizes RGB pixel values to [-1.0, 1.0] range via `(pixel - 127.5) / 127.5`.
  /// 5. Formats as 4D tensor `[1, 224, 224, 3]`.
  static List<List<List<List<double>>>> preprocessImageForMobileNetV2(
    File imageFile,
  ) {
    if (!imageFile.existsSync()) {
      throw InvalidImageException(
        'Image file does not exist',
        imageFile.path,
      );
    }

    final int fileLength = imageFile.lengthSync();
    if (fileLength == 0) {
      throw InvalidImageException(
        'Image file is empty (0 bytes)',
        imageFile.path,
      );
    }

    Uint8List bytes;
    try {
      bytes = imageFile.readAsBytesSync();
    } catch (e) {
      throw InvalidImageException(
        'Failed to read image bytes',
        e.toString(),
      );
    }

    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw InvalidImageException(
        'Corrupt or unsupported image format',
        imageFile.path,
      );
    }

    // Resize image to 224 x 224
    final resizedImage = img.copyResize(
      decodedImage,
      width: AppConstants.inputImageSize,
      height: AppConstants.inputImageSize,
    );

    // Construct 4D tensor shape [1, 224, 224, 3]
    final buffer = List<List<List<List<double>>>>.generate(
      1,
      (_) => List<List<List<double>>>.generate(
        AppConstants.inputImageSize,
        (y) => List<List<double>>.generate(
          AppConstants.inputImageSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            final r = (pixel.r - 127.5) / 127.5;
            final g = (pixel.g - 127.5) / 127.5;
            final b = (pixel.b - 127.5) / 127.5;
            return <double>[r.toDouble(), g.toDouble(), b.toDouble()];
          },
        ),
      ),
    );

    return buffer;
  }
}
