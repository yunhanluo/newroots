import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('ko'),
    Locale('tl'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'NewRoots'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'From arrival to belonging.'**
  String get tagline;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NewRoots'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thrive in America.'**
  String get welcomeSubtitle;

  /// No description provided for @landingPurpose.
  ///
  /// In en, this message translates to:
  /// **'Find trusted local help and take the next step—in your language.'**
  String get landingPurpose;

  /// No description provided for @welcomePurpose.
  ///
  /// In en, this message translates to:
  /// **'NewRoots is an app for immigrants in California, created for the 2026 Congressional App Challenge. It helps you find trusted local help and take the next step—all in your preferred language.'**
  String get welcomePurpose;

  /// No description provided for @welcomeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get welcomeContinue;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get welcomeDone;

  /// No description provided for @welcomeFeatureRoadmap.
  ///
  /// In en, this message translates to:
  /// **'A personal plan for your first months here.'**
  String get welcomeFeatureRoadmap;

  /// No description provided for @welcomeFeatureCareer.
  ///
  /// In en, this message translates to:
  /// **'Match your work experience to jobs in the US.'**
  String get welcomeFeatureCareer;

  /// No description provided for @welcomeFeatureHousing.
  ///
  /// In en, this message translates to:
  /// **'Understand renting and find housing help.'**
  String get welcomeFeatureHousing;

  /// No description provided for @welcomeFeatureHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Learn how healthcare works and find nearby clinics.'**
  String get welcomeFeatureHealthcare;

  /// No description provided for @welcomeFeatureSafety.
  ///
  /// In en, this message translates to:
  /// **'A guide on what to do in an emergency or disaster.'**
  String get welcomeFeatureSafety;

  /// No description provided for @welcomeFeatureScamShield.
  ///
  /// In en, this message translates to:
  /// **'Check a message or ad that might be a scam.'**
  String get welcomeFeatureScamShield;

  /// No description provided for @welcomeFeatureEnglish.
  ///
  /// In en, this message translates to:
  /// **'Find English classes near you.'**
  String get welcomeFeatureEnglish;

  /// No description provided for @welcomeFeatureEducation.
  ///
  /// In en, this message translates to:
  /// **'Find schools and programs for your family.'**
  String get welcomeFeatureEducation;

  /// No description provided for @welcomeFeatureSupportGroups.
  ///
  /// In en, this message translates to:
  /// **'Talk with other newcomers in California.'**
  String get welcomeFeatureSupportGroups;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navScamShield.
  ///
  /// In en, this message translates to:
  /// **'ScamShield'**
  String get navScamShield;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @featureRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Integration Roadmap'**
  String get featureRoadmap;

  /// No description provided for @featureHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get featureHousing;

  /// No description provided for @featureCareer.
  ///
  /// In en, this message translates to:
  /// **'Career Bridge'**
  String get featureCareer;

  /// No description provided for @featureEnglish.
  ///
  /// In en, this message translates to:
  /// **'English Learning'**
  String get featureEnglish;

  /// No description provided for @featureEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get featureEducation;

  /// No description provided for @featureHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get featureHealthcare;

  /// No description provided for @featureSupportGroups.
  ///
  /// In en, this message translates to:
  /// **'Support Groups'**
  String get featureSupportGroups;

  /// No description provided for @featureScamShield.
  ///
  /// In en, this message translates to:
  /// **'ScamShield'**
  String get featureScamShield;

  /// No description provided for @featureSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety Guide'**
  String get featureSafety;

  /// Generic placeholder for unbuilt screens
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get placeholderComingSoon;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'NewRoots is a navigation tool, not a substitute for legal, medical, or financial professionals.'**
  String get disclaimer;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {label}'**
  String actionEdit(String label);

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get actionLogIn;

  /// No description provided for @actionSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get actionSignUp;

  /// No description provided for @actionCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get actionCreateAccount;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get actionPrevious;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get actionFinish;

  /// No description provided for @actionSkipQuestion.
  ///
  /// In en, this message translates to:
  /// **'Skip question'**
  String get actionSkipQuestion;

  /// No description provided for @actionSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get actionSkipForNow;

  /// No description provided for @actionContinueSurvey.
  ///
  /// In en, this message translates to:
  /// **'Continue survey'**
  String get actionContinueSurvey;

  /// No description provided for @actionStartSurvey.
  ///
  /// In en, this message translates to:
  /// **'Start Survey'**
  String get actionStartSurvey;

  /// No description provided for @actionSkipSurvey.
  ///
  /// In en, this message translates to:
  /// **'Skip Survey'**
  String get actionSkipSurvey;

  /// No description provided for @actionTakeSurvey.
  ///
  /// In en, this message translates to:
  /// **'Take Survey'**
  String get actionTakeSurvey;

  /// No description provided for @actionRetakeSurvey.
  ///
  /// In en, this message translates to:
  /// **'Retake Survey'**
  String get actionRetakeSurvey;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Log in to continue.'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started.'**
  String get authCreateAccountSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authEmailPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get authEmailPasswordRequired;

  /// No description provided for @authFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get authFillAllFields;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authPasswordTooShort;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get preferredLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @editPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Edit preferred language'**
  String get editPreferredLanguage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedIn;

  /// No description provided for @profileLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocation;

  /// No description provided for @profileChildrenCount.
  ///
  /// In en, this message translates to:
  /// **'How many children'**
  String get profileChildrenCount;

  /// No description provided for @profilePriorities.
  ///
  /// In en, this message translates to:
  /// **'Top priorities'**
  String get profilePriorities;

  /// No description provided for @profileEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment background'**
  String get profileEmployment;

  /// No description provided for @profileChildrenAges.
  ///
  /// In en, this message translates to:
  /// **'Children ages'**
  String get profileChildrenAges;

  /// No description provided for @profileSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get profileSkipped;

  /// No description provided for @profileNoSurvey.
  ///
  /// In en, this message translates to:
  /// **'No survey data yet.'**
  String get profileNoSurvey;

  /// No description provided for @profileReviewSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Review group suggestions'**
  String get profileReviewSuggestions;

  /// No description provided for @profileAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileAdmin;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// No description provided for @priorityHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get priorityHousing;

  /// No description provided for @priorityEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get priorityEmployment;

  /// No description provided for @priorityEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get priorityEducation;

  /// No description provided for @priorityHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get priorityHealthcare;

  /// No description provided for @priorityEnglish.
  ///
  /// In en, this message translates to:
  /// **'English learning'**
  String get priorityEnglish;

  /// No description provided for @prioritySafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get prioritySafety;

  /// No description provided for @priorityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get priorityOther;

  /// No description provided for @priorityOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your priority'**
  String get priorityOtherHint;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Survey'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a quick survey for personalization.'**
  String get onboardingIntro;

  /// No description provided for @onboardingSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip onboarding survey?'**
  String get onboardingSkipTitle;

  /// No description provided for @onboardingSkipBody.
  ///
  /// In en, this message translates to:
  /// **'Taking the survey lets us understand your situation and design solutions (individual questions can be skipped).'**
  String get onboardingSkipBody;

  /// No description provided for @onboardingSurveyLater.
  ///
  /// In en, this message translates to:
  /// **'The survey can be taken at any time on the profile page.'**
  String get onboardingSurveyLater;

  /// No description provided for @onboardingQuestionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get onboardingQuestionLanguage;

  /// No description provided for @onboardingQuestionLocation.
  ///
  /// In en, this message translates to:
  /// **'Where are you located?'**
  String get onboardingQuestionLocation;

  /// No description provided for @onboardingQuestionChildren.
  ///
  /// In en, this message translates to:
  /// **'How many children?'**
  String get onboardingQuestionChildren;

  /// No description provided for @onboardingQuestionPriorities.
  ///
  /// In en, this message translates to:
  /// **'Top priorities right now'**
  String get onboardingQuestionPriorities;

  /// No description provided for @onboardingQuestionEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment background'**
  String get onboardingQuestionEmployment;

  /// No description provided for @onboardingQuestionAges.
  ///
  /// In en, this message translates to:
  /// **'Children ages'**
  String get onboardingQuestionAges;

  /// No description provided for @onboardingSelectChildren.
  ///
  /// In en, this message translates to:
  /// **'Select number of children'**
  String get onboardingSelectChildren;

  /// No description provided for @onboardingCityOrZip.
  ///
  /// In en, this message translates to:
  /// **'City or ZIP code'**
  String get onboardingCityOrZip;

  /// No description provided for @scamIntro.
  ///
  /// In en, this message translates to:
  /// **'Check suspicious messages, emails, job offers, rental ads, and government-related content. ScamShield explains why something may be risky so you can decide what to do next.'**
  String get scamIntro;

  /// No description provided for @scamWhatChecking.
  ///
  /// In en, this message translates to:
  /// **'What are you checking?'**
  String get scamWhatChecking;

  /// No description provided for @scamPasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste the message or listing'**
  String get scamPasteLabel;

  /// No description provided for @scamPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the full text here…'**
  String get scamPasteHint;

  /// No description provided for @scamAddScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Add screenshot'**
  String get scamAddScreenshot;

  /// No description provided for @scamAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze for scam risk'**
  String get scamAnalyze;

  /// No description provided for @scamPastChecks.
  ///
  /// In en, this message translates to:
  /// **'Past checks'**
  String get scamPastChecks;

  /// No description provided for @scamDropHint.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop a screenshot here'**
  String get scamDropHint;

  /// No description provided for @scamBrowseHint.
  ///
  /// In en, this message translates to:
  /// **'or click to browse'**
  String get scamBrowseHint;

  /// No description provided for @scamReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get scamReplace;

  /// No description provided for @scamRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get scamRemove;

  /// No description provided for @scamPastLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load past checks right now.'**
  String get scamPastLoadError;

  /// No description provided for @scamPastEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past checks yet. Analyze a message to save one here.'**
  String get scamPastEmpty;

  /// No description provided for @scamScreenshotCheck.
  ///
  /// In en, this message translates to:
  /// **'Screenshot check'**
  String get scamScreenshotCheck;

  /// No description provided for @scamDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get scamDelete;

  /// No description provided for @scamDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this check?'**
  String get scamDeleteTitle;

  /// No description provided for @scamDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the saved report from your past checks.'**
  String get scamDeleteBody;

  /// No description provided for @scamNeedInput.
  ///
  /// In en, this message translates to:
  /// **'Paste a message or add a screenshot to analyze.'**
  String get scamNeedInput;

  /// No description provided for @scamImageOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open that image. Try another photo.'**
  String get scamImageOpenError;

  /// No description provided for @scamDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete that check. Try again.'**
  String get scamDeleteError;

  /// No description provided for @scamChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scamChooseGallery;

  /// No description provided for @scamTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get scamTakePhoto;

  /// No description provided for @scamScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get scamScreenshot;

  /// No description provided for @scamRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get scamRiskLow;

  /// No description provided for @scamRiskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get scamRiskModerate;

  /// No description provided for @scamRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get scamRiskHigh;

  /// No description provided for @scamYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get scamYesterday;

  /// No description provided for @scamDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String scamDaysAgo(int count);

  /// No description provided for @scamCategorySms.
  ///
  /// In en, this message translates to:
  /// **'Text message'**
  String get scamCategorySms;

  /// No description provided for @scamCategoryEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get scamCategoryEmail;

  /// No description provided for @scamCategoryJob.
  ///
  /// In en, this message translates to:
  /// **'Job offer'**
  String get scamCategoryJob;

  /// No description provided for @scamCategoryRental.
  ///
  /// In en, this message translates to:
  /// **'Rental ad'**
  String get scamCategoryRental;

  /// No description provided for @scamCategoryGovernment.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get scamCategoryGovernment;

  /// No description provided for @scamUpdatedFrom.
  ///
  /// In en, this message translates to:
  /// **'Updated from {level}'**
  String scamUpdatedFrom(String level);

  /// No description provided for @scamWhatYouSubmitted.
  ///
  /// In en, this message translates to:
  /// **'What you submitted'**
  String get scamWhatYouSubmitted;

  /// No description provided for @scamExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get scamExpand;

  /// No description provided for @scamCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get scamCollapse;

  /// No description provided for @scamMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get scamMessage;

  /// No description provided for @scamMessageNumber.
  ///
  /// In en, this message translates to:
  /// **'Message {number}'**
  String scamMessageNumber(int number);

  /// No description provided for @scamWhyRisky.
  ///
  /// In en, this message translates to:
  /// **'Why this may be risky'**
  String get scamWhyRisky;

  /// No description provided for @scamWhatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get scamWhatYouCanDo;

  /// No description provided for @scamAddMessage.
  ///
  /// In en, this message translates to:
  /// **'Add message'**
  String get scamAddMessage;

  /// No description provided for @scamFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a follow-up from the conversation'**
  String get scamFollowUpTitle;

  /// No description provided for @scamFollowUpHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the next text or email…'**
  String get scamFollowUpHint;

  /// No description provided for @scamReevaluate.
  ///
  /// In en, this message translates to:
  /// **'Reevaluate'**
  String get scamReevaluate;

  /// No description provided for @scamFollowUpNeedInput.
  ///
  /// In en, this message translates to:
  /// **'Paste a follow-up message or add a screenshot.'**
  String get scamFollowUpNeedInput;

  /// No description provided for @scamFollowUpImageError.
  ///
  /// In en, this message translates to:
  /// **'Could not open that image.'**
  String get scamFollowUpImageError;

  /// No description provided for @scamScreenshotAttached.
  ///
  /// In en, this message translates to:
  /// **'Screenshot attached'**
  String get scamScreenshotAttached;

  /// No description provided for @scamThreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages in this thread'**
  String scamThreadCount(int count);

  /// No description provided for @actionSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get actionSend;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @followupAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get followupAsk;

  /// No description provided for @followupSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get followupSaveNote;

  /// No description provided for @followupDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get followupDeleteNote;

  /// No description provided for @followupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Q: {question}'**
  String followupQuestion(String question);

  /// No description provided for @careerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to explore career pathways.'**
  String get careerSignIn;

  /// No description provided for @careerAddPriorJob.
  ///
  /// In en, this message translates to:
  /// **'Add your prior job in your profile survey, or describe your background in the notes below.'**
  String get careerAddPriorJob;

  /// No description provided for @careerGoToProfile.
  ///
  /// In en, this message translates to:
  /// **'Go to profile'**
  String get careerGoToProfile;

  /// No description provided for @careerPriorEmployment.
  ///
  /// In en, this message translates to:
  /// **'Prior employment (from your survey)'**
  String get careerPriorEmployment;

  /// No description provided for @careerAdditionalBackground.
  ///
  /// In en, this message translates to:
  /// **'Additional background'**
  String get careerAdditionalBackground;

  /// No description provided for @careerAdditionalBackgroundHelp.
  ///
  /// In en, this message translates to:
  /// **'Skills, education, certifications, languages, or career goals that will help the AI suggest better paths.'**
  String get careerAdditionalBackgroundHelp;

  /// No description provided for @careerAdditionalBackgroundHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5 years as an electrician, vocational diploma, interested in solar installation…'**
  String get careerAdditionalBackgroundHint;

  /// No description provided for @careerGenerateAll.
  ///
  /// In en, this message translates to:
  /// **'Generate career paths'**
  String get careerGenerateAll;

  /// No description provided for @careerRegenerateAll.
  ///
  /// In en, this message translates to:
  /// **'Regenerate all paths'**
  String get careerRegenerateAll;

  /// No description provided for @careerGenerating.
  ///
  /// In en, this message translates to:
  /// **'Mapping career pathways…'**
  String get careerGenerating;

  /// No description provided for @careerNeedBackground.
  ///
  /// In en, this message translates to:
  /// **'Add notes about your skills or education first.'**
  String get careerNeedBackground;

  /// No description provided for @careerCouldNotSaveChecklist.
  ///
  /// In en, this message translates to:
  /// **'Could not save checklist progress.'**
  String get careerCouldNotSaveChecklist;

  /// No description provided for @careerCouldNotSaveStep.
  ///
  /// In en, this message translates to:
  /// **'Could not save step progress.'**
  String get careerCouldNotSaveStep;

  /// No description provided for @careerCouldNotSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Could not save note.'**
  String get careerCouldNotSaveNote;

  /// No description provided for @careerCouldNotDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Could not delete that note.'**
  String get careerCouldNotDeleteNote;

  /// No description provided for @careerDeleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get careerDeleteNoteTitle;

  /// No description provided for @careerDeleteNoteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the note from this career path.'**
  String get careerDeleteNoteBody;

  /// No description provided for @careerGeneratePathTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate this path?'**
  String get careerGeneratePathTitle;

  /// No description provided for @careerRegeneratePathTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate this path?'**
  String get careerRegeneratePathTitle;

  /// No description provided for @careerGeneratePathBody.
  ///
  /// In en, this message translates to:
  /// **'Create an AI-generated career path for Path {number}. Your other paths and notes are kept.'**
  String careerGeneratePathBody(int number);

  /// No description provided for @careerRegeneratePathBody.
  ///
  /// In en, this message translates to:
  /// **'Replace \"{title}\" with a new AI-generated career path. Your other paths and notes are kept.'**
  String careerRegeneratePathBody(String title);

  /// No description provided for @careerGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get careerGenerate;

  /// No description provided for @careerRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get careerRegenerate;

  /// No description provided for @careerPathNumber.
  ///
  /// In en, this message translates to:
  /// **'Path {number}'**
  String careerPathNumber(int number);

  /// No description provided for @careerPathHeading.
  ///
  /// In en, this message translates to:
  /// **'Path {number}: {title}'**
  String careerPathHeading(int number, String title);

  /// No description provided for @careerPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'A career pathway will appear here once generated.'**
  String get careerPlaceholderBody;

  /// No description provided for @careerPlaceholderStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting point'**
  String get careerPlaceholderStartTitle;

  /// No description provided for @careerPlaceholderStartBody.
  ///
  /// In en, this message translates to:
  /// **'Your current experience and background.'**
  String get careerPlaceholderStartBody;

  /// No description provided for @careerPlaceholderCredsTitle.
  ///
  /// In en, this message translates to:
  /// **'Build credentials'**
  String get careerPlaceholderCredsTitle;

  /// No description provided for @careerPlaceholderCredsBody.
  ///
  /// In en, this message translates to:
  /// **'Licenses, training, and skills to develop.'**
  String get careerPlaceholderCredsBody;

  /// No description provided for @careerPlaceholderTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Target role'**
  String get careerPlaceholderTargetTitle;

  /// No description provided for @careerPlaceholderTargetBody.
  ///
  /// In en, this message translates to:
  /// **'Your future career goal in the US.'**
  String get careerPlaceholderTargetBody;

  /// No description provided for @careerCertifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications & licenses'**
  String get careerCertifications;

  /// No description provided for @careerSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills to develop'**
  String get careerSkills;

  /// No description provided for @careerTimeEstimate.
  ///
  /// In en, this message translates to:
  /// **'Time Estimate'**
  String get careerTimeEstimate;

  /// No description provided for @careerStepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get careerStepCompleted;

  /// No description provided for @careerStepNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get careerStepNow;

  /// No description provided for @careerStepNowWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Now ({duration})'**
  String careerStepNowWithDuration(String duration);

  /// No description provided for @careerTimePending.
  ///
  /// In en, this message translates to:
  /// **'Time estimate pending'**
  String get careerTimePending;

  /// No description provided for @careerUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get careerUndo;

  /// No description provided for @careerMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get careerMarkComplete;

  /// No description provided for @careerFinishStepAbove.
  ///
  /// In en, this message translates to:
  /// **'Finish the step above first.'**
  String get careerFinishStepAbove;

  /// No description provided for @careerUndoLaterStep.
  ///
  /// In en, this message translates to:
  /// **'Undo the later step first.'**
  String get careerUndoLaterStep;

  /// No description provided for @careerAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about this path'**
  String get careerAskTitle;

  /// No description provided for @careerAskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions use this path\'s steps, notes, and your background. Answers stay on this page until you leave. Save anything you want to keep as a note.'**
  String get careerAskSubtitle;

  /// No description provided for @careerAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about a step, license, or how to get started…'**
  String get careerAskHint;

  /// No description provided for @careerNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes for this path'**
  String get careerNotesTitle;

  /// No description provided for @careerNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track progress on this pathway. Saved and shared with the AI.'**
  String get careerNotesSubtitle;

  /// No description provided for @careerNotesHint.
  ///
  /// In en, this message translates to:
  /// **'What have you done for this path?'**
  String get careerNotesHint;

  /// No description provided for @roadmapSettlementPlan.
  ///
  /// In en, this message translates to:
  /// **'Your settlement plan based on your survey answers.'**
  String get roadmapSettlementPlan;

  /// No description provided for @roadmapRegenerateAll.
  ///
  /// In en, this message translates to:
  /// **'Regenerate all'**
  String get roadmapRegenerateAll;

  /// No description provided for @roadmapRegenerateAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate entire roadmap?'**
  String get roadmapRegenerateAllTitle;

  /// No description provided for @roadmapRegenerateAllBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces all three sections with a fresh AI plan. Your section notes are kept.'**
  String get roadmapRegenerateAllBody;

  /// No description provided for @roadmapCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating your personalized roadmap…'**
  String get roadmapCreating;

  /// No description provided for @roadmapAnswerQuestions.
  ///
  /// In en, this message translates to:
  /// **'Answer the questions below so we can finish your roadmap.'**
  String get roadmapAnswerQuestions;

  /// No description provided for @roadmapUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating your roadmap…'**
  String get roadmapUpdating;

  /// No description provided for @roadmapGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Roadmap'**
  String get roadmapGenerate;

  /// No description provided for @roadmapNoRoadmap.
  ///
  /// In en, this message translates to:
  /// **'No roadmap yet. Tap below to generate one from your survey.'**
  String get roadmapNoRoadmap;

  /// No description provided for @roadmapEmptySurvey.
  ///
  /// In en, this message translates to:
  /// **'Take the onboarding survey so we can build a personalized roadmap.'**
  String get roadmapEmptySurvey;

  /// No description provided for @roadmapRegenerateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate {section}?'**
  String roadmapRegenerateSectionTitle(String section);

  /// No description provided for @roadmapRegenerateSectionBody.
  ///
  /// In en, this message translates to:
  /// **'This section will be replaced with a new AI-generated plan. Your notes for this section are kept.'**
  String get roadmapRegenerateSectionBody;

  /// No description provided for @roadmapAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about this section'**
  String get roadmapAskTitle;

  /// No description provided for @roadmapAskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions use this section\'s checklist, notes, and your survey. Answers stay on this page until you leave. Save anything you want to keep as a note.'**
  String get roadmapAskSubtitle;

  /// No description provided for @roadmapAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about a step in this section…'**
  String get roadmapAskHint;

  /// No description provided for @roadmapNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes for this section'**
  String get roadmapNotesTitle;

  /// No description provided for @roadmapNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track progress on these steps. Saved and shared with the AI.'**
  String get roadmapNotesSubtitle;

  /// No description provided for @roadmapNotesHint.
  ///
  /// In en, this message translates to:
  /// **'What have you done for this section?'**
  String get roadmapNotesHint;

  /// No description provided for @roadmapNoChecklist.
  ///
  /// In en, this message translates to:
  /// **'No checklist items yet.'**
  String get roadmapNoChecklist;

  /// No description provided for @roadmapCouldNotSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Could not save note.'**
  String get roadmapCouldNotSaveNote;

  /// No description provided for @roadmapCouldNotDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Could not delete that note.'**
  String get roadmapCouldNotDeleteNote;

  /// No description provided for @roadmapDeleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get roadmapDeleteNoteTitle;

  /// No description provided for @roadmapDeleteNoteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the note from this section.'**
  String get roadmapDeleteNoteBody;

  /// No description provided for @roadmapAiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI service is unavailable.'**
  String get roadmapAiUnavailable;

  /// No description provided for @roadmapAiCouldNotAnswer.
  ///
  /// In en, this message translates to:
  /// **'AI could not answer.'**
  String get roadmapAiCouldNotAnswer;

  /// No description provided for @roadmapSectionFirstMonth.
  ///
  /// In en, this message translates to:
  /// **'First Month'**
  String get roadmapSectionFirstMonth;

  /// No description provided for @roadmapSectionFirstThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'First 3 Months'**
  String get roadmapSectionFirstThreeMonths;

  /// No description provided for @roadmapSectionFirstYear.
  ///
  /// In en, this message translates to:
  /// **'First Year'**
  String get roadmapSectionFirstYear;

  /// No description provided for @roadmapQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String roadmapQuestionOf(int current, int total);

  /// No description provided for @roadmapOneQuestion.
  ///
  /// In en, this message translates to:
  /// **'One quick question'**
  String get roadmapOneQuestion;

  /// No description provided for @roadmapUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next: {question}'**
  String roadmapUpNext(String question);

  /// No description provided for @roadmapYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get roadmapYourAnswer;

  /// No description provided for @guideLoadError.
  ///
  /// In en, this message translates to:
  /// **'This guide could not be loaded. Try again when you are online.'**
  String get guideLoadError;

  /// No description provided for @guideNoSections.
  ///
  /// In en, this message translates to:
  /// **'This guide has no sections.'**
  String get guideNoSections;

  /// No description provided for @guideSectionOf.
  ///
  /// In en, this message translates to:
  /// **'Section {current} of {total}'**
  String guideSectionOf(int current, int total);

  /// No description provided for @housingAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about housing'**
  String get housingAskTitle;

  /// No description provided for @housingAskHint.
  ///
  /// In en, this message translates to:
  /// **'Type a question…'**
  String get housingAskHint;

  /// No description provided for @housingAskFollowUpHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a follow-up…'**
  String get housingAskFollowUpHint;

  /// No description provided for @educationNavigatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Education Navigator'**
  String get educationNavigatorTitle;

  /// No description provided for @educationHubIntro.
  ///
  /// In en, this message translates to:
  /// **'Learn how California schools work, then find nearby public and private schools plus trusted tutoring, library, and STEM programs.'**
  String get educationHubIntro;

  /// No description provided for @educationBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Education basics'**
  String get educationBasicsTitle;

  /// No description provided for @educationBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enrollment, districts, grade levels, English learner support, and academic help.'**
  String get educationBasicsSubtitle;

  /// No description provided for @educationFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find schools & programs'**
  String get educationFindTitle;

  /// No description provided for @educationFindSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Map and list of nearby California public and private schools, libraries, tutoring, and STEM programs.'**
  String get educationFindSubtitle;

  /// No description provided for @healthcareNavigatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthcare Navigator'**
  String get healthcareNavigatorTitle;

  /// No description provided for @healthcareHubIntro.
  ///
  /// In en, this message translates to:
  /// **'Learn how care works in California, then find trusted community health centers near you.'**
  String get healthcareHubIntro;

  /// No description provided for @healthcareBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthcare basics'**
  String get healthcareBasicsTitle;

  /// No description provided for @healthcareBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance, how visits work, community health centers, and language help.'**
  String get healthcareBasicsSubtitle;

  /// No description provided for @healthcareFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a clinic'**
  String get healthcareFindTitle;

  /// No description provided for @healthcareFindSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Map and list of nearby HRSA community health centers by city or ZIP.'**
  String get healthcareFindSubtitle;

  /// No description provided for @finderCityOrZipLabel.
  ///
  /// In en, this message translates to:
  /// **'City or ZIP code'**
  String get finderCityOrZipLabel;

  /// No description provided for @finderCityOrZipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Oakland or 94102'**
  String get finderCityOrZipHint;

  /// No description provided for @finderSetCityOrZip.
  ///
  /// In en, this message translates to:
  /// **'Set a city or ZIP code'**
  String get finderSetCityOrZip;

  /// No description provided for @finderNear.
  ///
  /// In en, this message translates to:
  /// **'Near: {location}'**
  String finderNear(String location);

  /// No description provided for @finderHideSearchOptions.
  ///
  /// In en, this message translates to:
  /// **'Hide search options'**
  String get finderHideSearchOptions;

  /// No description provided for @finderResizeMap.
  ///
  /// In en, this message translates to:
  /// **'Resize map'**
  String get finderResizeMap;

  /// No description provided for @finderOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get finderOpenWebsite;

  /// No description provided for @finderKmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String finderKmAway(String distance);

  /// No description provided for @clinicsSearchIntro.
  ///
  /// In en, this message translates to:
  /// **'Search HRSA community health centers near a California city or ZIP. Pins are from the official federal directory.'**
  String get clinicsSearchIntro;

  /// No description provided for @clinicsFindButton.
  ///
  /// In en, this message translates to:
  /// **'Find nearby clinics'**
  String get clinicsFindButton;

  /// No description provided for @clinicsSearchDetail.
  ///
  /// In en, this message translates to:
  /// **'HRSA community health centers'**
  String get clinicsSearchDetail;

  /// No description provided for @clinicsEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter a city or ZIP code to find nearby clinics.'**
  String get clinicsEnterLocation;

  /// No description provided for @clinicsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No community health centers found nearby. Try another California city or ZIP, or widen your search later.'**
  String get clinicsNoResults;

  /// No description provided for @clinicsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load clinics. Try again shortly.'**
  String get clinicsLoadError;

  /// No description provided for @clinicsTypeFqhc.
  ///
  /// In en, this message translates to:
  /// **'Federally Qualified Health Center (FQHC)'**
  String get clinicsTypeFqhc;

  /// No description provided for @clinicsTypeFqhcLookAlike.
  ///
  /// In en, this message translates to:
  /// **'Federally Qualified Health Center (FQHC) Look-Alike'**
  String get clinicsTypeFqhcLookAlike;

  /// No description provided for @englishSearchIntro.
  ///
  /// In en, this message translates to:
  /// **'Find trusted adult schools, community colleges, and library ESL programs near a California city or ZIP.'**
  String get englishSearchIntro;

  /// No description provided for @englishFindButton.
  ///
  /// In en, this message translates to:
  /// **'Find nearby classes'**
  String get englishFindButton;

  /// No description provided for @englishSearchDetail.
  ///
  /// In en, this message translates to:
  /// **'Adult schools, colleges & libraries'**
  String get englishSearchDetail;

  /// No description provided for @englishEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter a city or ZIP code to find nearby classes.'**
  String get englishEnterLocation;

  /// No description provided for @englishNoResults.
  ///
  /// In en, this message translates to:
  /// **'No ESL resources found nearby yet. Try another California city or ZIP.'**
  String get englishNoResults;

  /// No description provided for @englishLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load English resources. Try again shortly.'**
  String get englishLoadError;

  /// No description provided for @englishSourceCurated.
  ///
  /// In en, this message translates to:
  /// **'Source: curated California adult ed, colleges, and libraries'**
  String get englishSourceCurated;

  /// No description provided for @englishSourceNamed.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String englishSourceNamed(String source);

  /// No description provided for @educationSearchIntro.
  ///
  /// In en, this message translates to:
  /// **'Search California public and private schools from the official CDE directory, plus curated libraries, tutoring, and STEM programs.'**
  String get educationSearchIntro;

  /// No description provided for @educationFindButton.
  ///
  /// In en, this message translates to:
  /// **'Find nearby'**
  String get educationFindButton;

  /// No description provided for @educationEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter a city or ZIP code to find nearby schools.'**
  String get educationEnterLocation;

  /// No description provided for @educationNoResults.
  ///
  /// In en, this message translates to:
  /// **'No schools or programs found nearby. Try another California city or ZIP, or change the filters.'**
  String get educationNoResults;

  /// No description provided for @educationLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load education resources. Try again.'**
  String get educationLoadError;

  /// No description provided for @educationLoadErrorShort.
  ///
  /// In en, this message translates to:
  /// **'Could not load education resources. Try again shortly.'**
  String get educationLoadErrorShort;

  /// No description provided for @educationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get educationTypeLabel;

  /// No description provided for @educationAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get educationAllTypes;

  /// No description provided for @educationKindSchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get educationKindSchools;

  /// No description provided for @educationKindPrograms.
  ///
  /// In en, this message translates to:
  /// **'Programs & support'**
  String get educationKindPrograms;

  /// No description provided for @educationKindPublicSchools.
  ///
  /// In en, this message translates to:
  /// **'Public schools'**
  String get educationKindPublicSchools;

  /// No description provided for @educationKindPrivateSchools.
  ///
  /// In en, this message translates to:
  /// **'Private schools'**
  String get educationKindPrivateSchools;

  /// No description provided for @educationKindEnrollmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Enrollment help'**
  String get educationKindEnrollmentHelp;

  /// No description provided for @educationKindLibraries.
  ///
  /// In en, this message translates to:
  /// **'Libraries'**
  String get educationKindLibraries;

  /// No description provided for @educationKindTutoring.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get educationKindTutoring;

  /// No description provided for @educationKindStem.
  ///
  /// In en, this message translates to:
  /// **'STEM / enrichment'**
  String get educationKindStem;

  /// No description provided for @educationAllGrades.
  ///
  /// In en, this message translates to:
  /// **'All grades'**
  String get educationAllGrades;

  /// No description provided for @educationGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get educationGradeLabel;

  /// No description provided for @educationGradePk.
  ///
  /// In en, this message translates to:
  /// **'PK'**
  String get educationGradePk;

  /// No description provided for @educationGrade12.
  ///
  /// In en, this message translates to:
  /// **'12th'**
  String get educationGrade12;

  /// No description provided for @educationGradeSingle.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String educationGradeSingle(String grade);

  /// No description provided for @educationGradesRange.
  ///
  /// In en, this message translates to:
  /// **'Grades {low}–{high}'**
  String educationGradesRange(String low, String high);

  /// No description provided for @educationMapBadge.
  ///
  /// In en, this message translates to:
  /// **'CDE schools + programs'**
  String get educationMapBadge;

  /// No description provided for @educationMoreInformation.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get educationMoreInformation;

  /// No description provided for @educationAiSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'AI-generated school summary'**
  String get educationAiSummaryLabel;

  /// No description provided for @educationAiSummaryReading.
  ///
  /// In en, this message translates to:
  /// **'Reading official school information…'**
  String get educationAiSummaryReading;

  /// No description provided for @educationAiSummaryError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate this summary. Try again shortly.'**
  String get educationAiSummaryError;

  /// No description provided for @educationAiSummaryClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get educationAiSummaryClose;

  /// No description provided for @educationAiSummaryCloseRetry.
  ///
  /// In en, this message translates to:
  /// **'Close and try again'**
  String get educationAiSummaryCloseRetry;

  /// No description provided for @educationAiSummaryDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This summary was generated by AI from official sources. It does not include ratings or parent reviews and may miss recent changes. Verify important details directly with the school.'**
  String get educationAiSummaryDisclaimer;

  /// No description provided for @educationAiSummaryHighlights.
  ///
  /// In en, this message translates to:
  /// **'What the sources say'**
  String get educationAiSummaryHighlights;

  /// No description provided for @educationAiSummaryQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions to ask the school'**
  String get educationAiSummaryQuestions;

  /// No description provided for @educationAiSummarySources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get educationAiSummarySources;

  /// No description provided for @educationSourceCde.
  ///
  /// In en, this message translates to:
  /// **'California School Directory'**
  String get educationSourceCde;

  /// No description provided for @educationSourceWebsite.
  ///
  /// In en, this message translates to:
  /// **'Official school website'**
  String get educationSourceWebsite;

  /// No description provided for @educationTypeElementary.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get educationTypeElementary;

  /// No description provided for @educationTypeHighSchool.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get educationTypeHighSchool;

  /// No description provided for @educationTypeMiddle.
  ///
  /// In en, this message translates to:
  /// **'Intermediate/Middle/Junior High'**
  String get educationTypeMiddle;

  /// No description provided for @educationTypeElemHigh.
  ///
  /// In en, this message translates to:
  /// **'Elementary-High Combination'**
  String get educationTypeElemHigh;

  /// No description provided for @educationTypeAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get educationTypeAdult;

  /// No description provided for @educationTypePreschool.
  ///
  /// In en, this message translates to:
  /// **'Preschool'**
  String get educationTypePreschool;

  /// No description provided for @educationTypeUngraded.
  ///
  /// In en, this message translates to:
  /// **'Ungraded'**
  String get educationTypeUngraded;

  /// No description provided for @educationTypePrivateTuition.
  ///
  /// In en, this message translates to:
  /// **'Private school (tuition based)'**
  String get educationTypePrivateTuition;

  /// No description provided for @educationChipPublicSchool.
  ///
  /// In en, this message translates to:
  /// **'Public school'**
  String get educationChipPublicSchool;

  /// No description provided for @educationChipPrivateSchool.
  ///
  /// In en, this message translates to:
  /// **'Private school'**
  String get educationChipPrivateSchool;

  /// No description provided for @educationChipLibrary.
  ///
  /// In en, this message translates to:
  /// **'Public library'**
  String get educationChipLibrary;

  /// No description provided for @educationChipResource.
  ///
  /// In en, this message translates to:
  /// **'Education resource'**
  String get educationChipResource;

  /// No description provided for @educationBandMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get educationBandMiddle;

  /// No description provided for @educationBandHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get educationBandHigh;

  /// No description provided for @educationGradeK.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get educationGradeK;

  /// No description provided for @educationGenderCoed.
  ///
  /// In en, this message translates to:
  /// **'Coeducational'**
  String get educationGenderCoed;

  /// No description provided for @educationGenderBoys.
  ///
  /// In en, this message translates to:
  /// **'Boys only'**
  String get educationGenderBoys;

  /// No description provided for @educationGenderGirls.
  ///
  /// In en, this message translates to:
  /// **'Girls only'**
  String get educationGenderGirls;

  /// No description provided for @educationAffilNonReligious.
  ///
  /// In en, this message translates to:
  /// **'Non-religious'**
  String get educationAffilNonReligious;

  /// No description provided for @educationAffilCatholic.
  ///
  /// In en, this message translates to:
  /// **'Catholic'**
  String get educationAffilCatholic;

  /// No description provided for @educationAffilNondenominational.
  ///
  /// In en, this message translates to:
  /// **'Nondenominational'**
  String get educationAffilNondenominational;

  /// No description provided for @educationAffilSeventhDayAdventist.
  ///
  /// In en, this message translates to:
  /// **'Seventh-day Adventist'**
  String get educationAffilSeventhDayAdventist;

  /// No description provided for @educationAffilBaptist.
  ///
  /// In en, this message translates to:
  /// **'Baptist'**
  String get educationAffilBaptist;

  /// No description provided for @educationAffilLutheran.
  ///
  /// In en, this message translates to:
  /// **'Lutheran'**
  String get educationAffilLutheran;

  /// No description provided for @educationAffilJewish.
  ///
  /// In en, this message translates to:
  /// **'Jewish'**
  String get educationAffilJewish;

  /// No description provided for @educationAffilEvangelical.
  ///
  /// In en, this message translates to:
  /// **'Evangelical'**
  String get educationAffilEvangelical;

  /// No description provided for @educationAffilIslamic.
  ///
  /// In en, this message translates to:
  /// **'Islamic (Muslim)'**
  String get educationAffilIslamic;

  /// No description provided for @educationAffilOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get educationAffilOther;

  /// No description provided for @educationAffilCalvaryChapel.
  ///
  /// In en, this message translates to:
  /// **'Calvary Chapel'**
  String get educationAffilCalvaryChapel;

  /// No description provided for @educationAffilAssemblyOfGod.
  ///
  /// In en, this message translates to:
  /// **'Assembly of God'**
  String get educationAffilAssemblyOfGod;

  /// No description provided for @educationAffilApostolic.
  ///
  /// In en, this message translates to:
  /// **'Apostolic'**
  String get educationAffilApostolic;

  /// No description provided for @educationAffilEpiscopal.
  ///
  /// In en, this message translates to:
  /// **'Episcopal'**
  String get educationAffilEpiscopal;

  /// No description provided for @educationAffilPentecostal.
  ///
  /// In en, this message translates to:
  /// **'Pentecostal'**
  String get educationAffilPentecostal;

  /// No description provided for @educationAffilDisciplesOfChrist.
  ///
  /// In en, this message translates to:
  /// **'Christian Church (Disciples of Christ)'**
  String get educationAffilDisciplesOfChrist;

  /// No description provided for @educationAffilInterdenominational.
  ///
  /// In en, this message translates to:
  /// **'Interdenominational'**
  String get educationAffilInterdenominational;

  /// No description provided for @educationAffilReformed.
  ///
  /// In en, this message translates to:
  /// **'Reformed'**
  String get educationAffilReformed;

  /// No description provided for @educationAffilMennonite.
  ///
  /// In en, this message translates to:
  /// **'Mennonite'**
  String get educationAffilMennonite;

  /// No description provided for @educationAffilChurchOfChrist.
  ///
  /// In en, this message translates to:
  /// **'Church of Christ'**
  String get educationAffilChurchOfChrist;

  /// No description provided for @educationAffilPresbyterian.
  ///
  /// In en, this message translates to:
  /// **'Presbyterian'**
  String get educationAffilPresbyterian;

  /// No description provided for @educationAffilFourSquare.
  ///
  /// In en, this message translates to:
  /// **'Four Square Gospel'**
  String get educationAffilFourSquare;

  /// No description provided for @educationAffilNazarene.
  ///
  /// In en, this message translates to:
  /// **'Church of the Nazarene'**
  String get educationAffilNazarene;

  /// No description provided for @educationAffilOrthodox.
  ///
  /// In en, this message translates to:
  /// **'Orthodox (Eastern/Greek)'**
  String get educationAffilOrthodox;

  /// No description provided for @educationAffilChurchOfGod.
  ///
  /// In en, this message translates to:
  /// **'Church of God'**
  String get educationAffilChurchOfGod;

  /// No description provided for @educationAffilJehovahsWitnesses.
  ///
  /// In en, this message translates to:
  /// **'Jehovah\'s Witnesses'**
  String get educationAffilJehovahsWitnesses;

  /// No description provided for @educationAffilMormon.
  ///
  /// In en, this message translates to:
  /// **'Mormon (Latter-day Saints)'**
  String get educationAffilMormon;

  /// No description provided for @educationAffilFundamentalistChristian.
  ///
  /// In en, this message translates to:
  /// **'Fundamentalist Christian'**
  String get educationAffilFundamentalistChristian;

  /// No description provided for @educationAffilQuaker.
  ///
  /// In en, this message translates to:
  /// **'Quaker (Friends)'**
  String get educationAffilQuaker;

  /// No description provided for @educationAffilCovenant.
  ///
  /// In en, this message translates to:
  /// **'Covenant'**
  String get educationAffilCovenant;

  /// No description provided for @educationAffilNewAge.
  ///
  /// In en, this message translates to:
  /// **'New Age'**
  String get educationAffilNewAge;

  /// No description provided for @educationAffilCharismatic.
  ///
  /// In en, this message translates to:
  /// **'Charismatic'**
  String get educationAffilCharismatic;

  /// No description provided for @educationAffilMethodist.
  ///
  /// In en, this message translates to:
  /// **'Methodist'**
  String get educationAffilMethodist;

  /// No description provided for @educationAffilSikh.
  ///
  /// In en, this message translates to:
  /// **'Sikh'**
  String get educationAffilSikh;

  /// No description provided for @educationAffilBuddhist.
  ///
  /// In en, this message translates to:
  /// **'Buddhist'**
  String get educationAffilBuddhist;

  /// No description provided for @educationAffilBrethren.
  ///
  /// In en, this message translates to:
  /// **'Church of the Brethren'**
  String get educationAffilBrethren;

  /// No description provided for @educationAffilScientology.
  ///
  /// In en, this message translates to:
  /// **'Scientology'**
  String get educationAffilScientology;

  /// No description provided for @groupsIntro.
  ///
  /// In en, this message translates to:
  /// **'Join a group to post, ask questions, and help other newcomers in California.'**
  String get groupsIntro;

  /// No description provided for @groupsDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get groupsDiscover;

  /// No description provided for @groupsMine.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get groupsMine;

  /// No description provided for @groupsMineCount.
  ///
  /// In en, this message translates to:
  /// **'My groups ({count})'**
  String groupsMineCount(int count);

  /// No description provided for @groupsSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest a new group'**
  String get groupsSuggest;

  /// No description provided for @groupsJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get groupsJoin;

  /// No description provided for @groupsJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get groupsJoined;

  /// No description provided for @groupsLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get groupsLeave;

  /// No description provided for @groupsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get groupsSearch;

  /// No description provided for @groupsSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get groupsSearchClear;

  /// No description provided for @groupsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get groupsFilterAll;

  /// No description provided for @groupsSearchNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No groups match your search.'**
  String get groupsSearchNoMatch;

  /// No description provided for @groupsMineEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not joined a group yet. Switch to Discover to find one.'**
  String get groupsMineEmpty;

  /// No description provided for @groupsCategoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No groups in this category yet.'**
  String get groupsCategoryEmpty;

  /// No description provided for @groupsSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest a group'**
  String get groupsSuggestTitle;

  /// No description provided for @groupsSuggestIntro.
  ///
  /// In en, this message translates to:
  /// **'Propose a group for other newcomers in California. An admin reviews every suggestion before it is opened for people to join.'**
  String get groupsSuggestIntro;

  /// No description provided for @groupsSuggestNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupsSuggestNameLabel;

  /// No description provided for @groupsSuggestNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Newcomers in Fresno'**
  String get groupsSuggestNameHint;

  /// No description provided for @groupsSuggestCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get groupsSuggestCategory;

  /// No description provided for @groupsSuggestPurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'What is this group for?'**
  String get groupsSuggestPurposeLabel;

  /// No description provided for @groupsSuggestPurposeHint.
  ///
  /// In en, this message translates to:
  /// **'Who should join, and what will people talk about?'**
  String get groupsSuggestPurposeHint;

  /// No description provided for @groupsSuggestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get groupsSuggestSubmit;

  /// No description provided for @groupsSuggestSent.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent. An admin will review it before the group appears.'**
  String get groupsSuggestSent;

  /// No description provided for @groupsSuggestSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send that suggestion. Try again.'**
  String get groupsSuggestSendError;

  /// No description provided for @groupsSuggestNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the group a name.'**
  String get groupsSuggestNameRequired;

  /// No description provided for @groupsSuggestDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a short description.'**
  String get groupsSuggestDescriptionRequired;

  /// No description provided for @groupsCategoryParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get groupsCategoryParents;

  /// No description provided for @groupsCategoryJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get groupsCategoryJobs;

  /// No description provided for @groupsCategoryLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get groupsCategoryLanguage;

  /// No description provided for @groupsCategoryCareers.
  ///
  /// In en, this message translates to:
  /// **'Careers'**
  String get groupsCategoryCareers;

  /// No description provided for @groupsCategoryCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get groupsCategoryCulture;

  /// No description provided for @groupsCategoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get groupsCategoryHousing;

  /// No description provided for @groupsCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get groupsCategoryOther;

  /// No description provided for @groupsFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Support group'**
  String get groupsFallbackTitle;

  /// No description provided for @groupsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this group.'**
  String get groupsLoadError;

  /// No description provided for @groupsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This group is no longer available.'**
  String get groupsUnavailable;

  /// No description provided for @groupsRemovedAdmin.
  ///
  /// In en, this message translates to:
  /// **'This group was removed by an admin.'**
  String get groupsRemovedAdmin;

  /// No description provided for @groupsRemovedWithReason.
  ///
  /// In en, this message translates to:
  /// **'This group was removed. Reason: {reason}'**
  String groupsRemovedWithReason(String reason);

  /// No description provided for @groupsMemberOne.
  ///
  /// In en, this message translates to:
  /// **'1 member'**
  String get groupsMemberOne;

  /// No description provided for @groupsMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String groupsMemberCount(int count);

  /// No description provided for @groupsPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Posts and questions are private to members. They are checked for safety before others can see them. Be kind, and do not paste ID numbers, passwords, or account numbers.'**
  String get groupsPrivacyNotice;

  /// No description provided for @groupsNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get groupsNewPost;

  /// No description provided for @groupsAskQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get groupsAskQuestion;

  /// No description provided for @groupsJoinToRead.
  ///
  /// In en, this message translates to:
  /// **'Join to read posts and reply'**
  String get groupsJoinToRead;

  /// No description provided for @groupsJoinPrompt.
  ///
  /// In en, this message translates to:
  /// **'Only members can see posts and questions in this group. Join when you are ready to take part.'**
  String get groupsJoinPrompt;

  /// No description provided for @groupsJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get groupsJoinGroup;

  /// No description provided for @groupsLeaveShort.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupsLeaveShort;

  /// No description provided for @groupsLeaveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this group?'**
  String get groupsLeaveConfirmTitle;

  /// No description provided for @groupsLeaveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will stop seeing posts in \"{title}\". You can join again later.'**
  String groupsLeaveConfirmBody(String title);

  /// No description provided for @groupsPostsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load posts. Join the group and try again.'**
  String get groupsPostsLoadError;

  /// No description provided for @groupsNoPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Share something, or ask a question the group can help with.'**
  String get groupsNoPostsYet;

  /// No description provided for @groupsYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get groupsYou;

  /// No description provided for @groupsPostOptions.
  ///
  /// In en, this message translates to:
  /// **'Post options'**
  String get groupsPostOptions;

  /// No description provided for @groupsReplyOptions.
  ///
  /// In en, this message translates to:
  /// **'Reply options'**
  String get groupsReplyOptions;

  /// No description provided for @groupsKindPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get groupsKindPost;

  /// No description provided for @groupsKindQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get groupsKindQuestion;

  /// No description provided for @groupsNoAnswersYet.
  ///
  /// In en, this message translates to:
  /// **'No answers yet'**
  String get groupsNoAnswersYet;

  /// No description provided for @groupsNoRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get groupsNoRepliesYet;

  /// No description provided for @groupsReplyOne.
  ///
  /// In en, this message translates to:
  /// **'1 reply'**
  String get groupsReplyOne;

  /// No description provided for @groupsReplyMany.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String groupsReplyMany(int count);

  /// No description provided for @groupsComposePostIntro.
  ///
  /// In en, this message translates to:
  /// **'Share an update, a tip, or something that might help others in this group.'**
  String get groupsComposePostIntro;

  /// No description provided for @groupsComposeQuestionIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask the group something they can help with. Other members can reply on this thread.'**
  String get groupsComposeQuestionIntro;

  /// No description provided for @groupsComposeGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Posts are checked for safety before others can see them. Do not paste ID numbers, passwords, or account numbers. Talking about benefits, visas, and papers is fine.'**
  String get groupsComposeGuidelines;

  /// No description provided for @groupsComposeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get groupsComposeTitleLabel;

  /// No description provided for @groupsComposeQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get groupsComposeQuestionLabel;

  /// No description provided for @groupsComposeTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. A resume tip that helped me'**
  String get groupsComposeTitleHint;

  /// No description provided for @groupsComposeQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. How did you find a pediatrician?'**
  String get groupsComposeQuestionHint;

  /// No description provided for @groupsComposeBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupsComposeBodyLabel;

  /// No description provided for @groupsComposeDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get groupsComposeDetailsLabel;

  /// No description provided for @groupsComposeBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Add the story, a link, or anything useful.'**
  String get groupsComposeBodyHint;

  /// No description provided for @groupsComposeDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add any details that would help people answer.'**
  String get groupsComposeDetailsHint;

  /// No description provided for @groupsAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get groupsAddPhotos;

  /// No description provided for @groupsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get groupsAdd;

  /// No description provided for @groupsPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} photos'**
  String groupsPhotoCount(int count, int max);

  /// No description provided for @groupsPublishPost.
  ///
  /// In en, this message translates to:
  /// **'Publish post'**
  String get groupsPublishPost;

  /// No description provided for @groupsPostQuestion.
  ///
  /// In en, this message translates to:
  /// **'Post question'**
  String get groupsPostQuestion;

  /// No description provided for @groupsPhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get groupsPhotoLibrary;

  /// No description provided for @groupsCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get groupsCamera;

  /// No description provided for @groupsPhotoOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open that photo. Try another one.'**
  String get groupsPhotoOpenError;

  /// No description provided for @groupsPublishError.
  ///
  /// In en, this message translates to:
  /// **'Could not publish that. Try again.'**
  String get groupsPublishError;

  /// No description provided for @groupsRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get groupsRemovePhoto;

  /// No description provided for @groupsPostLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this post.'**
  String get groupsPostLoadError;

  /// No description provided for @groupsPostRemoved.
  ///
  /// In en, this message translates to:
  /// **'This post was removed.'**
  String get groupsPostRemoved;

  /// No description provided for @groupsAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get groupsAnswers;

  /// No description provided for @groupsReplies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get groupsReplies;

  /// No description provided for @groupsRepliesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load replies.'**
  String get groupsRepliesLoadError;

  /// No description provided for @groupsNoAnswersHelp.
  ///
  /// In en, this message translates to:
  /// **'No answers yet. Be the first to help.'**
  String get groupsNoAnswersHelp;

  /// No description provided for @groupsNoRepliesHelp.
  ///
  /// In en, this message translates to:
  /// **'No replies yet. Start the conversation.'**
  String get groupsNoRepliesHelp;

  /// No description provided for @groupsWriteAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write an answer…'**
  String get groupsWriteAnswer;

  /// No description provided for @groupsWriteReply.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get groupsWriteReply;

  /// No description provided for @groupsEditReply.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get groupsEditReply;

  /// No description provided for @groupsWriteReplyFirst.
  ///
  /// In en, this message translates to:
  /// **'Write a reply first.'**
  String get groupsWriteReplyFirst;

  /// No description provided for @groupsDeleteReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this reply?'**
  String get groupsDeleteReplyTitle;

  /// No description provided for @groupsDeleteReplyBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get groupsDeleteReplyBody;

  /// No description provided for @groupsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get groupsEdit;

  /// No description provided for @groupsEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get groupsEdited;

  /// No description provided for @groupsReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get groupsReply;

  /// No description provided for @groupsDeletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get groupsDeletePostTitle;

  /// No description provided for @groupsDeletePostBody.
  ///
  /// In en, this message translates to:
  /// **'Replies will be removed too. This cannot be undone.'**
  String get groupsDeletePostBody;

  /// No description provided for @groupsRemovePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this post?'**
  String get groupsRemovePostTitle;

  /// No description provided for @groupsRemovePostBody.
  ///
  /// In en, this message translates to:
  /// **'The post will be hidden from the group. The author has 7 days to appeal. If they do not, or a moderator declines the appeal, it will be deleted.'**
  String get groupsRemovePostBody;

  /// No description provided for @groupsRemovePostReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get groupsRemovePostReason;

  /// No description provided for @groupsRemovePostHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. This broke the group rules.'**
  String get groupsRemovePostHint;

  /// No description provided for @groupsRemovePostReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please say why this post is being removed.'**
  String get groupsRemovePostReasonRequired;

  /// No description provided for @groupsRemovePostAction.
  ///
  /// In en, this message translates to:
  /// **'Remove post'**
  String get groupsRemovePostAction;

  /// No description provided for @groupsModerationChecking.
  ///
  /// In en, this message translates to:
  /// **'The AI is checking this'**
  String get groupsModerationChecking;

  /// No description provided for @groupsModerationPendingBody.
  ///
  /// In en, this message translates to:
  /// **'We are checking this before others can see it. It should appear in a moment.'**
  String get groupsModerationPendingBody;

  /// No description provided for @groupsModerationHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden from the group'**
  String get groupsModerationHidden;

  /// No description provided for @groupsModerationHiddenPii.
  ///
  /// In en, this message translates to:
  /// **'This looks like a real ID or account number. Please remove the number and try again. You can still talk about the topic.'**
  String get groupsModerationHiddenPii;

  /// No description provided for @groupsModerationHiddenScam.
  ///
  /// In en, this message translates to:
  /// **'This looks like it could be asking people for money or personal details. Please keep the group free of sales and suspicious offers.'**
  String get groupsModerationHiddenScam;

  /// No description provided for @groupsModerationHiddenHate.
  ///
  /// In en, this message translates to:
  /// **'Please keep this group respectful. Unkind or hateful posts are not allowed.'**
  String get groupsModerationHiddenHate;

  /// No description provided for @groupsModerationHiddenHarassment.
  ///
  /// In en, this message translates to:
  /// **'Please keep this group respectful. Harassment is not allowed.'**
  String get groupsModerationHiddenHarassment;

  /// No description provided for @groupsModerationHiddenSexual.
  ///
  /// In en, this message translates to:
  /// **'This post does not fit a family support group. Please keep posts appropriate.'**
  String get groupsModerationHiddenSexual;

  /// No description provided for @groupsModerationHiddenSelfHarm.
  ///
  /// In en, this message translates to:
  /// **'If you are in crisis, call or text 988 in the US. This was hidden because it may include harmful content.'**
  String get groupsModerationHiddenSelfHarm;

  /// No description provided for @groupsModerationHiddenViolence.
  ///
  /// In en, this message translates to:
  /// **'Violent content is not allowed in this group.'**
  String get groupsModerationHiddenViolence;

  /// No description provided for @groupsModerationHiddenGeneric.
  ///
  /// In en, this message translates to:
  /// **'This was hidden because it did not meet community guidelines. Please rewrite it and try again.'**
  String get groupsModerationHiddenGeneric;

  /// No description provided for @groupsAppealSent.
  ///
  /// In en, this message translates to:
  /// **'Appeal sent'**
  String get groupsAppealSent;

  /// No description provided for @groupsReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String groupsReasonPrefix(String reason);

  /// No description provided for @groupsHiddenByAdmin.
  ///
  /// In en, this message translates to:
  /// **'An admin hid this post.'**
  String get groupsHiddenByAdmin;

  /// No description provided for @groupsDeletedAfter.
  ///
  /// In en, this message translates to:
  /// **'It will be deleted after {deadline} unless an appeal is approved.'**
  String groupsDeletedAfter(String deadline);

  /// No description provided for @groupsAppealPendingReview.
  ///
  /// In en, this message translates to:
  /// **'A moderator will review your appeal.'**
  String get groupsAppealPendingReview;

  /// No description provided for @groupsAppeal.
  ///
  /// In en, this message translates to:
  /// **'Appeal'**
  String get groupsAppeal;

  /// No description provided for @groupsAppealTitle.
  ///
  /// In en, this message translates to:
  /// **'Appeal this removal?'**
  String get groupsAppealTitle;

  /// No description provided for @groupsAppealIntro.
  ///
  /// In en, this message translates to:
  /// **'A moderator will review it. If they agree, the post will show in the group again.'**
  String get groupsAppealIntro;

  /// No description provided for @groupsAppealLabel.
  ///
  /// In en, this message translates to:
  /// **'Why should it stay? (optional)'**
  String get groupsAppealLabel;

  /// No description provided for @groupsSendAppeal.
  ///
  /// In en, this message translates to:
  /// **'Send appeal'**
  String get groupsSendAppeal;

  /// No description provided for @groupsNoticeDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get groupsNoticeDismiss;

  /// No description provided for @groupsNoticeAppealReviewing.
  ///
  /// In en, this message translates to:
  /// **'We\'re reviewing your appeal'**
  String get groupsNoticeAppealReviewing;

  /// No description provided for @groupsNoticeStillHidden.
  ///
  /// In en, this message translates to:
  /// **'\"{postTitle}\" in {groupTitle} is still hidden.'**
  String groupsNoticeStillHidden(String postTitle, String groupTitle);

  /// No description provided for @groupsNoticePostBack.
  ///
  /// In en, this message translates to:
  /// **'Your post is back'**
  String get groupsNoticePostBack;

  /// No description provided for @groupsNoticeVisibleAgain.
  ///
  /// In en, this message translates to:
  /// **'\"{postTitle}\" in {groupTitle} is visible to the group again.'**
  String groupsNoticeVisibleAgain(String postTitle, String groupTitle);

  /// No description provided for @groupsNoticeAppealDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your appeal was declined'**
  String get groupsNoticeAppealDeclined;

  /// No description provided for @groupsNoticeWasRemoved.
  ///
  /// In en, this message translates to:
  /// **'\"{postTitle}\" in {groupTitle} was removed.'**
  String groupsNoticeWasRemoved(String postTitle, String groupTitle);

  /// No description provided for @groupsNoticePostRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your post was removed'**
  String get groupsNoticePostRemovedTitle;

  /// No description provided for @groupsNoticeDeletedAfterWindow.
  ///
  /// In en, this message translates to:
  /// **'\"{postTitle}\" in {groupTitle} was deleted after the appeal window ended.'**
  String groupsNoticeDeletedAfterWindow(String postTitle, String groupTitle);

  /// No description provided for @groupsNoticePostHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your post was hidden'**
  String get groupsNoticePostHiddenTitle;

  /// No description provided for @groupsNoticeHiddenReason.
  ///
  /// In en, this message translates to:
  /// **'\"{postTitle}\" in {groupTitle} was hidden. Reason: {reason}'**
  String groupsNoticeHiddenReason(
    String postTitle,
    String groupTitle,
    String reason,
  );

  /// No description provided for @groupsNoticeHiddenAdmin.
  ///
  /// In en, this message translates to:
  /// **'\"{postTitle}\" in {groupTitle} was hidden by an admin.'**
  String groupsNoticeHiddenAdmin(String postTitle, String groupTitle);

  /// No description provided for @groupsNoticeAppealUntil.
  ///
  /// In en, this message translates to:
  /// **'You can appeal until {deadline}.'**
  String groupsNoticeAppealUntil(String deadline);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'hi',
    'ko',
    'tl',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'ko':
      return AppLocalizationsKo();
    case 'tl':
      return AppLocalizationsTl();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
