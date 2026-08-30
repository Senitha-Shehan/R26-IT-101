// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'CropGuard';

  @override
  String get continueBtn => 'தொடரவும்';

  @override
  String get skip => 'தவிர்';

  @override
  String get getStarted => 'தொடங்குங்கள்';

  @override
  String get chooseLanguage => 'மொழியை தேர்ந்தெடுங்கள்';

  @override
  String get languageSubtitle =>
      'தொடர உங்கள் விருப்பமான மொழியை தேர்ந்தெடுங்கள்';

  @override
  String get langEnglish => 'English';

  @override
  String get langSinhala => 'සිංහල';

  @override
  String get langTamil => 'தமிழ்';

  @override
  String get onboardingTitle1 => 'CropGuard';

  @override
  String get onboardingSubtitle1 => 'AI-இயக்கும் நெல் நோய் கண்டறிதல்';

  @override
  String get onboardingDesc1 =>
      'இலங்கையின் விவசாய மண்டலங்களுக்கு ஏற்ற உள்ளூர் AI மாதிரிகளைப் பயன்படுத்தி வயலிலேயே நெல் நோய்களை உடனடியாக கண்டறியுங்கள்.';

  @override
  String get onboardingTitle2 => 'உங்கள் பயிரை பரிசோதிக்கவும்';

  @override
  String get onboardingFeature1 =>
      'நேரடி கேமரா அல்லது கேலரியைப் பயன்படுத்துங்கள்';

  @override
  String get onboardingFeature2 => '100% Offline — இணைய இணைப்பு தேவையில்லை';

  @override
  String get onboardingFeature3 => 'உடனடி உள்ளூர் TFLite FP16 நோய் கண்டறிதல்';

  @override
  String get selectYourRegion => 'உங்கள் பகுதியை தேர்ந்தெடுங்கள்';

  @override
  String get regionSubtitle =>
      'உங்கள் இலங்கை விவசாய மண்டலத்தின் அடிப்படையில் CropGuard தானாக AI மாதிரியை தேர்ந்தெடுக்கும்.';

  @override
  String get fp16LocalModel => 'FP16 உள்ளூர் AI மாதிரி';

  @override
  String get confirmRegion => 'பகுதியை உறுதிப்படுத்தவும்';

  @override
  String get preparingCropGuard => 'CropGuard தயாராகிறது';

  @override
  String get aiModel => 'AI மாதிரி';

  @override
  String preparingModel(int percent) {
    return 'ஆஃப்லைன் பயன்பாட்டிற்கு மாதிரி தயாராகிறது... ($percent%)';
  }

  @override
  String get readyForOfflineDetection =>
      '✓ ஆஃப்லைன் கண்டறிதலுக்கு தயாராக உள்ளது';

  @override
  String allSetDesc(String region) {
    return '$region க்கான FP16 உள்ளூர் மாதிரி ஏற்றப்பட்டது. CropGuard ஆஃப்லைன் வயல் பயன்பாட்டிற்கு முழுமையாக அமைக்கப்பட்டது.';
  }

  @override
  String get regionalModelInstalled => 'பிராந்திய FP16 மாதிரி நிறுவப்பட்டது';

  @override
  String get offlineEngineReady => 'ஆஃப்லைன் AI இயந்திரம் தயாராக உள்ளது';

  @override
  String regionActive(String region) {
    return '$region செயலில் உள்ளது';
  }

  @override
  String get startUsingCropGuard => 'CropGuard பயன்படுத்தத் தொடங்குங்கள்';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navScan => 'ஸ்கேன்';

  @override
  String get navHistory => 'வரலாறு';

  @override
  String get navAlerts => 'எச்சரிக்கைகள்';

  @override
  String get scanYourCrop => 'உங்கள் பயிரை பரிசோதிக்கவும்';

  @override
  String get scanDesc =>
      'ஆஃப்லைன் AI பயன்படுத்தி நெல் இலை புகைப்படத்திலிருந்து நோய்களை கண்டறியுங்கள்.';

  @override
  String get startScan => 'ஸ்கேன் ஆரம்பிக்கவும்';

  @override
  String get syncingOfflineSamples =>
      'ஆஃப்லைன் மாதிரிகள் ஒத்திசைக்கப்படுகின்றன...';

  @override
  String get offlineAIReady => '● ஆஃப்லைன் AI தயாராக உள்ளது';

  @override
  String samplesQueuedForSync(int count) {
    return '$count மாதிரி(கள்) ஒத்திசைவுக்காக காத்திருக்கின்றன';
  }

  @override
  String get allSamplesSynced =>
      '✓ ஆஃப்லைன் AI தயாராக உள்ளது • அனைத்து மாதிரிகளும் ஒத்திசைக்கப்பட்டன';

  @override
  String get recentDiagnoses => 'சமீபத்திய நோய் கண்டறிதல்';

  @override
  String get viewAll => 'அனைத்தையும் காண்க';

  @override
  String get regionalAlerts => 'பிராந்திய எச்சரிக்கைகள்';

  @override
  String get alertsHub => 'எச்சரிக்கை மையம்';

  @override
  String get pestAdvisoryTitle => 'பூச்சி அறிவிப்பு: Rice Hispa';

  @override
  String pestAdvisoryDesc(String region) {
    return '$region இல் அதிக ஈரப்பதம் அறிவிக்கப்படுகிறது. இளம் நெல் இலைகளை சோதிக்கவும்.';
  }

  @override
  String get confidence => 'நம்பகத்தன்மை';

  @override
  String get region => 'பகுதி';

  @override
  String get scanCropLeaf => 'பயிர் இலையை ஸ்கேன் செய்யுங்கள்';

  @override
  String get previewLeafPhoto => 'இலை புகைப்படத்தை முன்னோட்டம்';

  @override
  String get analyzingTitle => 'பகுப்பாய்வு';

  @override
  String activeModel(String region) {
    return 'செயலில் உள்ள மாதிரி: $region';
  }

  @override
  String get localFP16Engine => 'உள்ளூர் FP16 இயந்திரம்';

  @override
  String get positionLeaf => 'நெல் இலையை சட்டத்தின் உள்ளே வையுங்கள்';

  @override
  String get chooseFromGallery => 'கேலரியிலிருந்து தேர்ந்தெடுங்கள்';

  @override
  String get retake => 'மீண்டும் எடுங்கள்';

  @override
  String get gallery => 'கேலரி';

  @override
  String get analyzeLeaf => 'இலையை பகுப்பாய்வு செய்யுங்கள்';

  @override
  String get analyzingOnDevice =>
      'உங்கள் சாதனத்தில் பகுப்பாய்வு செய்யப்படுகிறது...';

  @override
  String runningLocalModel(String region) {
    return 'உள்ளூர் $region FP16 மாதிரி இயங்குகிறது';
  }

  @override
  String get offlineAIInference => '100% ஆஃப்லைன் AI பகுப்பாய்வு';

  @override
  String get detectionResult => 'கண்டறிதல் முடிவு';

  @override
  String get highConfidencePrediction =>
      '✓ அதிக நம்பகத்தன்மையுடன் கண்டறியப்பட்டது';

  @override
  String get uncertainPrediction => 'நிச்சயமற்ற கணிப்பு (< 80%)';

  @override
  String get savedForExpertReview =>
      '✓ நிபுணர் மதிப்பாய்வுக்காக சேமிக்கப்பட்டது';

  @override
  String get uncertainDesc =>
      'இந்த கணிப்பு நிச்சயமற்றது மற்றும் நிபுணர் மதிப்பாய்வுக்காக தானாக சேமிக்கப்பட்டது.';

  @override
  String regionLabel(String region) {
    return 'பகுதி: $region';
  }

  @override
  String get modelClassProbabilities => 'மாதிரி முடிவுகள் (உள்ளூர் FP16)';

  @override
  String get helpImproveDiagnosis => 'நோய் கண்டறிதலை மேம்படுத்த உதவுங்கள்';

  @override
  String get isDiagnosisAccurate =>
      'இந்த நோய் கணிப்பு உங்கள் பயிருக்கு சரியானதா?';

  @override
  String get thankyouConfirmed =>
      '✓ நன்றி! நோய் கண்டறிதல் உறுதிப்படுத்தப்பட்டது.';

  @override
  String get confirmed => 'உறுதிப்படுத்தப்பட்டது';

  @override
  String get looksRight => 'சரியாக உள்ளது';

  @override
  String get reviewCorrect => 'மதிப்பாய்வு / திருத்தவும்';

  @override
  String get viewTreatmentGuide => 'சிகிச்சை வழிகாட்டியை காண்க';

  @override
  String get scanAnotherCrop => 'மற்றொரு பயிரை ஸ்கேன் செய்யுங்கள்';

  @override
  String get diagnosisHistory => 'நோய் கண்டறிதல் வரலாறு';

  @override
  String get syncQueue => 'ஒத்திசைக்கவும்';

  @override
  String get filterAll => 'அனைத்தும்';

  @override
  String get filterConfirmed => 'உறுதிப்படுத்தப்பட்டது';

  @override
  String get filterNeedsReview => 'மதிப்பாய்வு தேவை';

  @override
  String get noDiagnosesFound => 'நோய் கண்டறிதல் இல்லை';

  @override
  String get noDiagnosesDesc =>
      'ஸ்கேன் செய்யப்பட்ட பயிர்கள் மற்றும் நிச்சயமற்ற கணிப்புகள் இங்கே தோன்றும்';

  @override
  String get needsReview => 'மதிப்பாய்வு தேவை';

  @override
  String aiPredicted(String disease, String confidence) {
    return 'AI கணிப்பு: $disease ($confidence%)';
  }

  @override
  String get selectCorrectDisease => 'சரியான நோயை தேர்ந்தெடுங்கள்:';

  @override
  String get submitCorrection => 'திருத்தத்தை சமர்பிக்கவும்';

  @override
  String correctedLabelSaved(String disease) {
    return '✓ திருத்தப்பட்ட முத்திரை \"$disease\" என சேமிக்கப்பட்டது';
  }

  @override
  String syncedSamples(int count) {
    return '$count மாதிரி(கள்) வெற்றிகரமாக ஒத்திசைக்கப்பட்டன';
  }

  @override
  String get allSamplesUpToDate =>
      'அனைத்து மாதிரிகளும் புதுப்பித்த நிலையில் உள்ளன';

  @override
  String get sampleRemovedFromQueue => 'மாதிரி வரிசையிலிருந்து அகற்றப்பட்டது';

  @override
  String regionConfTitle(String region) {
    return 'பகுதி: $region';
  }

  @override
  String confLabel(String conf) {
    return 'நம்பகம்: $conf%';
  }

  @override
  String get alertsTitle => 'பிராந்திய எச்சரிக்கைகள் மற்றும் அறிவிப்புகள்';

  @override
  String get catAll => 'அனைத்தும்';

  @override
  String get catPestAlerts => 'பூச்சி எச்சரிக்கைகள்';

  @override
  String get catWeather => 'வானிலை';

  @override
  String get profileSettings => 'விவசாயி சுயவிவரம் & அமைப்புகள்';

  @override
  String get farmerProfile => 'விவசாயி சுயவிவரம்';

  @override
  String get sectionAiEngine => 'AI & ஆஃப்லைன் இயந்திரம்';

  @override
  String get activeAgriculturalRegion => 'செயலில் உள்ள விவசாய பகுதி';

  @override
  String get activeRegionDesc =>
      'உள்ளூர் நோய் காரணிகளுக்கு ஏற்றவாறு சரிசெய்யப்பட்ட பிராந்திய FP16 TFLite மாதிரியை ஏற்றுகிறது.';

  @override
  String get nineRegionalModelsInstalled =>
      '9 பிராந்திய FP16 மாதிரிகள் நிறுவப்பட்டன';

  @override
  String get ready => 'தயாராக உள்ளது';

  @override
  String get sectionInformation => 'தகவல்';

  @override
  String get aboutCropGuard => 'CropGuard பற்றி';

  @override
  String get versionInfo => 'AI நெல் நோய் கண்டறிதல் v1.0.0';

  @override
  String get fieldScanningGuide => 'வயல் ஸ்கேனிங் வழிகாட்டி';

  @override
  String get fieldScanningGuideSub =>
      'சிறந்த கேமரா வெளிச்சம் மற்றும் இலை நிலைப்படுத்தல் குறிப்புகள்';

  @override
  String get fieldScanningTips => 'வயல் ஸ்கேனிங் குறிப்புகள்';

  @override
  String get tip1 => '• இலையை நேரடியாக ஸ்கேன் சட்டத்தின் உள்ளே வையுங்கள்.';

  @override
  String get tip2 => '• போதுமான இயற்கை சூரிய வெளிச்சம் இருக்கட்டும்.';

  @override
  String get tip3 =>
      '• கடுமையான நிழல்கள் அல்லது மிகவும் மங்கலான புகைப்படங்களை தவிர்க்கவும்.';

  @override
  String get tip4 =>
      '• 80% கீழ் நம்பகத்தன்மை கொண்ட கணிப்புகள் தானாக நிபுணர் மதிப்பாய்வுக்காக சேமிக்கப்படும்.';

  @override
  String get gotIt => 'சரி';

  @override
  String activeAIModelSet(String region) {
    return 'AI மாதிரி $region என அமைக்கப்பட்டது';
  }

  @override
  String get cropGuardFooter => 'CropGuard இலங்கை • ஆஃப்லைன்-முதன்மை விவசாய AI';

  @override
  String get sectionLanguage => 'மொழி';

  @override
  String get language => 'மொழி';

  @override
  String get languageSettingDesc => 'உங்கள் விருப்பமான மொழியை தேர்ந்தெடுங்கள்';

  @override
  String get diseaseNameBacterialLeafBlight => 'பாக்டீரியா இலை கருகல்';

  @override
  String get diseaseNameBrownSpot => 'பழுப்பு புள்ளி நோய்';

  @override
  String get diseaseNameHealthyRiceLeaf => 'ஆரோக்கியமான நெல் இலை';

  @override
  String get diseaseNameLeafBlast => 'இலை தீக்காயம்';

  @override
  String get diseaseNameLeafScald => 'இலை வெந்து போதல்';

  @override
  String get diseaseNameNarrowBrownLeafSpot => 'குறுகிய பழுப்பு புள்ளி';

  @override
  String get diseaseNameRiceHispa => 'Rice Hispa';

  @override
  String get diseaseNameSheathBlight => 'Sheath Blight';

  @override
  String get regionCentralHighlands => 'மத்திய மலைநாடு';

  @override
  String get regionUvaZone => 'ஊவா மண்டலம்';

  @override
  String get regionEasternDryZone => 'கிழக்கு வறட்சி மண்டலம்';

  @override
  String get regionNorthCentralDryZone => 'வட மத்திய வறட்சி மண்டலம்';

  @override
  String get regionNorthernDryZone => 'வட வறட்சி மண்டலம்';

  @override
  String get regionNorthwesternIntermediate => 'வடமேற்கு இடைப்பட்ட மண்டலம்';

  @override
  String get regionSabaragamuwaZone => 'சபரகமுவ மண்டலம்';

  @override
  String get regionSouthernWetZone => 'தெற்கு ஈர மண்டலம்';

  @override
  String get regionWesternWetZone => 'மேற்கு ஈர மண்டலம்';
}
