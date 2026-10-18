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
  String get onboardingSubtitle1 => 'நெல் நோய் கண்டறிதல்';

  @override
  String get onboardingDesc1 =>
      'இலங்கையின் விவசாய பகுதிகளுக்கான வழிகாட்டுதலுடன் வயலிலேயே நெல் ஆரோக்கியத்தை சரிபாருங்கள்.';

  @override
  String get onboardingTitle2 => 'உங்கள் பயிரை பரிசோதிக்கவும்';

  @override
  String get onboardingFeature1 =>
      'நேரடி கேமரா அல்லது கேலரியைப் பயன்படுத்துங்கள்';

  @override
  String get onboardingFeature2 => 'இணையம் இல்லாமலும் பயன்படுத்தலாம்';

  @override
  String get onboardingFeature3 => 'வயலிலேயே விரைவான முடிவுகளைப் பெறுங்கள்';

  @override
  String get selectYourRegion => 'உங்கள் பகுதியை தேர்ந்தெடுங்கள்';

  @override
  String get regionSubtitle =>
      'உங்கள் இலங்கை விவசாய பகுதிக்கேற்ற வழிகாட்டுதலை CropGuard அமைக்கும்.';

  @override
  String get fp16LocalModel => 'உங்கள் பகுதிக்கு பரிந்துரைக்கப்பட்டது';

  @override
  String get confirmRegion => 'பகுதியை உறுதிப்படுத்தவும்';

  @override
  String get preparingCropGuard => 'CropGuard தயாராகிறது';

  @override
  String get aiModel => 'பயிர் பராமரிப்பு வழிகாட்டி';

  @override
  String preparingModel(int percent) {
    return 'பயிர் பராமரிப்பு வழிகாட்டி தயாராகிறது... ($percent%)';
  }

  @override
  String get readyForOfflineDetection =>
      '✓ ஆஃப்லைன் கண்டறிதலுக்கு தயாராக உள்ளது';

  @override
  String allSetDesc(String region) {
    return '$region க்கான CropGuard தயாராக உள்ளது. இணையம் இல்லாமலும் பயன்படுத்தலாம்.';
  }

  @override
  String get regionalModelInstalled =>
      'பிராந்திய பயிர் வழிகாட்டி தயாராக உள்ளது';

  @override
  String get offlineEngineReady => 'இணையம் இல்லாமலும் இயங்கும்';

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
      'இணையம் இல்லாமலும் நெல் இலை புகைப்படத்தில் நோய்களைச் சரிபாருங்கள்.';

  @override
  String get startScan => 'ஸ்கேன் ஆரம்பிக்கவும்';

  @override
  String get syncingOfflineSamples => 'உங்கள் அறிக்கைகள் சேமிக்கப்படுகின்றன...';

  @override
  String get offlineAIReady => '● இணையம் இல்லாமலும் பயன்படுத்தத் தயார்';

  @override
  String samplesQueuedForSync(int count) {
    return 'அனுப்ப காத்திருக்கும் அறிக்கைகள்: $count';
  }

  @override
  String get allSamplesSynced =>
      '✓ பயன்படுத்தத் தயார் • அறிக்கைகள் புதுப்பிக்கப்பட்டுள்ளன';

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
    return 'பயிர் வழிகாட்டி: $region';
  }

  @override
  String get localFP16Engine => 'உங்கள் தொலைபேசியில் இயங்கும்';

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
    return '$region க்காக இலையைச் சரிபார்க்கிறது';
  }

  @override
  String get offlineAIInference => 'இணையம் இல்லாமலும் இயங்கும்';

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
  String get modelClassProbabilities => 'சாத்தியமான முடிவுகள்';

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
  String get syncQueue => 'சேமித்த அறிக்கைகள்';

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
    return 'சாத்தியமான முடிவு: $disease ($confidence%)';
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
    return '$count அறிக்கைகள் வெற்றிகரமாக அனுப்பப்பட்டன';
  }

  @override
  String get allSamplesUpToDate =>
      'அனைத்து மாதிரிகளும் புதுப்பித்த நிலையில் உள்ளன';

  @override
  String get sampleRemovedFromQueue => 'அறிக்கை அகற்றப்பட்டது';

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
  String get sectionAiEngine => 'பயிர் பராமரிப்பு';

  @override
  String get activeAgriculturalRegion => 'செயலில் உள்ள விவசாய பகுதி';

  @override
  String get activeRegionDesc =>
      'நீங்கள் தேர்ந்தெடுத்த பகுதிக்கான பயிர் பராமரிப்பு வழிகாட்டுதலைப் பயன்படுத்துகிறது.';

  @override
  String get nineRegionalModelsInstalled =>
      'பிராந்திய பயிர் வழிகாட்டிகள் தயாராக உள்ளன';

  @override
  String get ready => 'தயாராக உள்ளது';

  @override
  String get sectionInformation => 'தகவல்';

  @override
  String get aboutCropGuard => 'CropGuard பற்றி';

  @override
  String get versionInfo => 'நெல் பயிர் பராமரிப்பு v1.0.0';

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
    return 'பயிர் வழிகாட்டி $region என அமைக்கப்பட்டது';
  }

  @override
  String get cropGuardFooter => 'CropGuard இலங்கை • விவசாயிகளுக்காக';

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
