# CropGuard Mobile App - Setup & Dependency Guide

This guide provides setup instructions for team members pulling this branch.

---

## 📋 Prerequisites

Before running the application, ensure your local development environment has:
- **Flutter SDK**: `^3.10.8` (or Flutter 3.x compatible)
- **Dart SDK**: `^3.10.8`
- **Target Device**: Android physical device (e.g., Samsung Galaxy) or Emulator with Camera/Gallery access

---

## 🚀 Quick Setup Instructions

Follow these commands after pulling the latest code from Git:

```bash
# 1. Navigate to cropguard directory
cd cropguard

# 2. Fetch and install all Dart & Flutter package dependencies
flutter pub get

# 3. Verify static code analysis
flutter analyze

# 4. Launch app on connected device or emulator
flutter run
```

---

## 📦 Installed Packages & Purpose

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `tflite_flutter` | `^0.12.1` | Local on-device execution of regional TFLite FP16 neural network models. |
| `camera` | `^0.10.5+5` | Real-time device camera preview and leaf capture interface. |
| `image_picker` | `^1.1.2` | Allows selecting crop images from device camera or photo gallery. |
| `path_provider` | `^2.1.4` | Locates local app document directories for archiving offline active learning samples. |
| `shared_preferences` | `^2.3.2` | Persistent key-value local storage for offline active learning queue metadata. |
| `image` | `^4.3.0` | Image decoding, resizing (224x224), and pixel array manipulation for TFLite tensor input. |
| `cupertino_icons` | `^1.0.8` | Cupertino style icons for iOS/cross-platform UI elements. |

---

## 🧠 TFLite Regional Models Asset Setup

All 9 Sri Lankan regional TFLite FP16 models are bundled in `assets/models/` and registered in `pubspec.yaml`:
- `central_highlands_float16.tflite`
- `uva_zone_float16.tflite`
- `eastern_dry_zone_float16.tflite`
- `north_central_dry_zone_float16.tflite`
- `northern_dry_zone_float16.tflite`
- `northwestern_intermediate_float16.tflite`
- `sabaragamuwa_zone_float16.tflite`
- `southern_wet_zone_float16.tflite`
- `western_wet_zone_float16.tflite`

Running `flutter pub get` will automatically register these models in the app asset bundle.

---

## 🛠️ Troubleshooting

If you encounter any caching or dependency build issues after pulling:
```bash
flutter clean
flutter pub get
flutter run
```
