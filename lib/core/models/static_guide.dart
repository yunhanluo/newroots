import 'dart:convert';

/// IDs for the bundled static guides (safety, education, healthcare, housing).
abstract class StaticGuideIds {
  static const safety = 'safety';
  static const education = 'education';
  static const healthcare = 'healthcare';
  static const housing = 'housing';

  static const all = <String>[safety, education, healthcare, housing];
}

/// A mostly-static, localized guide that ships in the app and can be refreshed
/// from Firestore while remaining readable offline.
class StaticGuide {
  const StaticGuide({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.landingTitle = '',
    this.landingBody = '',
    this.icon = '',
    this.finishRoute = 'home',
    this.version = 1,
    this.sections = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String landingTitle;
  final String landingBody;
  final String icon;
  final String finishRoute;
  final int version;
  final List<StaticGuideSection> sections;

  String get displayTitle =>
      landingTitle.trim().isNotEmpty ? landingTitle : title;

  factory StaticGuide.fromMap(String id, Map<String, dynamic> map) {
    final rawId = (map['id'] as String?)?.trim() ?? '';
    return StaticGuide(
      id: rawId.isNotEmpty ? rawId : id,
      title: (map['title'] as String?) ?? '',
      subtitle: (map['subtitle'] as String?) ?? '',
      landingTitle: (map['landingTitle'] as String?) ?? '',
      landingBody: (map['landingBody'] as String?) ?? '',
      icon: (map['icon'] as String?) ?? '',
      finishRoute: (map['finishRoute'] as String?) ?? 'home',
      version: (map['version'] as num?)?.toInt() ?? 0,
      sections: (map['sections'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StaticGuideSection.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'landingTitle': landingTitle,
    'landingBody': landingBody,
    'icon': icon,
    'finishRoute': finishRoute,
    'version': version,
    'sections': [for (final section in sections) section.toMap()],
  };

  String toJsonString() => jsonEncode(toMap());
}

class StaticGuideSection {
  const StaticGuideSection({
    required this.title,
    this.intro = '',
    this.body = '',
    this.topics = const [],
  });

  final String title;
  final String intro;
  final String body;
  final List<StaticGuideTopic> topics;

  factory StaticGuideSection.fromMap(Map<String, dynamic> map) {
    return StaticGuideSection(
      title: (map['title'] as String?) ?? '',
      intro: (map['intro'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      topics: (map['topics'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => StaticGuideTopic.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'intro': intro,
    'body': body,
    'topics': [for (final topic in topics) topic.toMap()],
  };
}

class StaticGuideTopic {
  const StaticGuideTopic({
    required this.heading,
    required this.paragraph,
    this.url,
    this.phone,
    this.phoneLabel,
  });

  final String heading;
  final String paragraph;
  final String? url;
  final String? phone;
  final String? phoneLabel;

  factory StaticGuideTopic.fromMap(Map<String, dynamic> map) {
    return StaticGuideTopic(
      heading: (map['heading'] as String?) ?? '',
      paragraph: (map['paragraph'] as String?) ?? '',
      url: _optionalString(map['url']),
      phone: _optionalString(map['phone']),
      phoneLabel: _optionalString(map['phoneLabel']),
    );
  }

  Map<String, dynamic> toMap() => {
    'heading': heading,
    'paragraph': paragraph,
    if (url != null) 'url': url,
    if (phone != null) 'phone': phone,
    if (phoneLabel != null) 'phoneLabel': phoneLabel,
  };
}

String? _optionalString(Object? value) {
  final text = (value as String?)?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}
