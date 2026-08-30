// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appName => 'CropGuard';

  @override
  String get continueBtn => 'ඉදිරියට';

  @override
  String get skip => 'මඟ හරින්න';

  @override
  String get getStarted => 'ආරම්භ කරන්න';

  @override
  String get chooseLanguage => 'භාෂාව තෝරන්න';

  @override
  String get languageSubtitle => 'ඉදිරියට යාමට ඔබේ කැමති භාෂාව තෝරන්න';

  @override
  String get langEnglish => 'English';

  @override
  String get langSinhala => 'සිංහල';

  @override
  String get langTamil => 'தமிழ்';

  @override
  String get onboardingTitle1 => 'CropGuard';

  @override
  String get onboardingSubtitle1 => 'AI-Powered ගොයම් රෝග හඳුනාගැනීම';

  @override
  String get onboardingDesc1 =>
      'ශ්‍රී ලාංකීය කෘෂිකාර්මික කලාප සඳහා ගැලපෙන දේශීය AI ආකෘති භාවිතා කරමින් ක්ෂේත්‍රයේදීම ගොයම් රෝග හඳුනාගන්න.';

  @override
  String get onboardingTitle2 => 'ඔබේ වගාව පරීක්ෂා කරන්න';

  @override
  String get onboardingFeature1 => 'සජීවී කැමරාව හෝ ගැලරිය භාවිත කරන්න';

  @override
  String get onboardingFeature2 =>
      '100% Offline — අන්තර්ජාල සම්බන්ධතාවයක් අවශ්‍ය නොවේ';

  @override
  String get onboardingFeature3 => 'ක්ෂණික දේශීය TFLite FP16 රෝග හඳුනාගැනීම';

  @override
  String get selectYourRegion => 'ඔබේ කලාපය තෝරන්න';

  @override
  String get regionSubtitle =>
      'ඔබේ ශ්‍රී ලාංකීය කෘෂිකාර්මික කලාපය අනුව CropGuard ස්වයංක්‍රීයව AI ආකෘතිය තෝරා ගනී.';

  @override
  String get fp16LocalModel => 'FP16 දේශීය AI ආකෘතිය';

  @override
  String get confirmRegion => 'කලාපය තහවුරු කරන්න';

  @override
  String get preparingCropGuard => 'CropGuard සූදානම් කරමින්';

  @override
  String get aiModel => 'AI ආකෘතිය';

  @override
  String preparingModel(int percent) {
    return 'ඔෆ්ලයින් භාවිතය සඳහා ආකෘතිය සූදානම් කරමින්... ($percent%)';
  }

  @override
  String get readyForOfflineDetection => '✓ ඔෆ්ලයින් හඳුනාගැනීමට සූදානම්';

  @override
  String allSetDesc(String region) {
    return '$region සඳහා FP16 දේශීය ආකෘතිය පූරණය විය. CropGuard ඔෆ්ලයින් ක්ෂේත්‍ර භාවිතය සඳහා සම්පූර්ණයෙන් සකසා ඇත.';
  }

  @override
  String get regionalModelInstalled => 'කලාපීය FP16 ආකෘතිය ස්ථාපිත විය';

  @override
  String get offlineEngineReady => 'ඔෆ්ලයින් AI ඇන්ජිම සූදානම්';

  @override
  String regionActive(String region) {
    return '$region සක්‍රියයි';
  }

  @override
  String get startUsingCropGuard => 'CropGuard භාවිත කිරීම ආරම්භ කරන්න';

  @override
  String get navHome => 'මුල් පිටුව';

  @override
  String get navScan => 'ස්කෑන්';

  @override
  String get navHistory => 'ඉතිහාසය';

  @override
  String get navAlerts => 'ඇඟවීම්';

  @override
  String get scanYourCrop => 'ඔබේ වගාව පරීක්ෂා කරන්න';

  @override
  String get scanDesc =>
      'ඔෆ්ලයින් AI භාවිතා කරමින් ගොයම් කොළ ඡායාරූපයෙන් රෝග හඳුනාගන්න.';

  @override
  String get startScan => 'ස්කෑන් කිරීම ආරම්භ කරන්න';

  @override
  String get syncingOfflineSamples => 'ඔෆ්ලයින් සාම්පල සමමුහුර්ත කරමින්...';

  @override
  String get offlineAIReady => '● ඔෆ්ලයින් AI සූදානම්';

  @override
  String samplesQueuedForSync(int count) {
    return 'සාම්පල $countක් සමමුහුර්ත කිරීමට හිඟව ඇත';
  }

  @override
  String get allSamplesSynced =>
      '✓ ඔෆ්ලයින් AI සූදානම් • සියලු සාම්පල සමමුහුර්ත විය';

  @override
  String get recentDiagnoses => 'මෑත රෝග නිර්ණය';

  @override
  String get viewAll => 'සියල්ල බලන්න';

  @override
  String get regionalAlerts => 'කලාපීය ඇඟවීම්';

  @override
  String get alertsHub => 'ඇඟවීම් මධ්‍යස්ථානය';

  @override
  String get pestAdvisoryTitle => 'පළිබෝධ උපදේශය: Rice Hispa';

  @override
  String pestAdvisoryDesc(String region) {
    return '$region හි ඉහළ තෙතමනය වාර්තා වේ. ගොයම් කොළ පරීක්ෂා කරන්න.';
  }

  @override
  String get confidence => 'විශ්වාසනීයත්වය';

  @override
  String get region => 'කලාපය';

  @override
  String get scanCropLeaf => 'ගොයම් කොළ ස්කෑන් කරන්න';

  @override
  String get previewLeafPhoto => 'කොළ ඡායාරූපය පෙරදසුන';

  @override
  String get analyzingTitle => 'විශ්ලේෂණය';

  @override
  String activeModel(String region) {
    return 'සක්‍රිය ආකෘතිය: $region';
  }

  @override
  String get localFP16Engine => 'දේශීය FP16 ඇන්ජිම';

  @override
  String get positionLeaf => 'ගොයම් කොළ රාමුව ඇතුළේ තබන්න';

  @override
  String get chooseFromGallery => 'ගැලරියෙන් තෝරන්න';

  @override
  String get retake => 'නැවත ගන්න';

  @override
  String get gallery => 'ගැලරිය';

  @override
  String get analyzeLeaf => 'කොළ විශ්ලේෂණය කරන්න';

  @override
  String get analyzingOnDevice => 'ඔබගේ දුරකථනය තුළ විශ්ලේෂණය කරමින් පවතී...';

  @override
  String runningLocalModel(String region) {
    return 'දේශීය $region FP16 ආකෘතිය ක්‍රියාත්මක කරමින්';
  }

  @override
  String get offlineAIInference => '100% ඔෆ්ලයින් AI විශ්ලේෂණය';

  @override
  String get detectionResult => 'හඳුනාගැනීමේ ප්‍රතිඵලය';

  @override
  String get highConfidencePrediction => '✓ ඉහළ විශ්වාසනීයත්වයෙන් හඳුනාගෙන ඇත';

  @override
  String get uncertainPrediction => 'අවිනිශ්චිත අනාවැකිය (< 80%)';

  @override
  String get savedForExpertReview => '✓ විශේෂඥ පරීක්ෂාව සඳහා සුරකිනා ලදී';

  @override
  String get uncertainDesc =>
      'මෙම අනාවැකිය අවිනිශ්චිත වන අතර විශේෂඥ සමාලෝචනය සඳහා ස්වයංක්‍රීයව සුරකිනා ඇත.';

  @override
  String regionLabel(String region) {
    return 'කලාපය: $region';
  }

  @override
  String get modelClassProbabilities => 'ආකෘති ප්‍රතිඵල (දේශීය FP16)';

  @override
  String get helpImproveDiagnosis => 'රෝග නිර්ණය වැඩිදියුණු කිරීමට සහාය වන්න';

  @override
  String get isDiagnosisAccurate => 'මෙම රෝග අනාවැකිය ඔබේ වගාවට නිවැරදිද?';

  @override
  String get thankyouConfirmed => '✓ ස්තූතියි! රෝග නිර්ණය තහවුරු කරන ලදී.';

  @override
  String get confirmed => 'තහවුරු විය';

  @override
  String get looksRight => 'නිවැරදියි';

  @override
  String get reviewCorrect => 'සමාලෝචනය / නිවැරදි කරන්න';

  @override
  String get viewTreatmentGuide => 'ප්‍රතිකාර මාර්ගෝපදේශය බලන්න';

  @override
  String get scanAnotherCrop => 'තවත් වගාවක් ස්කෑන් කරන්න';

  @override
  String get diagnosisHistory => 'රෝග නිර්ණය ඉතිහාසය';

  @override
  String get syncQueue => 'සමමුහුර්ත කරන්න';

  @override
  String get filterAll => 'සියල්ල';

  @override
  String get filterConfirmed => 'තහවුරු';

  @override
  String get filterNeedsReview => 'සමාලෝචනය අවශ්‍යයි';

  @override
  String get noDiagnosesFound => 'රෝග නිර්ණය හමු නොවිණි';

  @override
  String get noDiagnosesDesc =>
      'ස්කෑන් කළ වගා සහ අවිනිශ්චිත අනාවැකි මෙහි දිස්වනු ඇත';

  @override
  String get needsReview => 'සමාලෝචනය අවශ්‍යයි';

  @override
  String aiPredicted(String disease, String confidence) {
    return 'AI අනාවැකිය: $disease ($confidence%)';
  }

  @override
  String get selectCorrectDisease => 'නිවැරදි රෝගය තෝරන්න:';

  @override
  String get submitCorrection => 'නිවැරදිය ඉදිරිපත් කරන්න';

  @override
  String correctedLabelSaved(String disease) {
    return '✓ නිවැරදි ලේබලය \"$disease\" ලෙස සුරකිනා ලදී';
  }

  @override
  String syncedSamples(int count) {
    return 'සාම්පල $countක් සාර්ථකව සමමුහුර්ත කරන ලදී';
  }

  @override
  String get allSamplesUpToDate =>
      'සියලු සාම්පල යාවත්කාලීනයි (ඔෆ්ලයින් සතොස හිඟ නැත)';

  @override
  String get sampleRemovedFromQueue => 'සාම්පලය ගොනුවෙන් ඉවත් කරන ලදී';

  @override
  String regionConfTitle(String region) {
    return 'කලාපය: $region';
  }

  @override
  String confLabel(String conf) {
    return 'විශ්වාසය: $conf%';
  }

  @override
  String get alertsTitle => 'කලාපීය ඇඟවීම් සහ දැනුම්දීම්';

  @override
  String get catAll => 'සියල්ල';

  @override
  String get catPestAlerts => 'පළිබෝධ ඇඟවීම්';

  @override
  String get catWeather => 'කාලගුණය';

  @override
  String get profileSettings => 'ගොවි ව්‍යාපෘතිය සහ සැකසීම්';

  @override
  String get farmerProfile => 'ගොවි ව්‍යාපෘතිය';

  @override
  String get sectionAiEngine => 'AI සහ ඔෆ්ලයින් ඇන්ජිම';

  @override
  String get activeAgriculturalRegion => 'සක්‍රිය කෘෂිකාර්මික කලාපය';

  @override
  String get activeRegionDesc =>
      'දේශීය රෝග සාධක සඳහා ගැළපෙන කලාපීය FP16 TFLite ආකෘතිය පූරණය කරයි.';

  @override
  String get nineRegionalModelsInstalled => 'කලාපීය FP16 ආකෘති 9 ස්ථාපිත';

  @override
  String get ready => 'සූදානම්';

  @override
  String get sectionInformation => 'තොරතුරු';

  @override
  String get aboutCropGuard => 'CropGuard ගැන';

  @override
  String get versionInfo => 'AI ගොයම් රෝග හඳුනාගැනීම v1.0.0';

  @override
  String get fieldScanningGuide => 'ක්ෂේත්‍ර ස්කෑනිං මාර්ගෝපදේශය';

  @override
  String get fieldScanningGuideSub =>
      'හොඳම කැමරා ආලෝකය සහ කොළ ස්ථානගත කිරීම සඳහා උපදෙස්';

  @override
  String get fieldScanningTips => 'ක්ෂේත්‍ර ස්කෑනිං ඉඟි';

  @override
  String get tip1 => '• කොළ ස්කෑන් රාමුව ඇතුළේ කෙලින් තබන්න.';

  @override
  String get tip2 => '• ප්‍රමාණවත් ස්වාභාවික සූර්යයාලෝකය සහතික කරන්න.';

  @override
  String get tip3 => '• දැඩි සෙවනැලි හෝ නොපැහැදිළි ඡායාරූප වළකින්න.';

  @override
  String get tip4 =>
      '• 80%ට අඩු විශ්වාසනීයත්වයෙන් ඇති අනාවැකි ස්වයංක්‍රීයව විශේෂඥ සමාලෝචනය සඳහා සුරකිනා ඇත.';

  @override
  String get gotIt => 'හරි';

  @override
  String activeAIModelSet(String region) {
    return 'AI ආකෘතිය $region ලෙස සකසන ලදී';
  }

  @override
  String get cropGuardFooter =>
      'CropGuard ශ්‍රී ලංකා • ඔෆ්ලයින්-ප්‍රථම කෘෂිකාර්මික AI';

  @override
  String get sectionLanguage => 'භාෂාව';

  @override
  String get language => 'භාෂාව';

  @override
  String get languageSettingDesc => 'ඔබේ කැමති භාෂාව තෝරන්න';

  @override
  String get diseaseNameBacterialLeafBlight => 'කොළ ස්කෝල්ලී රෝගය';

  @override
  String get diseaseNameBrownSpot => 'දුඹුරු ලප රෝගය';

  @override
  String get diseaseNameHealthyRiceLeaf => 'සෞඛ්‍ය සම්පන්න ගොයම් කොළ';

  @override
  String get diseaseNameLeafBlast => 'කොළ පිළිස්සීම';

  @override
  String get diseaseNameLeafScald => 'කොළ දාහය';

  @override
  String get diseaseNameNarrowBrownLeafSpot => 'පටු දුඹුරු ලප';

  @override
  String get diseaseNameRiceHispa => 'Rice Hispa';

  @override
  String get diseaseNameSheathBlight => 'Sheath Blight';

  @override
  String get regionCentralHighlands => 'මධ්‍යම කදුකරය';

  @override
  String get regionUvaZone => 'ඌව කලාපය';

  @override
  String get regionEasternDryZone => 'නැගෙනහිර වියළි කලාපය';

  @override
  String get regionNorthCentralDryZone => 'උතුරු මධ්‍යම වියළි කලාපය';

  @override
  String get regionNorthernDryZone => 'උතුරු වියළි කලාපය';

  @override
  String get regionNorthwesternIntermediate => 'වයඹ අතරමැදි කලාපය';

  @override
  String get regionSabaragamuwaZone => 'සබරගමු කලාපය';

  @override
  String get regionSouthernWetZone => 'දකුණු තෙත් කලාපය';

  @override
  String get regionWesternWetZone => 'බස්නාහිර තෙත් කලාපය';
}
