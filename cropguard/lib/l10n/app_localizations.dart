import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'CropGuard'**
  String get appName;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to continue'**
  String get languageSubtitle;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langSinhala.
  ///
  /// In en, this message translates to:
  /// **'සිංහල'**
  String get langSinhala;

  /// No description provided for @langTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get langTamil;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'CropGuard'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Paddy Disease Detection'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Instantly diagnose rice crop diseases in the field using local deep learning models optimized for Sri Lankan agricultural zones.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Crop'**
  String get onboardingTitle2;

  /// No description provided for @onboardingFeature1.
  ///
  /// In en, this message translates to:
  /// **'Use live camera or select from gallery'**
  String get onboardingFeature1;

  /// No description provided for @onboardingFeature2.
  ///
  /// In en, this message translates to:
  /// **'Runs 100% offline — no internet connection required'**
  String get onboardingFeature2;

  /// No description provided for @onboardingFeature3.
  ///
  /// In en, this message translates to:
  /// **'Instant local TFLite FP16 disease classification'**
  String get onboardingFeature3;

  /// No description provided for @selectYourRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Your Region'**
  String get selectYourRegion;

  /// No description provided for @regionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CropGuard automatically selects tuned FP16 AI models based on your Sri Lankan agricultural zone.'**
  String get regionSubtitle;

  /// No description provided for @fp16LocalModel.
  ///
  /// In en, this message translates to:
  /// **'FP16 TFLite Local Model'**
  String get fp16LocalModel;

  /// No description provided for @confirmRegion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Region'**
  String get confirmRegion;

  /// No description provided for @preparingCropGuard.
  ///
  /// In en, this message translates to:
  /// **'Preparing CropGuard'**
  String get preparingCropGuard;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// No description provided for @preparingModel.
  ///
  /// In en, this message translates to:
  /// **'Preparing model for offline use... ({percent}%)'**
  String preparingModel(int percent);

  /// No description provided for @readyForOfflineDetection.
  ///
  /// In en, this message translates to:
  /// **'✓ Ready for Offline Detection'**
  String get readyForOfflineDetection;

  /// No description provided for @allSetDesc.
  ///
  /// In en, this message translates to:
  /// **'FP16 local model loaded for {region}. CropGuard is completely configured for offline field use.'**
  String allSetDesc(String region);

  /// No description provided for @regionalModelInstalled.
  ///
  /// In en, this message translates to:
  /// **'Regional FP16 Model Installed'**
  String get regionalModelInstalled;

  /// No description provided for @offlineEngineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline Inference Engine Ready'**
  String get offlineEngineReady;

  /// No description provided for @regionActive.
  ///
  /// In en, this message translates to:
  /// **'{region} Active'**
  String regionActive(String region);

  /// No description provided for @startUsingCropGuard.
  ///
  /// In en, this message translates to:
  /// **'Start Using CropGuard'**
  String get startUsingCropGuard;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @scanYourCrop.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Crop'**
  String get scanYourCrop;

  /// No description provided for @scanDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect possible diseases from a paddy leaf photo using offline AI.'**
  String get scanDesc;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// No description provided for @syncingOfflineSamples.
  ///
  /// In en, this message translates to:
  /// **'Syncing offline samples...'**
  String get syncingOfflineSamples;

  /// No description provided for @offlineAIReady.
  ///
  /// In en, this message translates to:
  /// **'● Offline AI Ready'**
  String get offlineAIReady;

  /// No description provided for @samplesQueuedForSync.
  ///
  /// In en, this message translates to:
  /// **'{count} sample(s) queued for sync'**
  String samplesQueuedForSync(int count);

  /// No description provided for @allSamplesSynced.
  ///
  /// In en, this message translates to:
  /// **'✓ Offline AI Ready • All samples synced'**
  String get allSamplesSynced;

  /// No description provided for @recentDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Recent Diagnoses'**
  String get recentDiagnoses;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @regionalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Regional Alerts'**
  String get regionalAlerts;

  /// No description provided for @alertsHub.
  ///
  /// In en, this message translates to:
  /// **'Alerts Hub'**
  String get alertsHub;

  /// No description provided for @pestAdvisoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pest Advisory: Rice Hispa Alert'**
  String get pestAdvisoryTitle;

  /// No description provided for @pestAdvisoryDesc.
  ///
  /// In en, this message translates to:
  /// **'High humidity reported in {region}. Check young paddy leaves.'**
  String pestAdvisoryDesc(String region);

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @scanCropLeaf.
  ///
  /// In en, this message translates to:
  /// **'Scan Crop Leaf'**
  String get scanCropLeaf;

  /// No description provided for @previewLeafPhoto.
  ///
  /// In en, this message translates to:
  /// **'Preview Leaf Photo'**
  String get previewLeafPhoto;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get analyzingTitle;

  /// No description provided for @activeModel.
  ///
  /// In en, this message translates to:
  /// **'Active Model: {region}'**
  String activeModel(String region);

  /// No description provided for @localFP16Engine.
  ///
  /// In en, this message translates to:
  /// **'Local FP16 Engine'**
  String get localFP16Engine;

  /// No description provided for @positionLeaf.
  ///
  /// In en, this message translates to:
  /// **'Position the paddy leaf inside the frame'**
  String get positionLeaf;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @analyzeLeaf.
  ///
  /// In en, this message translates to:
  /// **'Analyze Leaf'**
  String get analyzeLeaf;

  /// No description provided for @analyzingOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Analyzing on your device...'**
  String get analyzingOnDevice;

  /// No description provided for @runningLocalModel.
  ///
  /// In en, this message translates to:
  /// **'Running local {region} FP16 model'**
  String runningLocalModel(String region);

  /// No description provided for @offlineAIInference.
  ///
  /// In en, this message translates to:
  /// **'100% Offline AI Inference'**
  String get offlineAIInference;

  /// No description provided for @detectionResult.
  ///
  /// In en, this message translates to:
  /// **'Detection Result'**
  String get detectionResult;

  /// No description provided for @highConfidencePrediction.
  ///
  /// In en, this message translates to:
  /// **'✓ High Confidence Prediction'**
  String get highConfidencePrediction;

  /// No description provided for @uncertainPrediction.
  ///
  /// In en, this message translates to:
  /// **'Uncertain Prediction (< 80%)'**
  String get uncertainPrediction;

  /// No description provided for @savedForExpertReview.
  ///
  /// In en, this message translates to:
  /// **'✓ Saved for Expert Review'**
  String get savedForExpertReview;

  /// No description provided for @uncertainDesc.
  ///
  /// In en, this message translates to:
  /// **'This prediction is uncertain and has been automatically saved for expert review.'**
  String get uncertainDesc;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region: {region}'**
  String regionLabel(String region);

  /// No description provided for @modelClassProbabilities.
  ///
  /// In en, this message translates to:
  /// **'Model Class Probabilities (Local FP16)'**
  String get modelClassProbabilities;

  /// No description provided for @helpImproveDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Help Improve This Diagnosis'**
  String get helpImproveDiagnosis;

  /// No description provided for @isDiagnosisAccurate.
  ///
  /// In en, this message translates to:
  /// **'Is this disease prediction accurate for your crop?'**
  String get isDiagnosisAccurate;

  /// No description provided for @thankyouConfirmed.
  ///
  /// In en, this message translates to:
  /// **'✓ Thank you! Diagnosis confirmed.'**
  String get thankyouConfirmed;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @looksRight.
  ///
  /// In en, this message translates to:
  /// **'Looks Right'**
  String get looksRight;

  /// No description provided for @reviewCorrect.
  ///
  /// In en, this message translates to:
  /// **'Review / Correct'**
  String get reviewCorrect;

  /// No description provided for @viewTreatmentGuide.
  ///
  /// In en, this message translates to:
  /// **'View Treatment Guide'**
  String get viewTreatmentGuide;

  /// No description provided for @scanAnotherCrop.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Crop'**
  String get scanAnotherCrop;

  /// No description provided for @diagnosisHistory.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis History'**
  String get diagnosisHistory;

  /// No description provided for @syncQueue.
  ///
  /// In en, this message translates to:
  /// **'Sync Queue'**
  String get syncQueue;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get filterConfirmed;

  /// No description provided for @filterNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs Review'**
  String get filterNeedsReview;

  /// No description provided for @noDiagnosesFound.
  ///
  /// In en, this message translates to:
  /// **'No diagnoses found'**
  String get noDiagnosesFound;

  /// No description provided for @noDiagnosesDesc.
  ///
  /// In en, this message translates to:
  /// **'Scanned crops and uncertain predictions will appear here'**
  String get noDiagnosesDesc;

  /// No description provided for @needsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs Review'**
  String get needsReview;

  /// No description provided for @aiPredicted.
  ///
  /// In en, this message translates to:
  /// **'AI Predicted: {disease} ({confidence}%)'**
  String aiPredicted(String disease, String confidence);

  /// No description provided for @selectCorrectDisease.
  ///
  /// In en, this message translates to:
  /// **'Select Correct Disease Label:'**
  String get selectCorrectDisease;

  /// No description provided for @submitCorrection.
  ///
  /// In en, this message translates to:
  /// **'Submit Correction'**
  String get submitCorrection;

  /// No description provided for @correctedLabelSaved.
  ///
  /// In en, this message translates to:
  /// **'✓ Corrected label saved as \"{disease}\"'**
  String correctedLabelSaved(String disease);

  /// No description provided for @syncedSamples.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {count} sample(s) with cloud database'**
  String syncedSamples(int count);

  /// No description provided for @allSamplesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All samples up to date (Queue synced or offline)'**
  String get allSamplesUpToDate;

  /// No description provided for @sampleRemovedFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Sample removed from queue'**
  String get sampleRemovedFromQueue;

  /// No description provided for @regionConfTitle.
  ///
  /// In en, this message translates to:
  /// **'Region: {region}'**
  String regionConfTitle(String region);

  /// No description provided for @confLabel.
  ///
  /// In en, this message translates to:
  /// **'Conf: {conf}%'**
  String confLabel(String conf);

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Regional Alerts & Notices'**
  String get alertsTitle;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catPestAlerts.
  ///
  /// In en, this message translates to:
  /// **'Pest Alerts'**
  String get catPestAlerts;

  /// No description provided for @catWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get catWeather;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileSettings;

  /// No description provided for @farmerProfile.
  ///
  /// In en, this message translates to:
  /// **'Farmer Profile'**
  String get farmerProfile;

  /// No description provided for @sectionAiEngine.
  ///
  /// In en, this message translates to:
  /// **'AI & OFFLINE ENGINE'**
  String get sectionAiEngine;

  /// No description provided for @activeAgriculturalRegion.
  ///
  /// In en, this message translates to:
  /// **'Active Agricultural Region'**
  String get activeAgriculturalRegion;

  /// No description provided for @activeRegionDesc.
  ///
  /// In en, this message translates to:
  /// **'Loads regional FP16 TFLite model tuned for local disease factors.'**
  String get activeRegionDesc;

  /// No description provided for @nineRegionalModelsInstalled.
  ///
  /// In en, this message translates to:
  /// **'9 Regional FP16 Models Installed'**
  String get nineRegionalModelsInstalled;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @sectionInformation.
  ///
  /// In en, this message translates to:
  /// **'INFORMATION'**
  String get sectionInformation;

  /// No description provided for @aboutCropGuard.
  ///
  /// In en, this message translates to:
  /// **'About CropGuard'**
  String get aboutCropGuard;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'AI Paddy Disease Detection v1.0.0'**
  String get versionInfo;

  /// No description provided for @fieldScanningGuide.
  ///
  /// In en, this message translates to:
  /// **'Field Scanning Guide'**
  String get fieldScanningGuide;

  /// No description provided for @fieldScanningGuideSub.
  ///
  /// In en, this message translates to:
  /// **'Tips for best camera lighting and leaf positioning'**
  String get fieldScanningGuideSub;

  /// No description provided for @fieldScanningTips.
  ///
  /// In en, this message translates to:
  /// **'Field Scanning Tips'**
  String get fieldScanningTips;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'• Position leaf directly inside the scan frame.'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'• Ensure adequate natural sunlight daylight.'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'• Avoid severe shadows or extremely blurry photos.'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In en, this message translates to:
  /// **'• Predictions under 80% confidence are automatically saved for expert review.'**
  String get tip4;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @activeAIModelSet.
  ///
  /// In en, this message translates to:
  /// **'Active AI Model set to {region}'**
  String activeAIModelSet(String region);

  /// No description provided for @cropGuardFooter.
  ///
  /// In en, this message translates to:
  /// **'CropGuard Sri Lanka • Offline-First Agricultural AI'**
  String get cropGuardFooter;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get sectionLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSettingDesc;

  /// No description provided for @diseaseNameBacterialLeafBlight.
  ///
  /// In en, this message translates to:
  /// **'Bacterial Leaf Blight'**
  String get diseaseNameBacterialLeafBlight;

  /// No description provided for @diseaseNameBrownSpot.
  ///
  /// In en, this message translates to:
  /// **'Brown Spot'**
  String get diseaseNameBrownSpot;

  /// No description provided for @diseaseNameHealthyRiceLeaf.
  ///
  /// In en, this message translates to:
  /// **'Healthy Rice Leaf'**
  String get diseaseNameHealthyRiceLeaf;

  /// No description provided for @diseaseNameLeafBlast.
  ///
  /// In en, this message translates to:
  /// **'Leaf Blast'**
  String get diseaseNameLeafBlast;

  /// No description provided for @diseaseNameLeafScald.
  ///
  /// In en, this message translates to:
  /// **'Leaf Scald'**
  String get diseaseNameLeafScald;

  /// No description provided for @diseaseNameNarrowBrownLeafSpot.
  ///
  /// In en, this message translates to:
  /// **'Narrow Brown Leaf Spot'**
  String get diseaseNameNarrowBrownLeafSpot;

  /// No description provided for @diseaseNameRiceHispa.
  ///
  /// In en, this message translates to:
  /// **'Rice Hispa'**
  String get diseaseNameRiceHispa;

  /// No description provided for @diseaseNameSheathBlight.
  ///
  /// In en, this message translates to:
  /// **'Sheath Blight'**
  String get diseaseNameSheathBlight;

  /// No description provided for @regionCentralHighlands.
  ///
  /// In en, this message translates to:
  /// **'Central Highlands'**
  String get regionCentralHighlands;

  /// No description provided for @regionUvaZone.
  ///
  /// In en, this message translates to:
  /// **'Uva Zone'**
  String get regionUvaZone;

  /// No description provided for @regionEasternDryZone.
  ///
  /// In en, this message translates to:
  /// **'Eastern Dry Zone'**
  String get regionEasternDryZone;

  /// No description provided for @regionNorthCentralDryZone.
  ///
  /// In en, this message translates to:
  /// **'North Central Dry Zone'**
  String get regionNorthCentralDryZone;

  /// No description provided for @regionNorthernDryZone.
  ///
  /// In en, this message translates to:
  /// **'Northern Dry Zone'**
  String get regionNorthernDryZone;

  /// No description provided for @regionNorthwesternIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Northwestern Intermediate'**
  String get regionNorthwesternIntermediate;

  /// No description provided for @regionSabaragamuwaZone.
  ///
  /// In en, this message translates to:
  /// **'Sabaragamuwa Zone'**
  String get regionSabaragamuwaZone;

  /// No description provided for @regionSouthernWetZone.
  ///
  /// In en, this message translates to:
  /// **'Southern Wet Zone'**
  String get regionSouthernWetZone;

  /// No description provided for @regionWesternWetZone.
  ///
  /// In en, this message translates to:
  /// **'Western Wet Zone'**
  String get regionWesternWetZone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
