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
  String get onboardingSubtitle1 => 'Paddy Disease Detection';

  @override
  String get onboardingDesc1 =>
      'Check rice crop health in the field with guidance suited to Sri Lankan farming regions.';

  @override
  String get onboardingTitle2 => 'Scan Your Crop';

  @override
  String get onboardingFeature1 => 'Use live camera or select from gallery';

  @override
  String get onboardingFeature2 =>
      'Works without internet — no connection needed';

  @override
  String get onboardingFeature3 =>
      'Get quick results while you are in the field';

  @override
  String get selectYourRegion => 'Select Your Region';

  @override
  String get regionSubtitle =>
      'CropGuard adjusts its advice to suit your Sri Lankan farming region.';

  @override
  String get fp16LocalModel => 'Recommended for your region';

  @override
  String get confirmRegion => 'Confirm Region';

  @override
  String get preparingCropGuard => 'Preparing CropGuard';

  @override
  String get aiModel => 'Crop care guide';

  @override
  String preparingModel(int percent) {
    return 'Preparing your crop care guide... ($percent%)';
  }

  @override
  String get readyForOfflineDetection => '✓ Ready for Offline Detection';

  @override
  String allSetDesc(String region) {
    return 'CropGuard is ready to help you care for crops in $region, even without internet.';
  }

  @override
  String get regionalModelInstalled => 'Regional crop guide ready';

  @override
  String get offlineEngineReady => 'Works without internet';

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
      'Check for possible diseases from a paddy leaf photo, even without internet.';

  @override
  String get startScan => 'Start Scan';

  @override
  String get syncingOfflineSamples => 'Saving your reports...';

  @override
  String get offlineAIReady => '● Ready to use without internet';

  @override
  String samplesQueuedForSync(int count) {
    return '$count report(s) waiting to be sent';
  }

  @override
  String get allSamplesSynced => '✓ Ready to use • Reports are up to date';

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
    return 'Crop guide: $region';
  }

  @override
  String get localFP16Engine => 'Works on your phone';

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
    return 'Checking your leaf for $region...';
  }

  @override
  String get offlineAIInference => 'Works without internet';

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
  String get modelClassProbabilities => 'Possible matches';

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
  String get syncQueue => 'Saved Reports';

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
    return 'Possible result: $disease ($confidence%)';
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
    return 'Successfully sent $count report(s)';
  }

  @override
  String get allSamplesUpToDate => 'Your saved reports are up to date';

  @override
  String get sampleRemovedFromQueue => 'Report removed';

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
  String get sectionAiEngine => 'CROP CARE';

  @override
  String get activeAgriculturalRegion => 'Active Agricultural Region';

  @override
  String get activeRegionDesc =>
      'Use crop care guidance suited to your selected region.';

  @override
  String get nineRegionalModelsInstalled => 'Regional crop guides ready';

  @override
  String get ready => 'Ready';

  @override
  String get sectionInformation => 'INFORMATION';

  @override
  String get aboutCropGuard => 'About CropGuard';

  @override
  String get versionInfo => 'Paddy crop care v1.0.0';

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
      '• Results that are not clear are saved so they can be checked later.';

  @override
  String get gotIt => 'Got it';

  @override
  String activeAIModelSet(String region) {
    return 'Crop guide set to $region';
  }

  @override
  String get cropGuardFooter => 'CropGuard Sri Lanka • Made for farmers';

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
