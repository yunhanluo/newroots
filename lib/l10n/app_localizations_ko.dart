// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'NewRoots';

  @override
  String get tagline => '도착에서 소속까지.';

  @override
  String get navHome => '홈';

  @override
  String get navScamShield => 'ScamShield';

  @override
  String get navProfile => '프로필';

  @override
  String get featureRoadmap => '정착 계획';

  @override
  String get featureHousing => '주거';

  @override
  String get featureCareer => '직업 연결';

  @override
  String get featureEnglish => '영어 학습';

  @override
  String get featureEducation => '교육';

  @override
  String get featureHealthcare => '의료';

  @override
  String get featureSupportGroups => '지원 모임';

  @override
  String get featureScamShield => 'ScamShield';

  @override
  String get featureSafety => '안전 안내';

  @override
  String get placeholderComingSoon => '곧 제공됩니다';

  @override
  String get disclaimer => 'NewRoots는 안내 도구이며 법률, 의료, 재정 전문가를 대체하지 않습니다.';

  @override
  String get actionSave => '저장';

  @override
  String get actionCancel => '취소';

  @override
  String actionEdit(String label) {
    return '$label 수정';
  }

  @override
  String get actionSignOut => '로그아웃';

  @override
  String get actionLogIn => '로그인';

  @override
  String get actionSignUp => '가입';

  @override
  String get actionCreateAccount => '계정 만들기';

  @override
  String get actionStart => '시작';

  @override
  String get actionPrevious => '이전';

  @override
  String get actionNext => '다음';

  @override
  String get actionFinish => '완료';

  @override
  String get actionSkipQuestion => '이 질문 건너뛰기';

  @override
  String get actionSkipForNow => '지금은 건너뛰기';

  @override
  String get actionContinueSurvey => '설문 계속하기';

  @override
  String get actionStartSurvey => '설문 시작';

  @override
  String get actionSkipSurvey => '설문 건너뛰기';

  @override
  String get actionTakeSurvey => '설문 참여';

  @override
  String get actionRetakeSurvey => '설문 다시 하기';

  @override
  String get authWelcomeBack => '다시 오신 것을 환영합니다. 로그인하고 계속하세요.';

  @override
  String get authCreateAccountSubtitle => '계정을 만들어 시작하세요.';

  @override
  String get authEmail => '이메일';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authConfirmPassword => '비밀번호 확인';

  @override
  String get authNoAccount => '계정이 없으신가요?';

  @override
  String get authHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get authWhatIsNewRoots => 'NewRoots란?';

  @override
  String get authPrivacyPolicy => '개인정보 처리방침';

  @override
  String get authEmailPasswordRequired => '이메일과 비밀번호를 입력하세요.';

  @override
  String get authFillAllFields => '모든 항목을 입력하세요.';

  @override
  String get authPasswordTooShort => '비밀번호는 6자 이상이어야 합니다.';

  @override
  String get authPasswordsDoNotMatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get aboutTitle => '소개';

  @override
  String get aboutBody =>
      '미국에는 기회가 많습니다.\n\n경제적으로 강하고, 많은 나라에 영향을 준 헌법을 가지고 있으며, 다양한 문화가 있습니다.\n\n하지만 새로운 나라에서 자리를 잡기는 어렵습니다. 특히 미국에서는 더 그렇습니다.\n\nNewRoots가 도와드립니다. 자리를 찾고,\n새로운 관계를 만들고, 함정을 피하고, 가까운 자원을 쓰도록 돕습니다.\n미국이 어떤 나라인지 함께 알아보세요.\n\n새로운 뿌리를 찾으세요.';

  @override
  String get language => '언어';

  @override
  String get preferredLanguage => '선호 언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get editPreferredLanguage => '선호 언어 수정';

  @override
  String get profileTitle => '프로필';

  @override
  String get profileSignedIn => '로그인됨';

  @override
  String get profileLocation => '거주 지역';

  @override
  String get profileChildrenCount => '자녀 수';

  @override
  String get profilePriorities => '우선순위';

  @override
  String get profileEmployment => '직업 배경';

  @override
  String get profileChildrenAges => '자녀 나이';

  @override
  String get profileSkipped => '건너뜀';

  @override
  String get profileNoSurvey => '아직 설문 정보가 없습니다.';

  @override
  String get profileReviewSuggestions => '모임 제안 검토';

  @override
  String get profileAdmin => '관리자';

  @override
  String get priorityHousing => '주거';

  @override
  String get priorityEmployment => '취업';

  @override
  String get priorityEducation => '교육';

  @override
  String get priorityHealthcare => '의료';

  @override
  String get priorityEnglish => '영어 학습';

  @override
  String get prioritySafety => '안전';

  @override
  String get priorityOther => '기타';

  @override
  String get priorityOtherHint => '우선순위를 적어 주세요';

  @override
  String get onboardingTitle => '초기 설문';

  @override
  String get onboardingIntro => '맞춤 도움을 위해 짧은 설문을 작성해 주세요.';

  @override
  String get onboardingSkipTitle => '초기 설문을 건너뛸까요?';

  @override
  String get onboardingSkipBody =>
      '설문은 상황을 이해하고 더 나은 도움을 주는 데 필요합니다. 개별 질문은 건너뛸 수 있습니다.';

  @override
  String get onboardingSurveyLater => '설문은 프로필 페이지에서 언제든지 할 수 있습니다.';

  @override
  String get onboardingQuestionLanguage => '선호 언어';

  @override
  String get onboardingQuestionLocation => '어디에 살고 계신가요?';

  @override
  String get onboardingQuestionChildren => '자녀가 몇 명인가요?';

  @override
  String get onboardingQuestionPriorities => '지금 가장 중요한 것';

  @override
  String get onboardingQuestionEmployment => '직업 배경';

  @override
  String get onboardingQuestionAges => '자녀 나이';

  @override
  String get onboardingSelectChildren => '자녀 수 선택';

  @override
  String get onboardingCityOrZip => '도시 또는 우편번호';

  @override
  String get scamIntro =>
      '수상한 문자, 이메일, 일자리, 임대 광고, 정부처럼 보이는 내용을 확인하세요. ScamShield가 왜 위험할 수 있는지 설명하므로 다음에 무엇을 할지 결정할 수 있습니다.';

  @override
  String get scamWhatChecking => '무엇을 확인하고 있나요?';

  @override
  String get scamPasteLabel => '메시지 또는 광고 붙여넣기';

  @override
  String get scamPasteHint => '전체 내용을 여기에 붙여넣으세요…';

  @override
  String get scamAddScreenshot => '스크린샷 추가';

  @override
  String get scamAnalyze => '사기 위험 분석';

  @override
  String get scamPastChecks => '이전 확인';

  @override
  String get scamDropHint => '스크린샷을 여기에 끌어다 놓으세요';

  @override
  String get scamBrowseHint => '또는 눌러서 파일을 선택하세요';

  @override
  String get scamReplace => '바꾸기';

  @override
  String get scamRemove => '삭제';

  @override
  String get scamPastLoadError => '이전 확인을 지금 불러올 수 없습니다.';

  @override
  String get scamPastEmpty => '아직 확인한 내용이 없습니다. 메시지를 분석하면 여기에 저장됩니다.';

  @override
  String get scamScreenshotCheck => '스크린샷 확인';

  @override
  String get scamDelete => '삭제';

  @override
  String get scamDeleteTitle => '이 확인을 삭제할까요?';

  @override
  String get scamDeleteBody => '이전 확인에서 저장된 보고서가 삭제됩니다.';

  @override
  String get scamNeedInput => '분석하려면 메시지를 붙여넣거나 스크린샷을 추가하세요.';

  @override
  String get scamImageOpenError => '그 이미지를 열 수 없습니다. 다른 사진을 시도하세요.';

  @override
  String get scamDeleteError => '그 확인을 삭제할 수 없습니다. 다시 시도하세요.';

  @override
  String get scamChooseGallery => '갤러리에서 선택';

  @override
  String get scamTakePhoto => '사진 찍기';

  @override
  String get scamScreenshot => '스크린샷';

  @override
  String get scamRiskLow => '낮은 위험';

  @override
  String get scamRiskModerate => '보통 위험';

  @override
  String get scamRiskHigh => '높은 위험';

  @override
  String get scamYesterday => '어제';

  @override
  String scamDaysAgo(int count) {
    return '$count일 전';
  }

  @override
  String get scamCategorySms => '문자 메시지';

  @override
  String get scamCategoryEmail => '이메일';

  @override
  String get scamCategoryJob => '일자리 제안';

  @override
  String get scamCategoryRental => '임대 광고';

  @override
  String get scamCategoryGovernment => '정부';

  @override
  String scamUpdatedFrom(String level) {
    return '$level에서 업데이트됨';
  }

  @override
  String get scamWhatYouSubmitted => '제출한 내용';

  @override
  String get scamExpand => '펼치기';

  @override
  String get scamCollapse => '접기';

  @override
  String get scamMessage => '메시지';

  @override
  String scamMessageNumber(int number) {
    return '메시지 $number';
  }

  @override
  String get scamWhyRisky => '왜 위험할 수 있는지';

  @override
  String get scamWhatYouCanDo => '할 수 있는 일';

  @override
  String get scamAddMessage => '메시지 추가';

  @override
  String get scamFollowUpTitle => '대화에서 다음 메시지 추가';

  @override
  String get scamFollowUpHint => '다음 문자나 이메일을 붙여넣으세요…';

  @override
  String get scamReevaluate => '다시 평가';

  @override
  String get scamFollowUpNeedInput => '다음 메시지를 붙여넣거나 스크린샷을 추가하세요.';

  @override
  String get scamFollowUpImageError => '그 이미지를 열 수 없습니다.';

  @override
  String get scamScreenshotAttached => '스크린샷 첨부됨';

  @override
  String scamThreadCount(int count) {
    return '이 대화에 메시지 $count개';
  }

  @override
  String get actionSend => '보내기';

  @override
  String get actionDelete => '삭제';

  @override
  String get followupAsk => '질문';

  @override
  String get followupSaveNote => '메모 저장';

  @override
  String get followupDeleteNote => '메모 삭제';

  @override
  String followupQuestion(String question) {
    return 'Q: $question';
  }

  @override
  String get careerSignIn => '로그인하여 진로 경로를 살펴보세요.';

  @override
  String get careerAddPriorJob => '프로필 설문에 이전 직업을 추가하거나, 아래 메모에 경력을 적어 주세요.';

  @override
  String get careerGoToProfile => '프로필로 이동';

  @override
  String get careerPriorEmployment => '이전 경력 (설문에서)';

  @override
  String get careerAdditionalBackground => '추가 배경';

  @override
  String get careerAdditionalBackgroundHelp =>
      '기술, 학력, 자격증, 언어, 진로 목표를 적으면 AI가 더 나은 경로를 제안합니다.';

  @override
  String get careerAdditionalBackgroundHint =>
      '예: 전기공 5년, 직업 디플로마, 태양광 설치에 관심…';

  @override
  String get careerGenerateAll => '진로 경로 만들기';

  @override
  String get careerRegenerateAll => '모든 경로 다시 만들기';

  @override
  String get careerGenerating => '진로 경로를 작성하는 중…';

  @override
  String get careerNeedBackground => '먼저 기술이나 학력에 대한 메모를 추가하세요.';

  @override
  String get careerCouldNotSaveChecklist => '체크리스트 진행 상황을 저장하지 못했습니다.';

  @override
  String get careerCouldNotSaveStep => '단계 진행 상황을 저장하지 못했습니다.';

  @override
  String get careerCouldNotSaveNote => '메모를 저장하지 못했습니다.';

  @override
  String get careerCouldNotDeleteNote => '그 메모를 삭제하지 못했습니다.';

  @override
  String get careerDeleteNoteTitle => '이 메모를 삭제할까요?';

  @override
  String get careerDeleteNoteBody => '이 진로 경로에서 메모가 삭제됩니다.';

  @override
  String get careerGeneratePathTitle => '이 경로를 만들까요?';

  @override
  String get careerRegeneratePathTitle => '이 경로를 다시 만들까요?';

  @override
  String careerGeneratePathBody(int number) {
    return '경로 $number에 대한 AI 진로 경로를 만듭니다. 다른 경로와 메모는 유지됩니다.';
  }

  @override
  String careerRegeneratePathBody(String title) {
    return '\"$title\"을(를) 새 AI 진로 경로로 바꿉니다. 다른 경로와 메모는 유지됩니다.';
  }

  @override
  String get careerGenerate => '만들기';

  @override
  String get careerRegenerate => '다시 만들기';

  @override
  String careerPathNumber(int number) {
    return '경로 $number';
  }

  @override
  String careerPathHeading(int number, String title) {
    return '경로 $number: $title';
  }

  @override
  String get careerPlaceholderBody => '생성되면 여기에 진로 경로가 표시됩니다.';

  @override
  String get careerPlaceholderStartTitle => '시작점';

  @override
  String get careerPlaceholderStartBody => '현재 경험과 배경.';

  @override
  String get careerPlaceholderCredsTitle => '자격 쌓기';

  @override
  String get careerPlaceholderCredsBody => '면허, 교육, 키워야 할 기술.';

  @override
  String get careerPlaceholderTargetTitle => '목표 직무';

  @override
  String get careerPlaceholderTargetBody => '미국에서의 진로 목표.';

  @override
  String get careerCertifications => '자격증 및 면허';

  @override
  String get careerSkills => '키워야 할 기술';

  @override
  String get careerTimeEstimate => '예상 시간';

  @override
  String get careerStepCompleted => '완료됨';

  @override
  String get careerStepNow => '지금';

  @override
  String careerStepNowWithDuration(String duration) {
    return '지금 ($duration)';
  }

  @override
  String get careerTimePending => '예상 시간 없음';

  @override
  String get careerUndo => '실행 취소';

  @override
  String get careerMarkComplete => '완료로 표시';

  @override
  String get careerFinishStepAbove => '위의 단계를 먼저 완료하세요.';

  @override
  String get careerUndoLaterStep => '나중 단계를 먼저 실행 취소하세요.';

  @override
  String get careerAskTitle => '이 경로에 질문하기';

  @override
  String get careerAskSubtitle =>
      '질문은 이 경로의 단계, 메모, 배경을 사용합니다. 답변은 이 페이지를 떠날 때까지 유지됩니다. 남기고 싶은 내용은 메모로 저장하세요.';

  @override
  String get careerAskHint => '단계, 면허, 시작 방법에 대해 물어보세요…';

  @override
  String get careerNotesTitle => '이 경로 메모';

  @override
  String get careerNotesSubtitle => '이 경로의 진행 상황을 기록합니다. 저장되며 AI와 공유됩니다.';

  @override
  String get careerNotesHint => '이 경로에서 무엇을 했나요?';

  @override
  String get roadmapSettlementPlan => '설문 답변을 바탕으로 한 정착 계획입니다.';

  @override
  String get roadmapRegenerateAll => '전체 다시 만들기';

  @override
  String get roadmapRegenerateAllTitle => '전체 로드맵을 다시 만들까요?';

  @override
  String get roadmapRegenerateAllBody => '세 구간이 새 AI 계획으로 바뀝니다. 구간별 메모는 유지됩니다.';

  @override
  String get roadmapCreating => '맞춤 로드맵을 만드는 중…';

  @override
  String get roadmapAnswerQuestions => '아래 질문에 답해 로드맵을 완성해 주세요.';

  @override
  String get roadmapUpdating => '로드맵을 업데이트하는 중…';

  @override
  String get roadmapGenerate => '로드맵 만들기';

  @override
  String get roadmapNoRoadmap => '아직 로드맵이 없습니다. 아래를 눌러 설문으로 만드세요.';

  @override
  String get roadmapEmptySurvey => '맞춤 로드맵을 만들려면 온보딩 설문을 작성하세요.';

  @override
  String roadmapRegenerateSectionTitle(String section) {
    return '$section을(를) 다시 만들까요?';
  }

  @override
  String get roadmapRegenerateSectionBody =>
      '이 구간이 새 AI 계획으로 바뀝니다. 이 구간의 메모는 유지됩니다.';

  @override
  String get roadmapAskTitle => '이 구간에 질문하기';

  @override
  String get roadmapAskSubtitle =>
      '질문은 이 구간의 체크리스트, 메모, 설문을 사용합니다. 답변은 이 페이지를 떠날 때까지 유지됩니다. 남기고 싶은 내용은 메모로 저장하세요.';

  @override
  String get roadmapAskHint => '이 구간의 단계에 대해 물어보세요…';

  @override
  String get roadmapNotesTitle => '이 구간 메모';

  @override
  String get roadmapNotesSubtitle => '이 단계들의 진행 상황을 기록합니다. 저장되며 AI와 공유됩니다.';

  @override
  String get roadmapNotesHint => '이 구간에서 무엇을 했나요?';

  @override
  String get roadmapNoChecklist => '아직 체크리스트 항목이 없습니다.';

  @override
  String get roadmapCouldNotSaveNote => '메모를 저장하지 못했습니다.';

  @override
  String get roadmapCouldNotDeleteNote => '그 메모를 삭제하지 못했습니다.';

  @override
  String get roadmapDeleteNoteTitle => '이 메모를 삭제할까요?';

  @override
  String get roadmapDeleteNoteBody => '이 구간에서 메모가 삭제됩니다.';

  @override
  String get roadmapAiUnavailable => 'AI 서비스를 사용할 수 없습니다.';

  @override
  String get roadmapAiCouldNotAnswer => 'AI가 답할 수 없습니다.';

  @override
  String get roadmapSectionFirstMonth => '첫 달';

  @override
  String get roadmapSectionFirstThreeMonths => '처음 3개월';

  @override
  String get roadmapSectionFirstYear => '첫 해';

  @override
  String roadmapQuestionOf(int current, int total) {
    return '질문 $current / $total';
  }

  @override
  String get roadmapOneQuestion => '간단한 질문 하나';

  @override
  String roadmapUpNext(String question) {
    return '다음: $question';
  }

  @override
  String get roadmapYourAnswer => '답변';

  @override
  String get guideLoadError => '이 가이드를 불러올 수 없습니다. 인터넷에 연결된 뒤 다시 시도하세요.';

  @override
  String get guideNoSections => '이 가이드에는 구간이 없습니다.';

  @override
  String guideSectionOf(int current, int total) {
    return '구간 $current / $total';
  }

  @override
  String get housingAskTitle => '주거에 대해 묻기';

  @override
  String get housingAskHint => '질문을 입력하세요…';

  @override
  String get housingAskFollowUpHint => '이어서 질문하기…';
}
