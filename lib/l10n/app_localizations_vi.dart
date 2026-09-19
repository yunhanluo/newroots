// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'NewRoots';

  @override
  String get tagline => 'Từ khi đến, đến khi thuộc về.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navScamShield => 'ScamShield';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get featureRoadmap => 'Lộ trình hòa nhập';

  @override
  String get featureHousing => 'Nhà ở';

  @override
  String get featureCareer => 'Cầu nối nghề nghiệp';

  @override
  String get featureEnglish => 'Học tiếng Anh';

  @override
  String get featureEducation => 'Giáo dục';

  @override
  String get featureHealthcare => 'Y tế';

  @override
  String get featureSupportGroups => 'Nhóm hỗ trợ';

  @override
  String get featureScamShield => 'ScamShield';

  @override
  String get featureSafety => 'Hướng dẫn an toàn';

  @override
  String get placeholderComingSoon => 'Sắp ra mắt';

  @override
  String get disclaimer =>
      'NewRoots là công cụ hướng dẫn, không thay thế chuyên gia pháp lý, y tế hoặc tài chính.';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionCancel => 'Hủy';

  @override
  String actionEdit(String label) {
    return 'Sửa $label';
  }

  @override
  String get actionSignOut => 'Đăng xuất';

  @override
  String get actionLogIn => 'Đăng nhập';

  @override
  String get actionSignUp => 'Đăng ký';

  @override
  String get actionCreateAccount => 'Tạo tài khoản';

  @override
  String get actionStart => 'Bắt đầu';

  @override
  String get actionPrevious => 'Trước';

  @override
  String get actionNext => 'Tiếp';

  @override
  String get actionFinish => 'Hoàn tất';

  @override
  String get actionSkipQuestion => 'Bỏ qua câu hỏi';

  @override
  String get actionSkipForNow => 'Bỏ qua lúc này';

  @override
  String get actionContinueSurvey => 'Tiếp tục khảo sát';

  @override
  String get actionStartSurvey => 'Bắt đầu khảo sát';

  @override
  String get actionSkipSurvey => 'Bỏ qua khảo sát';

  @override
  String get actionTakeSurvey => 'Làm khảo sát';

  @override
  String get actionRetakeSurvey => 'Làm lại khảo sát';

  @override
  String get authWelcomeBack => 'Chào mừng trở lại. Đăng nhập để tiếp tục.';

  @override
  String get authCreateAccountSubtitle => 'Tạo tài khoản để bắt đầu.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get authNoAccount => 'Chưa có tài khoản?';

  @override
  String get authHaveAccount => 'Đã có tài khoản?';

  @override
  String get authPrivacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get authEmailPasswordRequired => 'Vui lòng nhập email và mật khẩu.';

  @override
  String get authFillAllFields => 'Vui lòng điền tất cả các mục.';

  @override
  String get authPasswordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự.';

  @override
  String get authPasswordsDoNotMatch => 'Mật khẩu không khớp.';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get preferredLanguage => 'Ngôn ngữ ưa dùng';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get editPreferredLanguage => 'Sửa ngôn ngữ ưa dùng';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get profileSignedIn => 'Đã đăng nhập';

  @override
  String get profileLocation => 'Nơi ở';

  @override
  String get profileChildrenCount => 'Số con';

  @override
  String get profilePriorities => 'Ưu tiên hàng đầu';

  @override
  String get profileEmployment => 'Kinh nghiệm làm việc';

  @override
  String get profileChildrenAges => 'Tuổi của con';

  @override
  String get profileSkipped => 'Đã bỏ qua';

  @override
  String get profileNoSurvey => 'Chưa có dữ liệu khảo sát.';

  @override
  String get profileReviewSuggestions => 'Xem đề xuất nhóm';

  @override
  String get profileAdmin => 'Quản trị';

  @override
  String get priorityHousing => 'Nhà ở';

  @override
  String get priorityEmployment => 'Việc làm';

  @override
  String get priorityEducation => 'Giáo dục';

  @override
  String get priorityHealthcare => 'Y tế';

  @override
  String get priorityEnglish => 'Học tiếng Anh';

  @override
  String get prioritySafety => 'An toàn';

  @override
  String get priorityOther => 'Khác';

  @override
  String get priorityOtherHint => 'Mô tả ưu tiên của bạn';

  @override
  String get onboardingTitle => 'Khảo sát ban đầu';

  @override
  String get onboardingIntro =>
      'Hãy trả lời khảo sát ngắn để cá nhân hóa ứng dụng.';

  @override
  String get onboardingSkipTitle => 'Bỏ qua khảo sát ban đầu?';

  @override
  String get onboardingSkipBody =>
      'Khảo sát giúp chúng tôi hiểu hoàn cảnh của bạn và đưa ra hỗ trợ tốt hơn (bạn có thể bỏ qua từng câu).';

  @override
  String get onboardingSurveyLater =>
      'Bạn có thể làm khảo sát bất cứ lúc nào trên trang hồ sơ.';

  @override
  String get onboardingQuestionLanguage => 'Ngôn ngữ ưa dùng';

  @override
  String get onboardingQuestionLocation => 'Bạn đang sống ở đâu?';

  @override
  String get onboardingQuestionChildren => 'Bạn có bao nhiêu con?';

  @override
  String get onboardingQuestionPriorities => 'Ưu tiên hiện tại';

  @override
  String get onboardingQuestionEmployment => 'Kinh nghiệm làm việc';

  @override
  String get onboardingQuestionAges => 'Tuổi của con';

  @override
  String get onboardingSelectChildren => 'Chọn số con';

  @override
  String get onboardingCityOrZip => 'Thành phố hoặc mã ZIP';

  @override
  String get scamIntro =>
      'Kiểm tra tin nhắn, email, việc làm, quảng cáo thuê nhà và nội dung giống cơ quan nhà nước. ScamShield giải thích vì sao có thể rủi ro để bạn quyết định bước tiếp theo.';

  @override
  String get scamWhatChecking => 'Bạn đang kiểm tra gì?';

  @override
  String get scamPasteLabel => 'Dán tin nhắn hoặc quảng cáo';

  @override
  String get scamPasteHint => 'Dán toàn bộ nội dung vào đây…';

  @override
  String get scamAddScreenshot => 'Thêm ảnh chụp màn hình';

  @override
  String get scamAnalyze => 'Phân tích nguy cơ lừa đảo';

  @override
  String get scamPastChecks => 'Lần kiểm tra trước';

  @override
  String get scamDropHint => 'Kéo thả ảnh chụp màn hình vào đây';

  @override
  String get scamBrowseHint => 'hoặc nhấn để chọn tệp';

  @override
  String get scamReplace => 'Đổi';

  @override
  String get scamRemove => 'Gỡ';

  @override
  String get scamPastLoadError => 'Không tải được các lần kiểm tra trước.';

  @override
  String get scamPastEmpty =>
      'Chưa có lần kiểm tra nào. Phân tích một tin nhắn để lưu tại đây.';

  @override
  String get scamScreenshotCheck => 'Kiểm tra ảnh chụp màn hình';

  @override
  String get scamDelete => 'Xóa';

  @override
  String get scamDeleteTitle => 'Xóa lần kiểm tra này?';

  @override
  String get scamDeleteBody =>
      'Thao tác này gỡ báo cáo đã lưu khỏi các lần kiểm tra trước.';

  @override
  String get scamNeedInput =>
      'Hãy dán tin nhắn hoặc thêm ảnh chụp màn hình để phân tích.';

  @override
  String get scamImageOpenError => 'Không mở được ảnh đó. Hãy thử ảnh khác.';

  @override
  String get scamDeleteError => 'Không xóa được lần kiểm tra đó. Hãy thử lại.';

  @override
  String get scamChooseGallery => 'Chọn từ thư viện';

  @override
  String get scamTakePhoto => 'Chụp ảnh';

  @override
  String get scamScreenshot => 'Ảnh chụp màn hình';

  @override
  String get scamRiskLow => 'Rủi ro thấp';

  @override
  String get scamRiskModerate => 'Rủi ro trung bình';

  @override
  String get scamRiskHigh => 'Rủi ro cao';

  @override
  String get scamYesterday => 'Hôm qua';

  @override
  String scamDaysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get scamCategorySms => 'Tin nhắn';

  @override
  String get scamCategoryEmail => 'Email';

  @override
  String get scamCategoryJob => 'Lời mời việc làm';

  @override
  String get scamCategoryRental => 'Quảng cáo thuê nhà';

  @override
  String get scamCategoryGovernment => 'Cơ quan nhà nước';

  @override
  String scamUpdatedFrom(String level) {
    return 'Cập nhật từ $level';
  }

  @override
  String get scamWhatYouSubmitted => 'Nội dung bạn đã gửi';

  @override
  String get scamExpand => 'Mở rộng';

  @override
  String get scamCollapse => 'Thu gọn';

  @override
  String get scamMessage => 'Tin nhắn';

  @override
  String scamMessageNumber(int number) {
    return 'Tin nhắn $number';
  }

  @override
  String get scamWhyRisky => 'Vì sao có thể rủi ro';

  @override
  String get scamWhatYouCanDo => 'Bạn có thể làm gì';

  @override
  String get scamAddMessage => 'Thêm tin nhắn';

  @override
  String get scamFollowUpTitle => 'Thêm tin tiếp theo trong cuộc trò chuyện';

  @override
  String get scamFollowUpHint => 'Dán tin nhắn hoặc email tiếp theo…';

  @override
  String get scamReevaluate => 'Đánh giá lại';

  @override
  String get scamFollowUpNeedInput =>
      'Hãy dán tin nhắn tiếp theo hoặc thêm ảnh chụp màn hình.';

  @override
  String get scamFollowUpImageError => 'Không mở được ảnh đó.';

  @override
  String get scamScreenshotAttached => 'Đã đính kèm ảnh chụp màn hình';

  @override
  String scamThreadCount(int count) {
    return '$count tin nhắn trong cuộc trò chuyện này';
  }

  @override
  String get actionSend => 'Gửi';

  @override
  String get actionDelete => 'Xóa';

  @override
  String get followupAsk => 'Hỏi';

  @override
  String get followupSaveNote => 'Lưu ghi chú';

  @override
  String get followupDeleteNote => 'Xóa ghi chú';

  @override
  String followupQuestion(String question) {
    return 'H: $question';
  }

  @override
  String get careerSignIn => 'Đăng nhập để khám phá lộ trình nghề nghiệp.';

  @override
  String get careerAddPriorJob =>
      'Thêm công việc trước đây trong khảo sát hồ sơ, hoặc mô tả nền tảng của bạn ở phần ghi chú bên dưới.';

  @override
  String get careerGoToProfile => 'Đến hồ sơ';

  @override
  String get careerPriorEmployment => 'Việc làm trước đây (từ khảo sát)';

  @override
  String get careerAdditionalBackground => 'Thông tin bổ sung';

  @override
  String get careerAdditionalBackgroundHelp =>
      'Kỹ năng, học vấn, chứng chỉ, ngôn ngữ hoặc mục tiêu nghề nghiệp để AI gợi ý lộ trình phù hợp hơn.';

  @override
  String get careerAdditionalBackgroundHint =>
      'vd. 5 năm làm thợ điện, bằng nghề, quan tâm lắp đặt năng lượng mặt trời…';

  @override
  String get careerGenerateAll => 'Tạo lộ trình nghề nghiệp';

  @override
  String get careerRegenerateAll => 'Tạo lại tất cả lộ trình';

  @override
  String get careerGenerating => 'Đang lập lộ trình nghề nghiệp…';

  @override
  String get careerNeedBackground =>
      'Hãy thêm ghi chú về kỹ năng hoặc học vấn trước.';

  @override
  String get careerCouldNotSaveChecklist => 'Không lưu được tiến độ danh sách.';

  @override
  String get careerCouldNotSaveStep => 'Không lưu được tiến độ bước.';

  @override
  String get careerCouldNotSaveNote => 'Không lưu được ghi chú.';

  @override
  String get careerCouldNotDeleteNote => 'Không xóa được ghi chú đó.';

  @override
  String get careerDeleteNoteTitle => 'Xóa ghi chú này?';

  @override
  String get careerDeleteNoteBody =>
      'Thao tác này gỡ ghi chú khỏi lộ trình nghề nghiệp này.';

  @override
  String get careerGeneratePathTitle => 'Tạo lộ trình này?';

  @override
  String get careerRegeneratePathTitle => 'Tạo lại lộ trình này?';

  @override
  String careerGeneratePathBody(int number) {
    return 'Tạo lộ trình AI cho Lộ trình $number. Các lộ trình và ghi chú khác được giữ lại.';
  }

  @override
  String careerRegeneratePathBody(String title) {
    return 'Thay \"$title\" bằng lộ trình AI mới. Các lộ trình và ghi chú khác được giữ lại.';
  }

  @override
  String get careerGenerate => 'Tạo';

  @override
  String get careerRegenerate => 'Tạo lại';

  @override
  String careerPathNumber(int number) {
    return 'Lộ trình $number';
  }

  @override
  String careerPathHeading(int number, String title) {
    return 'Lộ trình $number: $title';
  }

  @override
  String get careerPlaceholderBody =>
      'Lộ trình nghề nghiệp sẽ xuất hiện ở đây sau khi được tạo.';

  @override
  String get careerPlaceholderStartTitle => 'Điểm bắt đầu';

  @override
  String get careerPlaceholderStartBody =>
      'Kinh nghiệm và nền tảng hiện tại của bạn.';

  @override
  String get careerPlaceholderCredsTitle => 'Xây dựng chứng chỉ';

  @override
  String get careerPlaceholderCredsBody =>
      'Giấy phép, đào tạo và kỹ năng cần phát triển.';

  @override
  String get careerPlaceholderTargetTitle => 'Vị trí mục tiêu';

  @override
  String get careerPlaceholderTargetBody =>
      'Mục tiêu nghề nghiệp của bạn tại Hoa Kỳ.';

  @override
  String get careerCertifications => 'Chứng chỉ và giấy phép';

  @override
  String get careerSkills => 'Kỹ năng cần phát triển';

  @override
  String get careerTimeEstimate => 'Ước tính thời gian';

  @override
  String get careerStepCompleted => 'Đã hoàn thành';

  @override
  String get careerStepNow => 'Hiện tại';

  @override
  String careerStepNowWithDuration(String duration) {
    return 'Hiện tại ($duration)';
  }

  @override
  String get careerTimePending => 'Chưa có ước tính thời gian';

  @override
  String get careerUndo => 'Hoàn tác';

  @override
  String get careerMarkComplete => 'Đánh dấu hoàn thành';

  @override
  String get careerFinishStepAbove => 'Hãy hoàn thành bước phía trên trước.';

  @override
  String get careerUndoLaterStep => 'Hãy hoàn tác bước sau trước.';

  @override
  String get careerAskTitle => 'Hỏi về lộ trình này';

  @override
  String get careerAskSubtitle =>
      'Câu hỏi dùng các bước, ghi chú và nền tảng của bạn. Câu trả lời ở lại trang này cho đến khi bạn rời đi. Hãy lưu thành ghi chú những gì muốn giữ.';

  @override
  String get careerAskHint => 'Hỏi về một bước, giấy phép hoặc cách bắt đầu…';

  @override
  String get careerNotesTitle => 'Ghi chú cho lộ trình này';

  @override
  String get careerNotesSubtitle =>
      'Theo dõi tiến độ trên lộ trình này. Được lưu và chia sẻ với AI.';

  @override
  String get careerNotesHint => 'Bạn đã làm gì cho lộ trình này?';

  @override
  String get roadmapSettlementPlan =>
      'Kế hoạch ổn định dựa trên câu trả lời khảo sát của bạn.';

  @override
  String get roadmapRegenerateAll => 'Tạo lại tất cả';

  @override
  String get roadmapRegenerateAllTitle => 'Tạo lại toàn bộ lộ trình?';

  @override
  String get roadmapRegenerateAllBody =>
      'Thao tác này thay ba phần bằng kế hoạch AI mới. Ghi chú từng phần được giữ lại.';

  @override
  String get roadmapCreating => 'Đang tạo lộ trình cá nhân hóa…';

  @override
  String get roadmapAnswerQuestions =>
      'Hãy trả lời các câu hỏi bên dưới để hoàn tất lộ trình.';

  @override
  String get roadmapUpdating => 'Đang cập nhật lộ trình…';

  @override
  String get roadmapGenerate => 'Tạo lộ trình';

  @override
  String get roadmapNoRoadmap =>
      'Chưa có lộ trình. Nhấn bên dưới để tạo từ khảo sát.';

  @override
  String get roadmapEmptySurvey =>
      'Hãy làm khảo sát ban đầu để chúng tôi tạo lộ trình cá nhân hóa.';

  @override
  String roadmapRegenerateSectionTitle(String section) {
    return 'Tạo lại $section?';
  }

  @override
  String get roadmapRegenerateSectionBody =>
      'Phần này sẽ được thay bằng kế hoạch AI mới. Ghi chú của phần này được giữ lại.';

  @override
  String get roadmapAskTitle => 'Hỏi về phần này';

  @override
  String get roadmapAskSubtitle =>
      'Câu hỏi dùng danh sách, ghi chú và khảo sát. Câu trả lời ở lại trang này cho đến khi bạn rời đi. Hãy lưu thành ghi chú những gì muốn giữ.';

  @override
  String get roadmapAskHint => 'Hỏi về một bước trong phần này…';

  @override
  String get roadmapNotesTitle => 'Ghi chú cho phần này';

  @override
  String get roadmapNotesSubtitle =>
      'Theo dõi tiến độ các bước này. Được lưu và chia sẻ với AI.';

  @override
  String get roadmapNotesHint => 'Bạn đã làm gì cho phần này?';

  @override
  String get roadmapNoChecklist => 'Chưa có mục trong danh sách.';

  @override
  String get roadmapCouldNotSaveNote => 'Không lưu được ghi chú.';

  @override
  String get roadmapCouldNotDeleteNote => 'Không xóa được ghi chú đó.';

  @override
  String get roadmapDeleteNoteTitle => 'Xóa ghi chú này?';

  @override
  String get roadmapDeleteNoteBody => 'Thao tác này gỡ ghi chú khỏi phần này.';

  @override
  String get roadmapAiUnavailable => 'Dịch vụ AI hiện không khả dụng.';

  @override
  String get roadmapAiCouldNotAnswer => 'AI không thể trả lời.';

  @override
  String get roadmapSectionFirstMonth => 'Tháng đầu';

  @override
  String get roadmapSectionFirstThreeMonths => '3 tháng đầu';

  @override
  String get roadmapSectionFirstYear => 'Năm đầu';

  @override
  String roadmapQuestionOf(int current, int total) {
    return 'Câu $current / $total';
  }

  @override
  String get roadmapOneQuestion => 'Một câu hỏi nhanh';

  @override
  String roadmapUpNext(String question) {
    return 'Tiếp theo: $question';
  }

  @override
  String get roadmapYourAnswer => 'Câu trả lời của bạn';

  @override
  String get guideLoadError =>
      'Không tải được hướng dẫn này. Hãy thử lại khi bạn có mạng.';

  @override
  String get guideNoSections => 'Hướng dẫn này không có phần nào.';

  @override
  String guideSectionOf(int current, int total) {
    return 'Phần $current / $total';
  }

  @override
  String get housingAskTitle => 'Hỏi về nhà ở';

  @override
  String get housingAskHint => 'Nhập câu hỏi…';

  @override
  String get housingAskFollowUpHint => 'Hỏi thêm…';

  @override
  String get educationNavigatorTitle => 'Điều hướng giáo dục';

  @override
  String get educationHubIntro =>
      'Tìm hiểu cách trường học California hoạt động, rồi tìm trường công và tư gần bạn cùng gia sư, thư viện và chương trình STEM đáng tin.';

  @override
  String get educationBasicsTitle => 'Kiến thức cơ bản về giáo dục';

  @override
  String get educationBasicsSubtitle =>
      'Ghi danh, học khu, khối lớp, hỗ trợ học sinh học tiếng Anh, và trợ giúp học tập.';

  @override
  String get educationFindTitle => 'Tìm trường và chương trình';

  @override
  String get educationFindSubtitle =>
      'Bản đồ và danh sách trường công và tư California gần bạn, thư viện, gia sư, và chương trình STEM.';

  @override
  String get healthcareNavigatorTitle => 'Điều hướng y tế';

  @override
  String get healthcareHubIntro =>
      'Tìm hiểu cách chăm sóc y tế hoạt động ở California, rồi tìm trung tâm y tế cộng đồng đáng tin gần bạn.';

  @override
  String get healthcareBasicsTitle => 'Cơ bản về chăm sóc sức khỏe';

  @override
  String get healthcareBasicsSubtitle =>
      'Bảo hiểm, cách khám bệnh, trung tâm y tế cộng đồng, và hỗ trợ ngôn ngữ.';

  @override
  String get healthcareFindTitle => 'Tìm phòng khám';

  @override
  String get healthcareFindSubtitle =>
      'Bản đồ và danh sách trung tâm y tế cộng đồng HRSA gần bạn theo thành phố hoặc ZIP.';

  @override
  String get finderCityOrZipLabel => 'Thành phố hoặc mã ZIP';

  @override
  String get finderCityOrZipHint => 'vd. Oakland hoặc 94102';

  @override
  String get finderSetCityOrZip => 'Nhập thành phố hoặc mã ZIP';

  @override
  String finderNear(String location) {
    return 'Gần: $location';
  }

  @override
  String get finderHideSearchOptions => 'Ẩn tùy chọn tìm kiếm';

  @override
  String get finderResizeMap => 'Đổi kích thước bản đồ';

  @override
  String get clinicsSearchIntro =>
      'Tìm trung tâm y tế cộng đồng HRSA gần một thành phố hoặc mã ZIP ở California. Ghim đến từ danh mục liên bang chính thức.';

  @override
  String get clinicsFindButton => 'Tìm phòng khám gần đây';

  @override
  String get clinicsSearchDetail => 'Trung tâm y tế cộng đồng HRSA';

  @override
  String get clinicsEnterLocation =>
      'Nhập thành phố hoặc mã ZIP để tìm phòng khám gần đây.';

  @override
  String get clinicsNoResults =>
      'Không tìm thấy trung tâm y tế cộng đồng gần đây. Thử thành phố hoặc mã ZIP khác ở California, hoặc mở rộng tìm kiếm sau.';

  @override
  String get clinicsLoadError =>
      'Không tải được phòng khám. Hãy thử lại sau ít phút.';

  @override
  String get englishSearchIntro =>
      'Tìm trường dành cho người lớn, cao đẳng cộng đồng, và chương trình ESL thư viện đáng tin gần một thành phố hoặc mã ZIP ở California.';

  @override
  String get englishFindButton => 'Tìm lớp gần đây';

  @override
  String get englishSearchDetail => 'Trường người lớn, cao đẳng & thư viện';

  @override
  String get englishEnterLocation =>
      'Nhập thành phố hoặc mã ZIP để tìm lớp gần đây.';

  @override
  String get englishNoResults =>
      'Chưa có nguồn ESL gần đây. Hãy thử thành phố hoặc mã ZIP khác ở California.';

  @override
  String get englishLoadError =>
      'Không tải được tài nguyên tiếng Anh. Hãy thử lại sau ít phút.';

  @override
  String get englishSourceCurated =>
      'Nguồn: giáo dục người lớn, cao đẳng và thư viện California đã chọn lọc';

  @override
  String englishSourceNamed(String source) {
    return 'Nguồn: $source';
  }

  @override
  String get educationSearchIntro =>
      'Tìm trường công và tư California từ danh mục CDE chính thức, cộng với thư viện, gia sư, và chương trình STEM đã chọn lọc.';

  @override
  String get educationFindButton => 'Tìm gần đây';

  @override
  String get educationEnterLocation =>
      'Nhập thành phố hoặc mã ZIP để tìm trường gần đây.';

  @override
  String get educationNoResults =>
      'Không tìm thấy trường hoặc chương trình gần đây. Thử thành phố hoặc mã ZIP khác ở California, hoặc đổi bộ lọc.';

  @override
  String get educationLoadError =>
      'Không tải được nguồn giáo dục. Hãy thử lại.';

  @override
  String get educationLoadErrorShort =>
      'Không tải được nguồn giáo dục. Hãy thử lại sau ít phút.';

  @override
  String get educationTypeLabel => 'Loại';

  @override
  String get educationAllTypes => 'Tất cả loại';

  @override
  String get educationKindSchools => 'Trường học';

  @override
  String get educationKindPrograms => 'Chương trình & hỗ trợ';

  @override
  String get educationKindPublicSchools => 'Trường công';

  @override
  String get educationKindPrivateSchools => 'Trường tư';

  @override
  String get educationKindEnrollmentHelp => 'Hỗ trợ ghi danh';

  @override
  String get educationKindLibraries => 'Thư viện';

  @override
  String get educationKindTutoring => 'Gia sư';

  @override
  String get educationKindStem => 'STEM / bồi dưỡng';

  @override
  String get educationAllGrades => 'Tất cả khối lớp';

  @override
  String get educationGradeLabel => 'Khối lớp';

  @override
  String get educationGradePk => 'MG';

  @override
  String get educationGrade12 => 'Lớp 12';

  @override
  String educationGradeSingle(String grade) {
    return 'Lớp $grade';
  }

  @override
  String educationGradesRange(String low, String high) {
    return 'Lớp $low–$high';
  }

  @override
  String get educationMapBadge => 'Trường CDE + chương trình';

  @override
  String get groupsIntro =>
      'Tham gia một nhóm để đăng bài, đặt câu hỏi, và giúp người mới đến khác ở California.';

  @override
  String get groupsDiscover => 'Khám phá';

  @override
  String get groupsMine => 'Nhóm của tôi';

  @override
  String groupsMineCount(int count) {
    return 'Nhóm của tôi ($count)';
  }

  @override
  String get groupsSuggest => 'Đề xuất nhóm mới';

  @override
  String get groupsJoin => 'Tham gia';

  @override
  String get groupsJoined => 'Đã tham gia';

  @override
  String get groupsLeave => 'Rời nhóm';

  @override
  String get groupsSearch => 'Tìm';

  @override
  String get groupsSearchClear => 'Xóa tìm kiếm';

  @override
  String get groupsFilterAll => 'Tất cả';

  @override
  String get groupsSearchNoMatch => 'Không có nhóm khớp với tìm kiếm của bạn.';

  @override
  String get groupsMineEmpty =>
      'Bạn chưa tham gia nhóm nào. Chuyển sang Khám phá để tìm một nhóm.';

  @override
  String get groupsCategoryEmpty => 'Chưa có nhóm trong danh mục này.';

  @override
  String get groupsSuggestTitle => 'Đề xuất nhóm';

  @override
  String get groupsSuggestIntro =>
      'Đề xuất một nhóm cho người mới đến khác ở California. Quản trị viên xem xét mọi đề xuất trước khi mở cho người khác tham gia.';

  @override
  String get groupsSuggestNameLabel => 'Tên nhóm';

  @override
  String get groupsSuggestNameHint => 'vd. Người mới đến ở Fresno';

  @override
  String get groupsSuggestCategory => 'Danh mục';

  @override
  String get groupsSuggestPurposeLabel => 'Nhóm này để làm gì?';

  @override
  String get groupsSuggestPurposeHint =>
      'Ai nên tham gia, và mọi người sẽ nói về gì?';

  @override
  String get groupsSuggestSubmit => 'Gửi để xét duyệt';

  @override
  String get groupsSuggestSent =>
      'Đã gửi đề xuất. Quản trị viên sẽ xét duyệt trước khi nhóm xuất hiện.';

  @override
  String get groupsSuggestSendError =>
      'Không gửi được đề xuất đó. Hãy thử lại.';

  @override
  String get groupsSuggestNameRequired => 'Hãy đặt tên cho nhóm.';

  @override
  String get groupsSuggestDescriptionRequired => 'Thêm mô tả ngắn.';

  @override
  String get groupsCategoryParents => 'Phụ huynh';

  @override
  String get groupsCategoryJobs => 'Việc làm';

  @override
  String get groupsCategoryLanguage => 'Tiếng Anh';

  @override
  String get groupsCategoryCareers => 'Nghề nghiệp';

  @override
  String get groupsCategoryCulture => 'Văn hóa';

  @override
  String get groupsCategoryHousing => 'Nhà ở';

  @override
  String get groupsCategoryOther => 'Khác';

  @override
  String get groupsFallbackTitle => 'Nhóm hỗ trợ';

  @override
  String get groupsLoadError => 'Không tải được nhóm này.';

  @override
  String get groupsUnavailable => 'Nhóm này không còn nữa.';

  @override
  String get groupsRemovedAdmin => 'Quản trị viên đã gỡ nhóm này.';

  @override
  String groupsRemovedWithReason(String reason) {
    return 'Nhóm này đã bị gỡ. Lý do: $reason';
  }

  @override
  String get groupsMemberOne => '1 thành viên';

  @override
  String groupsMemberCount(int count) {
    return '$count thành viên';
  }

  @override
  String get groupsPrivacyNotice =>
      'Bài đăng và câu hỏi chỉ dành cho thành viên. Chúng được kiểm tra an toàn trước khi người khác xem. Hãy tử tế, và đừng dán số ID, mật khẩu, hoặc số tài khoản.';

  @override
  String get groupsNewPost => 'Bài mới';

  @override
  String get groupsAskQuestion => 'Đặt câu hỏi';

  @override
  String get groupsJoinToRead => 'Tham gia để đọc bài và trả lời';

  @override
  String get groupsJoinPrompt =>
      'Chỉ thành viên mới xem được bài đăng và câu hỏi trong nhóm này. Hãy tham gia khi bạn sẵn sàng.';

  @override
  String get groupsJoinGroup => 'Tham gia nhóm';

  @override
  String get groupsLeaveShort => 'Rời';

  @override
  String get groupsLeaveConfirmTitle => 'Rời nhóm này?';

  @override
  String groupsLeaveConfirmBody(String title) {
    return 'Bạn sẽ không còn thấy bài trong \"$title\". Bạn có thể tham gia lại sau.';
  }

  @override
  String get groupsPostsLoadError =>
      'Không tải được bài đăng. Hãy tham gia nhóm rồi thử lại.';

  @override
  String get groupsNoPostsYet =>
      'Chưa có bài. Hãy chia sẻ điều gì đó, hoặc hỏi nhóm để được giúp.';

  @override
  String get groupsYou => 'Bạn';

  @override
  String get groupsPostOptions => 'Tùy chọn bài đăng';

  @override
  String get groupsReplyOptions => 'Tùy chọn trả lời';

  @override
  String get groupsKindPost => 'Bài đăng';

  @override
  String get groupsKindQuestion => 'Câu hỏi';

  @override
  String get groupsNoAnswersYet => 'Chưa có câu trả lời';

  @override
  String get groupsNoRepliesYet => 'Chưa có phản hồi';

  @override
  String get groupsReplyOne => '1 phản hồi';

  @override
  String groupsReplyMany(int count) {
    return '$count phản hồi';
  }

  @override
  String get groupsComposePostIntro =>
      'Chia sẻ cập nhật, mẹo, hoặc điều có thể giúp người khác trong nhóm này.';

  @override
  String get groupsComposeQuestionIntro =>
      'Hỏi nhóm điều họ có thể giúp. Thành viên khác có thể trả lời trong chủ đề này.';

  @override
  String get groupsComposeGuidelines =>
      'Bài đăng được kiểm tra an toàn trước khi người khác xem. Đừng dán số ID, mật khẩu, hoặc số tài khoản. Nói về phúc lợi, visa, và giấy tờ thì được.';

  @override
  String get groupsComposeTitleLabel => 'Tiêu đề';

  @override
  String get groupsComposeQuestionLabel => 'Câu hỏi';

  @override
  String get groupsComposeTitleHint => 'vd. Một mẹo sơ yếu lý lịch đã giúp tôi';

  @override
  String get groupsComposeQuestionHint =>
      'vd. Bạn tìm bác sĩ nhi khoa thế nào?';

  @override
  String get groupsComposeBodyLabel => 'Mô tả';

  @override
  String get groupsComposeDetailsLabel => 'Chi tiết (không bắt buộc)';

  @override
  String get groupsComposeBodyHint =>
      'Thêm câu chuyện, liên kết, hoặc điều hữu ích.';

  @override
  String get groupsComposeDetailsHint =>
      'Thêm chi tiết giúp người khác trả lời.';

  @override
  String get groupsAddPhotos => 'Thêm ảnh';

  @override
  String get groupsAdd => 'Thêm';

  @override
  String groupsPhotoCount(int count, int max) {
    return '$count / $max ảnh';
  }

  @override
  String get groupsPublishPost => 'Đăng bài';

  @override
  String get groupsPostQuestion => 'Đăng câu hỏi';

  @override
  String get groupsPhotoLibrary => 'Thư viện ảnh';

  @override
  String get groupsCamera => 'Máy ảnh';

  @override
  String get groupsPhotoOpenError => 'Không mở được ảnh đó. Hãy thử ảnh khác.';

  @override
  String get groupsPublishError => 'Không đăng được. Hãy thử lại.';

  @override
  String get groupsRemovePhoto => 'Gỡ ảnh';

  @override
  String get groupsPostLoadError => 'Không tải được bài này.';

  @override
  String get groupsPostRemoved => 'Bài này đã bị gỡ.';

  @override
  String get groupsAnswers => 'Câu trả lời';

  @override
  String get groupsReplies => 'Phản hồi';

  @override
  String get groupsRepliesLoadError => 'Không tải được phản hồi.';

  @override
  String get groupsNoAnswersHelp =>
      'Chưa có câu trả lời. Hãy là người đầu tiên giúp.';

  @override
  String get groupsNoRepliesHelp =>
      'Chưa có phản hồi. Hãy bắt đầu cuộc trò chuyện.';

  @override
  String get groupsWriteAnswer => 'Viết câu trả lời…';

  @override
  String get groupsWriteReply => 'Viết phản hồi…';

  @override
  String get groupsEditReply => 'Sửa phản hồi';

  @override
  String get groupsWriteReplyFirst => 'Hãy viết phản hồi trước.';

  @override
  String get groupsDeleteReplyTitle => 'Xóa phản hồi này?';

  @override
  String get groupsDeleteReplyBody => 'Không hoàn tác được.';

  @override
  String get groupsEdit => 'Sửa';

  @override
  String get groupsEdited => 'Đã sửa';

  @override
  String get groupsReply => 'Trả lời';

  @override
  String get groupsDeletePostTitle => 'Xóa bài này?';

  @override
  String get groupsDeletePostBody =>
      'Phản hồi cũng sẽ bị gỡ. Không hoàn tác được.';

  @override
  String get groupsRemovePostTitle => 'Gỡ bài này?';

  @override
  String get groupsRemovePostBody =>
      'Bài sẽ bị ẩn khỏi nhóm. Tác giả có 7 ngày để kháng cáo. Nếu không kháng cáo, hoặc người kiểm duyệt từ chối, bài sẽ bị xóa.';

  @override
  String get groupsRemovePostReason => 'Lý do';

  @override
  String get groupsRemovePostHint => 'vd. Điều này phá quy tắc nhóm.';

  @override
  String get groupsRemovePostReasonRequired => 'Hãy nói vì sao bài này bị gỡ.';

  @override
  String get groupsRemovePostAction => 'Gỡ bài';

  @override
  String get groupsModerationChecking => 'AI đang kiểm tra';

  @override
  String get groupsModerationPendingBody =>
      'Chúng tôi đang kiểm tra trước khi người khác xem. Bài sẽ hiện sau một lát.';

  @override
  String get groupsModerationHidden => 'Đã ẩn khỏi nhóm';

  @override
  String get groupsModerationHiddenPii =>
      'Đây giống số ID hoặc số tài khoản thật. Hãy xóa số rồi thử lại. Bạn vẫn có thể nói về chủ đề này.';

  @override
  String get groupsModerationHiddenScam =>
      'Đây giống như đang xin tiền hoặc thông tin cá nhân. Hãy giữ nhóm không có bán hàng và đề nghị đáng ngờ.';

  @override
  String get groupsModerationHiddenHate =>
      'Hãy tôn trọng nhau. Không cho phép bài không tử tế hoặc thù ghét.';

  @override
  String get groupsModerationHiddenHarassment =>
      'Hãy tôn trọng nhau. Không cho phép quấy rối.';

  @override
  String get groupsModerationHiddenSexual =>
      'Bài này không phù hợp nhóm hỗ trợ gia đình. Hãy giữ nội dung phù hợp.';

  @override
  String get groupsModerationHiddenSelfHarm =>
      'Nếu bạn đang khủng hoảng, hãy gọi hoặc nhắn 988 tại Mỹ. Bài bị ẩn vì có thể chứa nội dung gây hại.';

  @override
  String get groupsModerationHiddenViolence =>
      'Nhóm này không cho phép nội dung bạo lực.';

  @override
  String get groupsModerationHiddenGeneric =>
      'Bài bị ẩn vì không đúng quy tắc cộng đồng. Hãy viết lại rồi thử lại.';

  @override
  String get groupsAppealSent => 'Đã gửi kháng cáo';

  @override
  String groupsReasonPrefix(String reason) {
    return 'Lý do: $reason';
  }

  @override
  String get groupsHiddenByAdmin => 'Quản trị viên đã ẩn bài này.';

  @override
  String groupsDeletedAfter(String deadline) {
    return 'Sẽ bị xóa sau $deadline trừ khi kháng cáo được chấp nhận.';
  }

  @override
  String get groupsAppealPendingReview =>
      'Người kiểm duyệt sẽ xem kháng cáo của bạn.';

  @override
  String get groupsAppeal => 'Kháng cáo';

  @override
  String get groupsAppealTitle => 'Kháng cáo việc gỡ này?';

  @override
  String get groupsAppealIntro =>
      'Người kiểm duyệt sẽ xem. Nếu đồng ý, bài sẽ hiện lại trong nhóm.';

  @override
  String get groupsAppealLabel => 'Vì sao nên giữ lại? (không bắt buộc)';

  @override
  String get groupsSendAppeal => 'Gửi kháng cáo';

  @override
  String get groupsNoticeDismiss => 'Đóng';

  @override
  String get groupsNoticeAppealReviewing =>
      'Chúng tôi đang xem kháng cáo của bạn';

  @override
  String groupsNoticeStillHidden(String postTitle, String groupTitle) {
    return '\"$postTitle\" trong $groupTitle vẫn đang bị ẩn.';
  }

  @override
  String get groupsNoticePostBack => 'Bài của bạn đã trở lại';

  @override
  String groupsNoticeVisibleAgain(String postTitle, String groupTitle) {
    return '\"$postTitle\" trong $groupTitle đã hiện lại với nhóm.';
  }

  @override
  String get groupsNoticeAppealDeclined => 'Kháng cáo của bạn bị từ chối';

  @override
  String groupsNoticeWasRemoved(String postTitle, String groupTitle) {
    return '\"$postTitle\" trong $groupTitle đã bị gỡ.';
  }

  @override
  String get groupsNoticePostRemovedTitle => 'Bài của bạn đã bị gỡ';

  @override
  String groupsNoticeDeletedAfterWindow(String postTitle, String groupTitle) {
    return '\"$postTitle\" trong $groupTitle đã bị xóa sau khi hết hạn kháng cáo.';
  }

  @override
  String get groupsNoticePostHiddenTitle => 'Bài của bạn đã bị ẩn';

  @override
  String groupsNoticeHiddenReason(
    String postTitle,
    String groupTitle,
    String reason,
  ) {
    return '\"$postTitle\" trong $groupTitle đã bị ẩn. Lý do: $reason';
  }

  @override
  String groupsNoticeHiddenAdmin(String postTitle, String groupTitle) {
    return 'Quản trị viên đã ẩn \"$postTitle\" trong $groupTitle.';
  }

  @override
  String groupsNoticeAppealUntil(String deadline) {
    return 'Bạn có thể kháng cáo đến $deadline.';
  }
}
