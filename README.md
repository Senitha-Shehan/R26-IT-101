# CropGuard

CropGuard is an offline-first crop disease detection platform for Sri Lankan farmers and agricultural experts. The project combines a Flutter mobile application, a FastAPI backend, regional machine-learning models, and a knowledge base for treatment recommendations.

## Project Components

| Directory | Description |
| --- | --- |
| [`cropguard/`](./cropguard/) | Flutter mobile application for image capture, offline disease detection, regional model selection, treatment guidance, and active-learning reviews |
| [`backend/`](./backend/) | FastAPI service for authentication, disease-related APIs, active-learning synchronization, and retrieval-augmented treatment recommendations |
| [`expert_web/`](./expert_web/) | Web interface for expert workflows |

## Main Features

- On-device rice leaf disease detection using regional TensorFlow Lite FP16 models
- Support for Sri Lankan agricultural regions
- Camera and gallery image input
- Offline-first operation with local model inference
- Treatment recommendations backed by the project knowledge base
- Active-learning workflow for uncertain samples and expert review
- Sinhala, Tamil, and English localization
- Optional backend synchronization when network access is available

## Requirements

### Mobile application

- Flutter 3.x
- Dart SDK `^3.10.8`
- Android physical device or emulator
- Camera and gallery permissions

### Backend

- Python 3.12 recommended
- A virtual environment
- MongoDB configuration for features that require database access
- Ollama with the configured local language model for generated treatment recommendations

## Quick Start

### 1. Start the backend

From PowerShell:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
.\.venv\Scripts\python.exe -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at `http://localhost:8000`. FastAPI documentation is available at `http://localhost:8000/docs`.

### 2. Run the Flutter application

From another terminal:

```powershell
cd cropguard
flutter pub get
flutter analyze
flutter run --dart-define=CROPGUARD_API_BASE_URL=http://192.168.8.121:8000
```

Replace `192.168.8.121` with the development computer's local network address when using a physical Android device. For an Android emulator, use:

```powershell
flutter run --dart-define=CROPGUARD_API_BASE_URL=http://10.0.2.2:8000
```

For additional setup details, see [`cropguard/SETUP_GUIDE.md`](./cropguard/SETUP_GUIDE.md).

## Regional Models

The mobile application bundles the regional models in [`cropguard/assets/models/`](./cropguard/assets/models/). These models allow disease prediction without sending an image to the backend.

The supported regional model zones include:

- Central Highlands
- Uva
- Eastern Dry Zone
- North Central Dry Zone
- Northern Dry Zone
- Northwestern Intermediate Zone
- Sabaragamuwa
- Southern Wet Zone
- Western Wet Zone

## Recent UI Update

The dedicated **Alerts** tab has been removed from the mobile application's bottom navigation.

The update includes:

- Removal of the Alerts item from bottom navigation
- Removal of the Alerts page from the navigation stack
- Removal of the notification shortcut from the home-screen header
- Removal of the “Alerts Hub” navigation link
- Preservation of the regional alerts preview content on the home screen

## Development Checks

Run the Flutter analyzer before submitting mobile application changes:

```powershell
cd cropguard
flutter analyze
```

Run backend tests with:

```powershell
cd backend
.\.venv\Scripts\python.exe -m pytest
```

## Repository Notes

- Do not commit virtual environments, generated build output, credentials, or local database configuration.
- Keep model files and knowledge-base assets synchronized with the registry and application configuration.
- When testing on a physical device, ensure the device and development computer are connected to the same network.

