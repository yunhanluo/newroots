/// Languages the app UI and AI replies support (DESIGN_PLAN.md §7).
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    this.isRtl = false,
  });

  final String code;
  final String englishName;
  final String nativeName;
  final bool isRtl;
}

const kAppLanguages = <AppLanguage>[
  AppLanguage(code: 'en', englishName: 'English', nativeName: 'English'),
  AppLanguage(code: 'es', englishName: 'Spanish', nativeName: 'Español'),
  AppLanguage(code: 'zh', englishName: 'Chinese', nativeName: '中文'),
  AppLanguage(code: 'vi', englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
  AppLanguage(code: 'ko', englishName: 'Korean', nativeName: '한국어'),
  AppLanguage(code: 'tl', englishName: 'Tagalog', nativeName: 'Tagalog'),
  AppLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
  AppLanguage(
    code: 'ar',
    englishName: 'Arabic',
    nativeName: 'العربية',
    isRtl: true,
  ),
];

const kSupportedLanguageCodes = <String>{
  'en',
  'es',
  'zh',
  'vi',
  'ko',
  'tl',
  'hi',
  'ar',
};

/// Maps device/profile codes onto the app language list (`fil` → Tagalog).
String normalizeAppLanguageCode(String? code) {
  final value = code?.trim().toLowerCase() ?? '';
  if (value == 'fil') return 'tl';
  return value;
}

bool isSupportedAppLanguage(String? code) {
  return kSupportedLanguageCodes.contains(normalizeAppLanguageCode(code));
}

AppLanguage? appLanguageByCode(String? code) {
  final value = normalizeAppLanguageCode(code);
  for (final language in kAppLanguages) {
    if (language.code == value) return language;
  }
  return null;
}

String appLanguageNativeName(String? code) {
  return appLanguageByCode(code)?.nativeName ?? (code ?? '');
}
