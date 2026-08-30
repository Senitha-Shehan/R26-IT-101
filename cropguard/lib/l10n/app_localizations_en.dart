// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CropGuard';

  @override
  String get continueBtn => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get languageSubtitle => 'Select your preferred language to continue';

  @override
  String get langEnglish => 'English';

  @override
  String get langSinhala => 'සිංහල';

  @override
  String get langTamil => 'தமிழ்';

  @override
  String get onboardingTitle1 => 'CropGuard';

  @override
  String get onboardingSubtitle1 => 'AI-Powered Paddy Disease Detection';

  @override
  String get onboardingDesc1 =>
      'Instantly diagnose rice crop diseases in the field using local deep learning models optimized for Sri Lankan agricultural zones.';

  @override
  String get onboardingTitle2 => 'Scan Your Crop';

  @override
  String get onboardingFeature1 => 'Use live camera or select from gallery';

  @override
  String get onboardingFeature2 =>
      'Runs 100% offline — no internet connection required';

  @override
  String get onboardingFeature3 =>
      'Instant local TFLite FP16 disease classification';

  @override
  String get selectYourRegion => 'Select Your Region';

  @override
  String get regionSubtitle =>
      'CropGuard automatically selects tuned FP16 AI models based on your Sri Lankan agricultural zone.';

  @override
  String get fp16LocalModel => 'FP16 TFLite Local Model';

  @override
  String get confirmRegion => 'Confirm Region';

  @override
  String get preparingCropGuard => 'Preparing CropGuard';

  @override
  String get aiModel => 'AI Model';

  @override
  String preparingModel(int percent) {
    return 'Preparing model for offline use... ($percent%)';
  }

  @override
  String get readyForOfflineDetection => '✓ Ready for Offline Detection';

  @override
  String allSetDesc(String region) {
    return 'FP16 local model loaded for $region. CropGuard is completely configured for offline field use.';
  }

  @override
  String get regionalModelInstalled => 'Regional FP16 Model Installed';

  @override
  String get offlineEngineReady => 'Offline Inference Engine Ready';

  @override
  String regionActive(String region) {
    return '$region Active';
  }

  @override
  String get startUsingCropGuard => 'Start Using CropGuard';

  @override
  String get navHome => 'Home';

  @override
  String get navScan => 'Scan';

  @override
  String get navHistory => 'History';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get scanYourCrop => 'Scan Your Crop';

  @override
  String get scanDesc =>
      'Detect possible diseases from a paddy leaf photo using offline AI.';

  @override
  String get startScan => 'Start Scan';

  @override
  String get syncingOfflineSamples => 'Syncing offline samples...';

  @override
  String get offlineAIReady => '● Offline AI Ready';

  @override
  String samplesQueuedForSync(int count) {
    return '$count sample(s) queued for sync';
  }

  @override
  String get allSamplesSynced => '✓ Offline AI Ready • All samples synced';

  @override
  String get recentDiagnoses => 'Recent Diagnoses';

  @override
  String get viewAll => 'View All';

  @override
  String get regionalAlerts => 'Regional Alerts';

  @override
  String get alertsHub => 'Alerts Hub';

  @override
  String get pestAdvisoryTitle => 'Pest Advisory: Rice Hispa Alert';

  @override
  String pestAdvisoryDesc(String region) {
    return 'High humidity reported in $region. Check young paddy leaves.';
  }

  @override
  String get confidence => 'Confidence';

  @override
  String get region => 'Region';

  @override
  String get scanCropLeaf => 'Scan Crop Leaf';

  @override
  String get previewLeafPhoto => 'Preview Leaf Photo';

  @override
  String get analyzingTitle => 'Analyzing';

  @override
  String activeModel(String region) {
    return 'Active Model: $region';
  }

  @override
  String get localFP16Engine => 'Local FP16 Engine';

  @override
  String get positionLeaf => 'Position the paddy leaf inside the frame';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get retake => 'Retake';

  @override
  String get gallery => 'Gallery';

  @override
  String get analyzeLeaf => 'Analyze Leaf';

  @override
  String get analyzingOnDevice => 'Analyzing on your device...';

  @override
  String runningLocalModel(String region) {
    return 'Running local $region FP16 model';
  }

  @override
  String get offlineAIInference => '100% Offline AI Inference';

  @override
  String get detectionResult => 'Detection Result';

  @override
  String get highConfidencePrediction => '✓ High Confidence Prediction';

  @override
  String get uncertainPrediction => 'Uncertain Prediction (< 80%)';

  @override
  String get savedForExpertReview => '✓ Saved for Expert Review';

  @override
  String get uncertainDesc =>
      'This prediction is uncertain and has been automatically saved for expert review.';

  @override
  String regionLabel(String region) {
    return 'Region: $region';
  }

  @override
  String get modelClassProbabilities =>
      'Model Class Probabilities (Local FP16)';

  @override
  String get helpImproveDiagnosis => 'Help Improve This Diagnosis';

  @override
  String get isDiagnosisAccurate =>
      'Is this disease prediction accurate for your crop?';

  @override
  String get thankyouConfirmed => '✓ Thank you! Diagnosis confirmed.';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get looksRight => 'Looks Right';

  @override
  String get reviewCorrect => 'Review / Correct';

  @override
  String get viewTreatmentGuide => 'View Treatment Guide';

  @override
  String get scanAnotherCrop => 'Scan Another Crop';

  @override
  String get diagnosisHistory => 'Diagnosis History';

  @override
  String get syncQueue => 'Sync Queue';

  @override
  String get filterAll => 'All';

  @override
  String get filterConfirmed => 'Confirmed';

  @override
  String get filterNeedsReview => 'Needs Review';

  @override
  String get noDiagnosesFound => 'No diagnoses found';

  @override
  String get noDiagnosesDesc =>
      'Scanned crops and uncertain predictions will appear here';

  @override
  String get needsReview => 'Needs Review';

  @override
  String aiPredicted(String disease, String confidence) {
    return 'AI Predicted: $disease ($confidence%)';
  }

  @override
  String get selectCorrectDisease => 'Select Correct Disease Label:';

  @override
  String get submitCorrection => 'Submit Correction';

  @override
  String correctedLabelSaved(String disease) {
    return '✓ Corrected label saved as \"$disease\"';
  }

  @override
  String syncedSamples(int count) {
    return 'Successfully synced $count sample(s) with cloud database';
  }

  @override
  String get allSamplesUpToDate =>
      'All samples up to date (Queue synced or offline)';

  @override
  String get sampleRemovedFromQueue => 'Sample removed from queue';

  @override
  String regionConfTitle(String region) {
    return 'Region: $region';
  }

  @override
  String confLabel(String conf) {
    return 'Conf: $conf%';
  }

  @override
  String get alertsTitle => 'Regional Alerts & Notices';

  @override
  String get catAll => 'All';

  @override
  String get catPestAlerts => 'Pest Alerts';

  @override
  String get catWeather => 'Weather';

  @override
  String get profileSettings => 'Profile & Settings';

  @override
  String get farmerProfile => 'Farmer Profile';

  @override
  String get sectionAiEngine => 'AI & OFFLINE ENGINE';

  @override
  String get activeAgriculturalRegion => 'Active Agricultural Region';

  @override
  String get activeRegionDesc =>
      'Loads regional FP16 TFLite model tuned for local disease factors.';

  @override
  String get nineRegionalModelsInstalled => '9 Regional FP16 Models Installed';

  @override
  String get ready => 'Ready';

  @override
  String get sectionInformation => 'INFORMATION';

  @override
  String get aboutCropGuard => 'About CropGuard';

  @override
  String get versionInfo => 'AI Paddy Disease Detection v1.0.0';

  @override
  String get fieldScanningGuide => 'Field Scanning Guide';

  @override
  String get fieldScanningGuideSub =>
      'Tips for best camera lighting and leaf positioning';

  @override
  String get fieldScanningTips => 'Field Scanning Tips';

  @override
  String get tip1 => '• Position leaf directly inside the scan frame.';

  @override
  String get tip2 => '• Ensure adequate natural sunlight daylight.';

  @override
  String get tip3 => '• Avoid severe shadows or extremely blurry photos.';

  @override
  String get tip4 =>
      '• Predictions under 80% confidence are automatically saved for expert review.';

  @override
  String get gotIt => 'Got it';

  @override
  String activeAIModelSet(String region) {
    return 'Active AI Model set to $region';
  }

  @override
  String get cropGuardFooter =>
      'CropGuard Sri Lanka • Offline-First Agricultural AI';

  @override
  String get sectionLanguage => 'LANGUAGE';

  @override
  String get language => 'Language';

  @override
  String get languageSettingDesc => 'Choose your preferred language';

  @override
  String get diseaseNameBacterialLeafBlight => 'Bacterial Leaf Blight';

  @override
  String get diseaseNameBrownSpot => 'Brown Spot';

  @override
  String get diseaseNameHealthyRiceLeaf => 'Healthy Rice Leaf';

  @override
  String get diseaseNameLeafBlast => 'Leaf Blast';

  @override
  String get diseaseNameLeafScald => 'Leaf Scald';

  @override
  String get diseaseNameNarrowBrownLeafSpot => 'Narrow Brown Leaf Spot';

  @override
  String get diseaseNameRiceHispa => 'Rice Hispa';

  @override
  String get diseaseNameSheathBlight => 'Sheath Blight';

  @override
  String get regionCentralHighlands => 'Central Highlands';

  @override
  String get regionUvaZone => 'Uva Zone';

  @override
  String get regionEasternDryZone => 'Eastern Dry Zone';

  @override
  String get regionNorthCentralDryZone => 'North Central Dry Zone';

  @override
  String get regionNorthernDryZone => 'Northern Dry Zone';

  @override
  String get regionNorthwesternIntermediate => 'Northwestern Intermediate';

  @override
  String get regionSabaragamuwaZone => 'Sabaragamuwa Zone';

  @override
  String get regionSouthernWetZone => 'Southern Wet Zone';

  @override
  String get regionWesternWetZone => 'Western Wet Zone';
}
