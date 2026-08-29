/// Instant, on-device checks before a group post or reply is uploaded.
///
/// Cloud Functions still re-check every write. These rules only catch
/// pasted ID/account numbers and a few high-confidence scam asks — talking
/// about Social Security, visas, or immigration is allowed.
class GroupContentPolicy {
  const GroupContentPolicy._();

  static const piiMessage =
      'This looks like a real ID or account number. Please remove the '
      'number and try again. You can still talk about the topic.';

  static const scamMessage =
      'This looks like it could be asking people for money or selling '
      'immigration papers. Please keep the group free of those offers.';

  static const guidelines =
      'Posts are checked for safety before others can see them. Do not paste '
      'ID numbers, passwords, or account numbers. Talking about benefits, '
      'visas, and papers is fine.';

  static const _rules = <_Rule>[
    // Actual SSN/ITIN shape (123-45-6789), not the words.
    _Rule(piiMessage, r'\b\d{3}-\d{2}-\d{4}\b'),
    // 16-digit card shape with separators.
    _Rule(piiMessage, r'\b(?:\d{4}[ -]){3}\d{4}\b'),
    _Rule(
      scamMessage,
      r'\b(gift ?cards?|western union|moneygram|wire transfer)\b.{0,80}\b(send|pay|buy|purchase|deposit)\b',
    ),
    _Rule(
      scamMessage,
      r'\b(send|pay|buy|purchase|deposit)\b.{0,80}\b(gift ?cards?|western union|moneygram|wire transfer)\b',
    ),
    _Rule(
      scamMessage,
      r'\b(green card|work permit|visa|citizenship)s?\b.{0,20}\b(for sale|guaranteed)\b',
    ),
    _Rule(
      scamMessage,
      r'\bbuy (a )?(green card|work permit|visa|citizenship)\b',
    ),
    _Rule(
      scamMessage,
      r'\bi can (get|make|guarantee) you (a )?(papers?|green card|visa|work permit)\b',
    ),
    _Rule(
      piiMessage,
      r'\bsend me your (password|ssn|itin|passport|green card|id)\b',
    ),
  ];

  static String? blockedReason({String title = '', String text = ''}) {
    final haystack = '$title\n$text'.trim();
    if (haystack.isEmpty) return null;
    for (final rule in _rules) {
      if (RegExp(rule.pattern, caseSensitive: false).hasMatch(haystack)) {
        return rule.message;
      }
    }
    return null;
  }
}

class _Rule {
  const _Rule(this.message, this.pattern);
  final String message;
  final String pattern;
}
