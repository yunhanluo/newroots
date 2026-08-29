import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_profile_service.dart';
import 'app_languages.dart';

class LocaleOverride extends Notifier<String?> {
  @override
  String? build() => null;

  void setCode(String? code) => state = code;
}

/// Session override used before a profile is saved (auth + onboarding).
final localeOverrideProvider =
    NotifierProvider<LocaleOverride, String?>(LocaleOverride.new);

/// Active UI locale: override → profile → device → English.
final appLocaleProvider = Provider<Locale>((ref) {
  final override = ref.watch(localeOverrideProvider);
  if (isSupportedAppLanguage(override)) {
    return Locale(override!.trim());
  }

  final profileCode =
      ref.watch(userProfileProvider).value?.languageCode.trim() ?? '';
  if (isSupportedAppLanguage(profileCode)) {
    return Locale(profileCode);
  }

  final device = WidgetsBinding.instance.platformDispatcher.locale;
  if (isSupportedAppLanguage(device.languageCode)) {
    return Locale(device.languageCode);
  }
  return const Locale('en');
});
