// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NewRoots';

  @override
  String get tagline => 'From arrival to belonging.';

  @override
  String get navHome => 'Home';

  @override
  String get navScamShield => 'ScamShield';

  @override
  String get navProfile => 'Profile';

  @override
  String get featureRoadmap => 'Integration Roadmap';

  @override
  String get featureHousing => 'Housing';

  @override
  String get featureCareer => 'Career Bridge';

  @override
  String get featureEnglish => 'English Learning';

  @override
  String get featureEducation => 'Education';

  @override
  String get featureHealthcare => 'Healthcare';

  @override
  String get featureSupportGroups => 'Support Groups';

  @override
  String get featureScamShield => 'ScamShield';

  @override
  String get featureSafety => 'Safety Guide';

  @override
  String get placeholderComingSoon => 'Coming soon';

  @override
  String get disclaimer =>
      'NewRoots is a navigation tool, not a substitute for legal, medical, or financial professionals.';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String actionEdit(String label) {
    return 'Edit $label';
  }

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionLogIn => 'Log in';

  @override
  String get actionSignUp => 'Sign up';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get actionStart => 'Start';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionNext => 'Next';

  @override
  String get actionFinish => 'Finish';

  @override
  String get actionSkipQuestion => 'Skip question';

  @override
  String get actionSkipForNow => 'Skip for now';

  @override
  String get actionContinueSurvey => 'Continue survey';

  @override
  String get actionStartSurvey => 'Start Survey';

  @override
  String get actionSkipSurvey => 'Skip Survey';

  @override
  String get actionTakeSurvey => 'Take Survey';

  @override
  String get actionRetakeSurvey => 'Retake Survey';

  @override
  String get authWelcomeBack => 'Welcome back. Log in to continue.';

  @override
  String get authCreateAccountSubtitle => 'Create your account to get started.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authPrivacyPolicy => 'Privacy policy';

  @override
  String get authEmailPasswordRequired =>
      'Please enter your email and password.';

  @override
  String get authFillAllFields => 'Please fill in all fields.';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters.';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get language => 'Language';

  @override
  String get preferredLanguage => 'Preferred language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get editPreferredLanguage => 'Edit preferred language';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignedIn => 'Signed in';

  @override
  String get profileLocation => 'Location';

  @override
  String get profileChildrenCount => 'How many children';

  @override
  String get profilePriorities => 'Top priorities';

  @override
  String get profileEmployment => 'Employment background';

  @override
  String get profileChildrenAges => 'Children ages';

  @override
  String get profileSkipped => 'Skipped';

  @override
  String get profileNoSurvey => 'No survey data yet.';

  @override
  String get profileReviewSuggestions => 'Review group suggestions';

  @override
  String get profileAdmin => 'Admin';

  @override
  String get priorityHousing => 'Housing';

  @override
  String get priorityEmployment => 'Employment';

  @override
  String get priorityEducation => 'Education';

  @override
  String get priorityHealthcare => 'Healthcare';

  @override
  String get priorityEnglish => 'English learning';

  @override
  String get prioritySafety => 'Safety';

  @override
  String get priorityOther => 'Other';

  @override
  String get priorityOtherHint => 'Describe your priority';

  @override
  String get onboardingTitle => 'Onboarding Survey';

  @override
  String get onboardingIntro => 'Take a quick survey for personalization.';

  @override
  String get onboardingSkipTitle => 'Skip onboarding survey?';

  @override
  String get onboardingSkipBody =>
      'Taking the survey lets us understand your situation and design solutions (individual questions can be skipped).';

  @override
  String get onboardingSurveyLater =>
      'The survey can be taken at any time on the profile page.';

  @override
  String get onboardingQuestionLanguage => 'Preferred language';

  @override
  String get onboardingQuestionLocation => 'Where are you located?';

  @override
  String get onboardingQuestionChildren => 'How many children?';

  @override
  String get onboardingQuestionPriorities => 'Top priorities right now';

  @override
  String get onboardingQuestionEmployment => 'Employment background';

  @override
  String get onboardingQuestionAges => 'Children ages';

  @override
  String get onboardingSelectChildren => 'Select number of children';

  @override
  String get onboardingCityOrZip => 'City or ZIP code';

  @override
  String get scamIntro =>
      'Check suspicious messages, emails, job offers, rental ads, and government-related content. ScamShield explains why something may be risky so you can decide what to do next.';

  @override
  String get scamWhatChecking => 'What are you checking?';

  @override
  String get scamPasteLabel => 'Paste the message or listing';

  @override
  String get scamPasteHint => 'Paste the full text here…';

  @override
  String get scamAddScreenshot => 'Add screenshot';

  @override
  String get scamAnalyze => 'Analyze for scam risk';

  @override
  String get scamPastChecks => 'Past checks';

  @override
  String get scamDropHint => 'Drag and drop a screenshot here';

  @override
  String get scamBrowseHint => 'or click to browse';

  @override
  String get scamReplace => 'Replace';

  @override
  String get scamRemove => 'Remove';

  @override
  String get scamPastLoadError => 'Could not load past checks right now.';

  @override
  String get scamPastEmpty =>
      'No past checks yet. Analyze a message to save one here.';

  @override
  String get scamScreenshotCheck => 'Screenshot check';

  @override
  String get scamDelete => 'Delete';

  @override
  String get scamDeleteTitle => 'Delete this check?';

  @override
  String get scamDeleteBody =>
      'This removes the saved report from your past checks.';

  @override
  String get scamNeedInput => 'Paste a message or add a screenshot to analyze.';

  @override
  String get scamImageOpenError =>
      'Could not open that image. Try another photo.';

  @override
  String get scamDeleteError => 'Could not delete that check. Try again.';

  @override
  String get scamChooseGallery => 'Choose from gallery';

  @override
  String get scamTakePhoto => 'Take a photo';

  @override
  String get scamScreenshot => 'Screenshot';

  @override
  String get scamRiskLow => 'Low Risk';

  @override
  String get scamRiskModerate => 'Moderate Risk';

  @override
  String get scamRiskHigh => 'High Risk';

  @override
  String get scamYesterday => 'Yesterday';

  @override
  String scamDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get scamCategorySms => 'Text message';

  @override
  String get scamCategoryEmail => 'Email';

  @override
  String get scamCategoryJob => 'Job offer';

  @override
  String get scamCategoryRental => 'Rental ad';

  @override
  String get scamCategoryGovernment => 'Government';

  @override
  String scamUpdatedFrom(String level) {
    return 'Updated from $level';
  }

  @override
  String get scamWhatYouSubmitted => 'What you submitted';

  @override
  String get scamExpand => 'Expand';

  @override
  String get scamCollapse => 'Collapse';

  @override
  String get scamMessage => 'Message';

  @override
  String scamMessageNumber(int number) {
    return 'Message $number';
  }

  @override
  String get scamWhyRisky => 'Why this may be risky';

  @override
  String get scamWhatYouCanDo => 'What you can do';

  @override
  String get scamAddMessage => 'Add message';

  @override
  String get scamFollowUpTitle => 'Add a follow-up from the conversation';

  @override
  String get scamFollowUpHint => 'Paste the next text or email…';

  @override
  String get scamReevaluate => 'Reevaluate';

  @override
  String get scamFollowUpNeedInput =>
      'Paste a follow-up message or add a screenshot.';

  @override
  String get scamFollowUpImageError => 'Could not open that image.';

  @override
  String get scamScreenshotAttached => 'Screenshot attached';

  @override
  String scamThreadCount(int count) {
    return '$count messages in this thread';
  }

  @override
  String get actionSend => 'Send';

  @override
  String get actionDelete => 'Delete';

  @override
  String get followupAsk => 'Ask';

  @override
  String get followupSaveNote => 'Save note';

  @override
  String get followupDeleteNote => 'Delete note';

  @override
  String followupQuestion(String question) {
    return 'Q: $question';
  }

  @override
  String get careerSignIn => 'Sign in to explore career pathways.';

  @override
  String get careerAddPriorJob =>
      'Add your prior job in your profile survey, or describe your background in the notes below.';

  @override
  String get careerGoToProfile => 'Go to profile';

  @override
  String get careerPriorEmployment => 'Prior employment (from your survey)';

  @override
  String get careerAdditionalBackground => 'Additional background';

  @override
  String get careerAdditionalBackgroundHelp =>
      'Skills, education, certifications, languages, or career goals that will help the AI suggest better paths.';

  @override
  String get careerAdditionalBackgroundHint =>
      'e.g. 5 years as an electrician, vocational diploma, interested in solar installation…';

  @override
  String get careerGenerateAll => 'Generate career paths';

  @override
  String get careerRegenerateAll => 'Regenerate all paths';

  @override
  String get careerGenerating => 'Mapping career pathways…';

  @override
  String get careerNeedBackground =>
      'Add notes about your skills or education first.';

  @override
  String get careerCouldNotSaveChecklist =>
      'Could not save checklist progress.';

  @override
  String get careerCouldNotSaveStep => 'Could not save step progress.';

  @override
  String get careerCouldNotSaveNote => 'Could not save note.';

  @override
  String get careerCouldNotDeleteNote => 'Could not delete that note.';

  @override
  String get careerDeleteNoteTitle => 'Delete this note?';

  @override
  String get careerDeleteNoteBody =>
      'This removes the note from this career path.';

  @override
  String get careerGeneratePathTitle => 'Generate this path?';

  @override
  String get careerRegeneratePathTitle => 'Regenerate this path?';

  @override
  String careerGeneratePathBody(int number) {
    return 'Create an AI-generated career path for Path $number. Your other paths and notes are kept.';
  }

  @override
  String careerRegeneratePathBody(String title) {
    return 'Replace \"$title\" with a new AI-generated career path. Your other paths and notes are kept.';
  }

  @override
  String get careerGenerate => 'Generate';

  @override
  String get careerRegenerate => 'Regenerate';

  @override
  String careerPathNumber(int number) {
    return 'Path $number';
  }

  @override
  String careerPathHeading(int number, String title) {
    return 'Path $number: $title';
  }

  @override
  String get careerPlaceholderBody =>
      'A career pathway will appear here once generated.';

  @override
  String get careerPlaceholderStartTitle => 'Starting point';

  @override
  String get careerPlaceholderStartBody =>
      'Your current experience and background.';

  @override
  String get careerPlaceholderCredsTitle => 'Build credentials';

  @override
  String get careerPlaceholderCredsBody =>
      'Licenses, training, and skills to develop.';

  @override
  String get careerPlaceholderTargetTitle => 'Target role';

  @override
  String get careerPlaceholderTargetBody =>
      'Your future career goal in the US.';

  @override
  String get careerCertifications => 'Certifications & licenses';

  @override
  String get careerSkills => 'Skills to develop';

  @override
  String get careerTimeEstimate => 'Time Estimate';

  @override
  String get careerStepCompleted => 'Completed';

  @override
  String get careerStepNow => 'Now';

  @override
  String careerStepNowWithDuration(String duration) {
    return 'Now ($duration)';
  }

  @override
  String get careerTimePending => 'Time estimate pending';

  @override
  String get careerUndo => 'Undo';

  @override
  String get careerMarkComplete => 'Mark complete';

  @override
  String get careerFinishStepAbove => 'Finish the step above first.';

  @override
  String get careerUndoLaterStep => 'Undo the later step first.';

  @override
  String get careerAskTitle => 'Ask about this path';

  @override
  String get careerAskSubtitle =>
      'Questions use this path\'s steps, notes, and your background. Answers stay on this page until you leave. Save anything you want to keep as a note.';

  @override
  String get careerAskHint =>
      'Ask about a step, license, or how to get started…';

  @override
  String get careerNotesTitle => 'Notes for this path';

  @override
  String get careerNotesSubtitle =>
      'Track progress on this pathway. Saved and shared with the AI.';

  @override
  String get careerNotesHint => 'What have you done for this path?';

  @override
  String get roadmapSettlementPlan =>
      'Your settlement plan based on your survey answers.';

  @override
  String get roadmapRegenerateAll => 'Regenerate all';

  @override
  String get roadmapRegenerateAllTitle => 'Regenerate entire roadmap?';

  @override
  String get roadmapRegenerateAllBody =>
      'This replaces all three sections with a fresh AI plan. Your section notes are kept.';

  @override
  String get roadmapCreating => 'Creating your personalized roadmap…';

  @override
  String get roadmapAnswerQuestions =>
      'Answer the questions below so we can finish your roadmap.';

  @override
  String get roadmapUpdating => 'Updating your roadmap…';

  @override
  String get roadmapGenerate => 'Generate Roadmap';

  @override
  String get roadmapNoRoadmap =>
      'No roadmap yet. Tap below to generate one from your survey.';

  @override
  String get roadmapEmptySurvey =>
      'Take the onboarding survey so we can build a personalized roadmap.';

  @override
  String roadmapRegenerateSectionTitle(String section) {
    return 'Regenerate $section?';
  }

  @override
  String get roadmapRegenerateSectionBody =>
      'This section will be replaced with a new AI-generated plan. Your notes for this section are kept.';

  @override
  String get roadmapAskTitle => 'Ask about this section';

  @override
  String get roadmapAskSubtitle =>
      'Questions use this section\'s checklist, notes, and your survey. Answers stay on this page until you leave. Save anything you want to keep as a note.';

  @override
  String get roadmapAskHint => 'Ask about a step in this section…';

  @override
  String get roadmapNotesTitle => 'Notes for this section';

  @override
  String get roadmapNotesSubtitle =>
      'Track progress on these steps. Saved and shared with the AI.';

  @override
  String get roadmapNotesHint => 'What have you done for this section?';

  @override
  String get roadmapNoChecklist => 'No checklist items yet.';

  @override
  String get roadmapCouldNotSaveNote => 'Could not save note.';

  @override
  String get roadmapCouldNotDeleteNote => 'Could not delete that note.';

  @override
  String get roadmapDeleteNoteTitle => 'Delete this note?';

  @override
  String get roadmapDeleteNoteBody =>
      'This removes the note from this section.';

  @override
  String get roadmapAiUnavailable => 'AI service is unavailable.';

  @override
  String get roadmapAiCouldNotAnswer => 'AI could not answer.';

  @override
  String get roadmapSectionFirstMonth => 'First Month';

  @override
  String get roadmapSectionFirstThreeMonths => 'First 3 Months';

  @override
  String get roadmapSectionFirstYear => 'First Year';

  @override
  String roadmapQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get roadmapOneQuestion => 'One quick question';

  @override
  String roadmapUpNext(String question) {
    return 'Up next: $question';
  }

  @override
  String get roadmapYourAnswer => 'Your answer';

  @override
  String get guideLoadError =>
      'This guide could not be loaded. Try again when you are online.';

  @override
  String get guideNoSections => 'This guide has no sections.';

  @override
  String guideSectionOf(int current, int total) {
    return 'Section $current of $total';
  }

  @override
  String get housingAskTitle => 'Ask about housing';

  @override
  String get housingAskHint => 'Type a question…';

  @override
  String get housingAskFollowUpHint => 'Ask a follow-up…';

  @override
  String get educationNavigatorTitle => 'Education Navigator';

  @override
  String get educationHubIntro =>
      'Learn how California schools work, then find nearby public and private schools plus trusted tutoring, library, and STEM programs.';

  @override
  String get educationBasicsTitle => 'Education basics';

  @override
  String get educationBasicsSubtitle =>
      'Enrollment, districts, grade levels, English learner support, and academic help.';

  @override
  String get educationFindTitle => 'Find schools & programs';

  @override
  String get educationFindSubtitle =>
      'Map and list of nearby California public and private schools, libraries, tutoring, and STEM programs.';

  @override
  String get healthcareNavigatorTitle => 'Healthcare Navigator';

  @override
  String get healthcareHubIntro =>
      'Learn how care works in California, then find trusted community health centers near you.';

  @override
  String get healthcareBasicsTitle => 'Healthcare basics';

  @override
  String get healthcareBasicsSubtitle =>
      'Insurance, how visits work, community health centers, and language help.';

  @override
  String get healthcareFindTitle => 'Find a clinic';

  @override
  String get healthcareFindSubtitle =>
      'Map and list of nearby HRSA community health centers by city or ZIP.';

  @override
  String get finderCityOrZipLabel => 'City or ZIP code';

  @override
  String get finderCityOrZipHint => 'e.g. Oakland or 94102';

  @override
  String get finderSetCityOrZip => 'Set a city or ZIP code';

  @override
  String finderNear(String location) {
    return 'Near: $location';
  }

  @override
  String get finderHideSearchOptions => 'Hide search options';

  @override
  String get finderResizeMap => 'Resize map';

  @override
  String get finderOpenWebsite => 'Open website';

  @override
  String finderKmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get clinicsSearchIntro =>
      'Search HRSA community health centers near a California city or ZIP. Pins are from the official federal directory.';

  @override
  String get clinicsFindButton => 'Find nearby clinics';

  @override
  String get clinicsSearchDetail => 'HRSA community health centers';

  @override
  String get clinicsEnterLocation =>
      'Enter a city or ZIP code to find nearby clinics.';

  @override
  String get clinicsNoResults =>
      'No community health centers found nearby. Try another California city or ZIP, or widen your search later.';

  @override
  String get clinicsLoadError => 'Could not load clinics. Try again shortly.';

  @override
  String get clinicsTypeFqhc => 'Federally Qualified Health Center (FQHC)';

  @override
  String get clinicsTypeFqhcLookAlike =>
      'Federally Qualified Health Center (FQHC) Look-Alike';

  @override
  String get englishSearchIntro =>
      'Find trusted adult schools, community colleges, and library ESL programs near a California city or ZIP.';

  @override
  String get englishFindButton => 'Find nearby classes';

  @override
  String get englishSearchDetail => 'Adult schools, colleges & libraries';

  @override
  String get englishEnterLocation =>
      'Enter a city or ZIP code to find nearby classes.';

  @override
  String get englishNoResults =>
      'No ESL resources found nearby yet. Try another California city or ZIP.';

  @override
  String get englishLoadError =>
      'Could not load English resources. Try again shortly.';

  @override
  String get englishSourceCurated =>
      'Source: curated California adult ed, colleges, and libraries';

  @override
  String englishSourceNamed(String source) {
    return 'Source: $source';
  }

  @override
  String get educationSearchIntro =>
      'Search California public and private schools from the official CDE directory, plus curated libraries, tutoring, and STEM programs.';

  @override
  String get educationFindButton => 'Find nearby';

  @override
  String get educationEnterLocation =>
      'Enter a city or ZIP code to find nearby schools.';

  @override
  String get educationNoResults =>
      'No schools or programs found nearby. Try another California city or ZIP, or change the filters.';

  @override
  String get educationLoadError =>
      'Could not load education resources. Try again.';

  @override
  String get educationLoadErrorShort =>
      'Could not load education resources. Try again shortly.';

  @override
  String get educationTypeLabel => 'Type';

  @override
  String get educationAllTypes => 'All types';

  @override
  String get educationKindSchools => 'Schools';

  @override
  String get educationKindPrograms => 'Programs & support';

  @override
  String get educationKindPublicSchools => 'Public schools';

  @override
  String get educationKindPrivateSchools => 'Private schools';

  @override
  String get educationKindEnrollmentHelp => 'Enrollment help';

  @override
  String get educationKindLibraries => 'Libraries';

  @override
  String get educationKindTutoring => 'Tutoring';

  @override
  String get educationKindStem => 'STEM / enrichment';

  @override
  String get educationAllGrades => 'All grades';

  @override
  String get educationGradeLabel => 'Grade';

  @override
  String get educationGradePk => 'PK';

  @override
  String get educationGrade12 => '12th';

  @override
  String educationGradeSingle(String grade) {
    return 'Grade $grade';
  }

  @override
  String educationGradesRange(String low, String high) {
    return 'Grades $low–$high';
  }

  @override
  String get educationMapBadge => 'CDE schools + programs';

  @override
  String get educationMoreInformation => 'More information';

  @override
  String get educationAiSummaryLabel => 'AI-generated school summary';

  @override
  String get educationAiSummaryReading =>
      'Reading official school information…';

  @override
  String get educationAiSummaryError =>
      'Could not generate this summary. Try again shortly.';

  @override
  String get educationAiSummaryClose => 'Close';

  @override
  String get educationAiSummaryCloseRetry => 'Close and try again';

  @override
  String get educationAiSummaryDisclaimer =>
      'This summary was generated by AI from official sources. It does not include ratings or parent reviews and may miss recent changes. Verify important details directly with the school.';

  @override
  String get educationAiSummaryHighlights => 'What the sources say';

  @override
  String get educationAiSummaryQuestions => 'Questions to ask the school';

  @override
  String get educationAiSummarySources => 'Sources';

  @override
  String get educationSourceCde => 'California School Directory';

  @override
  String get educationSourceWebsite => 'Official school website';

  @override
  String get educationTypeElementary => 'Elementary';

  @override
  String get educationTypeHighSchool => 'High School';

  @override
  String get educationTypeMiddle => 'Intermediate/Middle/Junior High';

  @override
  String get educationTypeElemHigh => 'Elementary-High Combination';

  @override
  String get educationTypeAdult => 'Adult';

  @override
  String get educationTypePreschool => 'Preschool';

  @override
  String get educationTypeUngraded => 'Ungraded';

  @override
  String get educationTypePrivateTuition => 'Private school (tuition based)';

  @override
  String get educationChipPublicSchool => 'Public school';

  @override
  String get educationChipPrivateSchool => 'Private school';

  @override
  String get educationChipLibrary => 'Public library';

  @override
  String get educationChipResource => 'Education resource';

  @override
  String get educationBandMiddle => 'Middle';

  @override
  String get educationBandHigh => 'High';

  @override
  String get educationGradeK => 'K';

  @override
  String get groupsIntro =>
      'Join a group to post, ask questions, and help other newcomers in California.';

  @override
  String get groupsDiscover => 'Discover';

  @override
  String get groupsMine => 'My groups';

  @override
  String groupsMineCount(int count) {
    return 'My groups ($count)';
  }

  @override
  String get groupsSuggest => 'Suggest a new group';

  @override
  String get groupsJoin => 'Join';

  @override
  String get groupsJoined => 'Joined';

  @override
  String get groupsLeave => 'Leave group';

  @override
  String get groupsSearch => 'Search';

  @override
  String get groupsSearchClear => 'Clear search';

  @override
  String get groupsFilterAll => 'All';

  @override
  String get groupsSearchNoMatch => 'No groups match your search.';

  @override
  String get groupsMineEmpty =>
      'You have not joined a group yet. Switch to Discover to find one.';

  @override
  String get groupsCategoryEmpty => 'No groups in this category yet.';

  @override
  String get groupsSuggestTitle => 'Suggest a group';

  @override
  String get groupsSuggestIntro =>
      'Propose a group for other newcomers in California. An admin reviews every suggestion before it is opened for people to join.';

  @override
  String get groupsSuggestNameLabel => 'Group name';

  @override
  String get groupsSuggestNameHint => 'e.g. Newcomers in Fresno';

  @override
  String get groupsSuggestCategory => 'Category';

  @override
  String get groupsSuggestPurposeLabel => 'What is this group for?';

  @override
  String get groupsSuggestPurposeHint =>
      'Who should join, and what will people talk about?';

  @override
  String get groupsSuggestSubmit => 'Submit for review';

  @override
  String get groupsSuggestSent =>
      'Suggestion sent. An admin will review it before the group appears.';

  @override
  String get groupsSuggestSendError =>
      'Could not send that suggestion. Try again.';

  @override
  String get groupsSuggestNameRequired => 'Give the group a name.';

  @override
  String get groupsSuggestDescriptionRequired => 'Add a short description.';

  @override
  String get groupsCategoryParents => 'Parents';

  @override
  String get groupsCategoryJobs => 'Jobs';

  @override
  String get groupsCategoryLanguage => 'English';

  @override
  String get groupsCategoryCareers => 'Careers';

  @override
  String get groupsCategoryCulture => 'Culture';

  @override
  String get groupsCategoryHousing => 'Housing';

  @override
  String get groupsCategoryOther => 'Other';

  @override
  String get groupsFallbackTitle => 'Support group';

  @override
  String get groupsLoadError => 'Could not load this group.';

  @override
  String get groupsUnavailable => 'This group is no longer available.';

  @override
  String get groupsRemovedAdmin => 'This group was removed by an admin.';

  @override
  String groupsRemovedWithReason(String reason) {
    return 'This group was removed. Reason: $reason';
  }

  @override
  String get groupsMemberOne => '1 member';

  @override
  String groupsMemberCount(int count) {
    return '$count members';
  }

  @override
  String get groupsPrivacyNotice =>
      'Posts and questions are private to members. They are checked for safety before others can see them. Be kind, and do not paste ID numbers, passwords, or account numbers.';

  @override
  String get groupsNewPost => 'New post';

  @override
  String get groupsAskQuestion => 'Ask a question';

  @override
  String get groupsJoinToRead => 'Join to read posts and reply';

  @override
  String get groupsJoinPrompt =>
      'Only members can see posts and questions in this group. Join when you are ready to take part.';

  @override
  String get groupsJoinGroup => 'Join group';

  @override
  String get groupsLeaveShort => 'Leave';

  @override
  String get groupsLeaveConfirmTitle => 'Leave this group?';

  @override
  String groupsLeaveConfirmBody(String title) {
    return 'You will stop seeing posts in \"$title\". You can join again later.';
  }

  @override
  String get groupsPostsLoadError =>
      'Could not load posts. Join the group and try again.';

  @override
  String get groupsNoPostsYet =>
      'No posts yet. Share something, or ask a question the group can help with.';

  @override
  String get groupsYou => 'You';

  @override
  String get groupsPostOptions => 'Post options';

  @override
  String get groupsReplyOptions => 'Reply options';

  @override
  String get groupsKindPost => 'Post';

  @override
  String get groupsKindQuestion => 'Question';

  @override
  String get groupsNoAnswersYet => 'No answers yet';

  @override
  String get groupsNoRepliesYet => 'No replies yet';

  @override
  String get groupsReplyOne => '1 reply';

  @override
  String groupsReplyMany(int count) {
    return '$count replies';
  }

  @override
  String get groupsComposePostIntro =>
      'Share an update, a tip, or something that might help others in this group.';

  @override
  String get groupsComposeQuestionIntro =>
      'Ask the group something they can help with. Other members can reply on this thread.';

  @override
  String get groupsComposeGuidelines =>
      'Posts are checked for safety before others can see them. Do not paste ID numbers, passwords, or account numbers. Talking about benefits, visas, and papers is fine.';

  @override
  String get groupsComposeTitleLabel => 'Title';

  @override
  String get groupsComposeQuestionLabel => 'Question';

  @override
  String get groupsComposeTitleHint => 'e.g. A resume tip that helped me';

  @override
  String get groupsComposeQuestionHint =>
      'e.g. How did you find a pediatrician?';

  @override
  String get groupsComposeBodyLabel => 'Description';

  @override
  String get groupsComposeDetailsLabel => 'Details (optional)';

  @override
  String get groupsComposeBodyHint =>
      'Add the story, a link, or anything useful.';

  @override
  String get groupsComposeDetailsHint =>
      'Add any details that would help people answer.';

  @override
  String get groupsAddPhotos => 'Add photos';

  @override
  String get groupsAdd => 'Add';

  @override
  String groupsPhotoCount(int count, int max) {
    return '$count of $max photos';
  }

  @override
  String get groupsPublishPost => 'Publish post';

  @override
  String get groupsPostQuestion => 'Post question';

  @override
  String get groupsPhotoLibrary => 'Photo library';

  @override
  String get groupsCamera => 'Camera';

  @override
  String get groupsPhotoOpenError =>
      'Could not open that photo. Try another one.';

  @override
  String get groupsPublishError => 'Could not publish that. Try again.';

  @override
  String get groupsRemovePhoto => 'Remove photo';

  @override
  String get groupsPostLoadError => 'Could not load this post.';

  @override
  String get groupsPostRemoved => 'This post was removed.';

  @override
  String get groupsAnswers => 'Answers';

  @override
  String get groupsReplies => 'Replies';

  @override
  String get groupsRepliesLoadError => 'Could not load replies.';

  @override
  String get groupsNoAnswersHelp => 'No answers yet. Be the first to help.';

  @override
  String get groupsNoRepliesHelp => 'No replies yet. Start the conversation.';

  @override
  String get groupsWriteAnswer => 'Write an answer…';

  @override
  String get groupsWriteReply => 'Write a reply…';

  @override
  String get groupsEditReply => 'Edit reply';

  @override
  String get groupsWriteReplyFirst => 'Write a reply first.';

  @override
  String get groupsDeleteReplyTitle => 'Delete this reply?';

  @override
  String get groupsDeleteReplyBody => 'This cannot be undone.';

  @override
  String get groupsEdit => 'Edit';

  @override
  String get groupsEdited => 'Edited';

  @override
  String get groupsReply => 'Reply';

  @override
  String get groupsDeletePostTitle => 'Delete this post?';

  @override
  String get groupsDeletePostBody =>
      'Replies will be removed too. This cannot be undone.';

  @override
  String get groupsRemovePostTitle => 'Remove this post?';

  @override
  String get groupsRemovePostBody =>
      'The post will be hidden from the group. The author has 7 days to appeal. If they do not, or a moderator declines the appeal, it will be deleted.';

  @override
  String get groupsRemovePostReason => 'Reason';

  @override
  String get groupsRemovePostHint => 'e.g. This broke the group rules.';

  @override
  String get groupsRemovePostReasonRequired =>
      'Please say why this post is being removed.';

  @override
  String get groupsRemovePostAction => 'Remove post';

  @override
  String get groupsModerationChecking => 'The AI is checking this';

  @override
  String get groupsModerationPendingBody =>
      'We are checking this before others can see it. It should appear in a moment.';

  @override
  String get groupsModerationHidden => 'Hidden from the group';

  @override
  String get groupsModerationHiddenPii =>
      'This looks like a real ID or account number. Please remove the number and try again. You can still talk about the topic.';

  @override
  String get groupsModerationHiddenScam =>
      'This looks like it could be asking people for money or personal details. Please keep the group free of sales and suspicious offers.';

  @override
  String get groupsModerationHiddenHate =>
      'Please keep this group respectful. Unkind or hateful posts are not allowed.';

  @override
  String get groupsModerationHiddenHarassment =>
      'Please keep this group respectful. Harassment is not allowed.';

  @override
  String get groupsModerationHiddenSexual =>
      'This post does not fit a family support group. Please keep posts appropriate.';

  @override
  String get groupsModerationHiddenSelfHarm =>
      'If you are in crisis, call or text 988 in the US. This was hidden because it may include harmful content.';

  @override
  String get groupsModerationHiddenViolence =>
      'Violent content is not allowed in this group.';

  @override
  String get groupsModerationHiddenGeneric =>
      'This was hidden because it did not meet community guidelines. Please rewrite it and try again.';

  @override
  String get groupsAppealSent => 'Appeal sent';

  @override
  String groupsReasonPrefix(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get groupsHiddenByAdmin => 'An admin hid this post.';

  @override
  String groupsDeletedAfter(String deadline) {
    return 'It will be deleted after $deadline unless an appeal is approved.';
  }

  @override
  String get groupsAppealPendingReview =>
      'A moderator will review your appeal.';

  @override
  String get groupsAppeal => 'Appeal';

  @override
  String get groupsAppealTitle => 'Appeal this removal?';

  @override
  String get groupsAppealIntro =>
      'A moderator will review it. If they agree, the post will show in the group again.';

  @override
  String get groupsAppealLabel => 'Why should it stay? (optional)';

  @override
  String get groupsSendAppeal => 'Send appeal';

  @override
  String get groupsNoticeDismiss => 'Dismiss';

  @override
  String get groupsNoticeAppealReviewing => 'We\'re reviewing your appeal';

  @override
  String groupsNoticeStillHidden(String postTitle, String groupTitle) {
    return '\"$postTitle\" in $groupTitle is still hidden.';
  }

  @override
  String get groupsNoticePostBack => 'Your post is back';

  @override
  String groupsNoticeVisibleAgain(String postTitle, String groupTitle) {
    return '\"$postTitle\" in $groupTitle is visible to the group again.';
  }

  @override
  String get groupsNoticeAppealDeclined => 'Your appeal was declined';

  @override
  String groupsNoticeWasRemoved(String postTitle, String groupTitle) {
    return '\"$postTitle\" in $groupTitle was removed.';
  }

  @override
  String get groupsNoticePostRemovedTitle => 'Your post was removed';

  @override
  String groupsNoticeDeletedAfterWindow(String postTitle, String groupTitle) {
    return '\"$postTitle\" in $groupTitle was deleted after the appeal window ended.';
  }

  @override
  String get groupsNoticePostHiddenTitle => 'Your post was hidden';

  @override
  String groupsNoticeHiddenReason(
    String postTitle,
    String groupTitle,
    String reason,
  ) {
    return '\"$postTitle\" in $groupTitle was hidden. Reason: $reason';
  }

  @override
  String groupsNoticeHiddenAdmin(String postTitle, String groupTitle) {
    return '\"$postTitle\" in $groupTitle was hidden by an admin.';
  }

  @override
  String groupsNoticeAppealUntil(String deadline) {
    return 'You can appeal until $deadline.';
  }
}
