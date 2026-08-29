import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brand_colors.dart';

const kMaxSurveyChildren = 8;
const kMaxChildAge = 21;

List<int> parseChildrenAges(String raw) {
  final ages = <int>[];
  for (final match in RegExp(r'\d+').allMatches(raw)) {
    final age = int.tryParse(match.group(0)!);
    if (age == null || age < 0 || age > kMaxChildAge) continue;
    ages.add(age);
    if (ages.length >= kMaxSurveyChildren) break;
  }
  return ages;
}

int surveyChildCount(int? familySize) {
  if (familySize == null || familySize <= 0) return 0;
  return familySize.clamp(0, kMaxSurveyChildren);
}

/// One age field per child, using the family-size / children count already answered.
class ChildrenAgesDraft {
  int count = 0;
  final List<TextEditingController> controllers = [];

  void setCount(int next) {
    count = next.clamp(0, kMaxSurveyChildren);
    while (controllers.length > count) {
      controllers.removeLast().dispose();
    }
    while (controllers.length < count) {
      controllers.add(TextEditingController());
    }
  }

  void loadFrom(String raw, {required int count}) {
    final ages = parseChildrenAges(raw);
    setCount(count);
    for (var i = 0; i < controllers.length && i < ages.length; i++) {
      controllers[i].text = '${ages[i]}';
    }
  }

  String toStorage() {
    if (count == 0) return '';
    return [
      for (final controller in controllers) controller.text.trim(),
    ].join(', ');
  }

  String? validationError() {
    if (count == 0) return null;
    for (final controller in controllers) {
      final age = int.tryParse(controller.text.trim());
      if (age == null || age < 0 || age > kMaxChildAge) {
        return 'Enter an age from 0 to $kMaxChildAge for each child.';
      }
    }
    return null;
  }

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    controllers.clear();
  }
}

class ChildrenAgesEditor extends StatelessWidget {
  const ChildrenAgesEditor({
    super.key,
    required this.draft,
    this.emptyMessage =
        'No children’s ages to add. You can go back and change how many children you have.',
    this.onChanged,
  });

  final ChildrenAgesDraft draft;
  final String emptyMessage;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    if (draft.count == 0) {
      return Text(
        emptyMessage,
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          color: Colors.black87.withValues(alpha: 0.65),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < draft.controllers.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          TextField(
            controller: draft.controllers[i],
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: kBrandGreen,
            onChanged: (_) => onChanged?.call(),
            decoration: InputDecoration(
              labelText: draft.count == 1 ? 'Age' : 'Child ${i + 1} age',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD9E2DE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBrandGreen, width: 2),
              ),
              labelStyle: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ],
    );
  }
}
