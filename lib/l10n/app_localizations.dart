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

  /// No description provided for @authWhatIsNewRoots.
  ///
  /// In en, this message translates to:
  /// **'What is NewRoots?'**
  String get authWhatIsNewRoots;

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

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'America brims with opportunities.\n\nIt is an economic powerhouse. It boasts a constitution so strong and effective that it has set the standard for dozens of other countries. It is a land of many unique cultures.\n\nBut it\'s hard to find your footing in a new country - especially in America.\n\nNewRoots is here to solve these problems. We\'ll help you find your place.\nWe\'ll help you make new connections. We\'ll help you steer clear of traps. We\'ll help you take advantage of resources near you.\nLet us show you what America is all about.\n\nFind your new roots.'**
  String get aboutBody;

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
