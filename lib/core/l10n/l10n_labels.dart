import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../models/scam_report.dart';

String localizedPriorityLabel(AppLocalizations l10n, String value) {
  switch (value) {
    case 'Housing':
      return l10n.priorityHousing;
    case 'Employment':
      return l10n.priorityEmployment;
    case 'Education':
      return l10n.priorityEducation;
    case 'Healthcare':
      return l10n.priorityHealthcare;
    case 'English':
      return l10n.priorityEnglish;
    case 'Safety':
      return l10n.prioritySafety;
    default:
      if (value.startsWith('Other (') && value.endsWith(')')) {
        return '${l10n.priorityOther} (${value.substring(7, value.length - 1)})';
      }
      if (value.startsWith('Other ')) {
        return '${l10n.priorityOther} ${value.substring(6)}';
      }
      return value;
  }
}

String formatLocalizedPriorities(
  AppLocalizations l10n,
  List<String> priorities,
) {
  if (priorities.isEmpty) return '';
  return priorities.map((item) => localizedPriorityLabel(l10n, item)).join(', ');
}

String localizedScamCategory(AppLocalizations l10n, ScamCategory category) {
  switch (category) {
    case ScamCategory.sms:
      return l10n.scamCategorySms;
    case ScamCategory.email:
      return l10n.scamCategoryEmail;
    case ScamCategory.job:
      return l10n.scamCategoryJob;
    case ScamCategory.rental:
      return l10n.scamCategoryRental;
    case ScamCategory.government:
      return l10n.scamCategoryGovernment;
  }
}

String localizedScamRisk(AppLocalizations l10n, RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return l10n.scamRiskLow;
    case RiskLevel.moderate:
      return l10n.scamRiskModerate;
    case RiskLevel.high:
      return l10n.scamRiskHigh;
  }
}

String formatScamRelativeDate(AppLocalizations l10n, DateTime when) {
  final local = when.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(day).inDays;
  if (diffDays == 0) {
    return DateFormat.jm(l10n.localeName).format(local);
  }
  if (diffDays == 1) return l10n.scamYesterday;
  if (diffDays < 7) return l10n.scamDaysAgo(diffDays);
  return DateFormat.yMd(l10n.localeName).format(local);
}
