import 'package:flutter/material.dart';

/// Renders the light Markdown models often emit (`#` headings, `**bold**`,
/// `*italic*`, `* ` / `- ` bullets) instead of showing the raw markers.
class AiBodyText extends StatelessWidget {
  const AiBodyText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(style: base, children: parseAiBodySpans(text)),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

final _bulletPrefix = RegExp(r'^(\s*)(?:\*|-)\s+', multiLine: true);
final _headingLine = RegExp(r'^(#{1,6})\s+(.*?)\s*$');
final _trailingHashes = RegExp(r'\s+#+\s*$');

List<InlineSpan> parseAiBodySpans(String raw) {
  if (raw.isEmpty) return const [];
  final prepared = raw.replaceAllMapped(
    _bulletPrefix,
    (match) => '${match[1]}• ',
  );
  final lines = prepared.split('\n');
  final spans = <InlineSpan>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final heading = _headingLine.firstMatch(line);
    if (heading != null) {
      final level = heading[1]!.length;
      final title = heading[2]!.replaceFirst(_trailingHashes, '');
      spans.add(
        TextSpan(
          style: _headingStyle(level),
          children: _parseInline(title),
        ),
      );
    } else {
      spans.addAll(_parseInline(line));
    }
    if (i < lines.length - 1) {
      spans.add(const TextSpan(text: '\n'));
    }
  }
  return spans;
}

TextStyle _headingStyle(int level) {
  return switch (level) {
    1 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    2 => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    3 => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    _ => const TextStyle(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
  };
}

List<InlineSpan> _parseInline(String input) {
  final spans = <InlineSpan>[];
  var i = 0;
  var plainStart = 0;

  void flushPlain(int end) {
    if (end > plainStart) {
      spans.add(TextSpan(text: input.substring(plainStart, end)));
    }
  }

  while (i < input.length) {
    if (_startsWith(input, i, '***')) {
      final close = input.indexOf('***', i + 3);
      if (close != -1) {
        flushPlain(i);
        spans.add(
          TextSpan(
            text: input.substring(i + 3, close),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        i = close + 3;
        plainStart = i;
        continue;
      }
    }

    if (_startsWith(input, i, '**')) {
      final close = input.indexOf('**', i + 2);
      if (close != -1) {
        flushPlain(i);
        spans.add(
          TextSpan(
            text: input.substring(i + 2, close),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
        i = close + 2;
        plainStart = i;
        continue;
      }
    }

    if (_startsWith(input, i, '__')) {
      final close = input.indexOf('__', i + 2);
      if (close != -1) {
        flushPlain(i);
        spans.add(
          TextSpan(
            text: input.substring(i + 2, close),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
        i = close + 2;
        plainStart = i;
        continue;
      }
    }

    if (input.codeUnitAt(i) == 0x2A /* * */ && !_startsWith(input, i, '**')) {
      final close = _nextSingleMarker(input, i + 1, '*');
      if (close != -1) {
        flushPlain(i);
        spans.add(
          TextSpan(
            text: input.substring(i + 1, close),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
        i = close + 1;
        plainStart = i;
        continue;
      }
    }

    i += 1;
  }

  flushPlain(input.length);
  return spans;
}

bool _startsWith(String input, int index, String token) {
  if (index + token.length > input.length) return false;
  return input.startsWith(token, index);
}

int _nextSingleMarker(String input, int from, String marker) {
  var index = from;
  while (true) {
    final found = input.indexOf(marker, index);
    if (found == -1) return -1;
    if (marker == '*' && _startsWith(input, found, '**')) {
      index = found + 2;
      continue;
    }
    return found;
  }
}
