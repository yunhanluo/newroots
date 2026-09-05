import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/models/static_guide.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/static_guide_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/ai_body_text.dart';
import '../../../core/widgets/static_guide_pager.dart';
import '../../../core/widgets/static_guide_section_view.dart';
import '../../../l10n/app_localizations.dart';

/// Feature 2: Housing Navigator.
class HousingScreen extends ConsumerStatefulWidget {
  const HousingScreen({super.key});

  @override
  ConsumerState<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends ConsumerState<HousingScreen> {
  bool _started = false;
  int _step = 0;
  final _questionController = TextEditingController();
  final _chatScrollController = ScrollController();
  bool _asking = false;
  final List<_HousingChatMessage> _messages = [];
  String? _aiError;

  @override
  void dispose() {
    _questionController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guideAsync = ref.watch(staticGuideProvider(StaticGuideIds.housing));
    return guideAsync.when(
      loading: () => const GuideStatusScaffold(busy: true),
      error: (error, _) => GuideStatusScaffold(message: l10n.guideLoadError),
      data: (guide) {
        if (!_started) return _buildIntro(guide, l10n);
        return _buildTutorial(guide, l10n);
      },
    );
  }

  Widget _buildIntro(StaticGuide guide, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: kBrandGreen,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Text(
                    guide.displayTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Icon(
                        staticGuideIcon(guide.icon),
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    guide.landingBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 36),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kBrandGreen,
                      minimumSize: const Size(180, 50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () => setState(() {
                      _started = true;
                      _step = 0;
                      _messages.clear();
                      _aiError = null;
                      _questionController.clear();
                    }),
                    child: Text(l10n.actionStart),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorial(StaticGuide guide, AppLocalizations l10n) {
    final total = guide.sections.length;
    if (total == 0) {
      return GuideStatusScaffold(message: l10n.guideNoSections);
    }
    final step = _step.clamp(0, total - 1);
    final section = guide.sections[step];
    final progress = (step + 1) / total;
    final isLast = step == total - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        title: Text(guide.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: StaticGuideSectionView(section: section),
              ),
            ),
            _AiAskBar(
              controller: _questionController,
              scrollController: _chatScrollController,
              asking: _asking,
              messages: _messages,
              error: _aiError,
              onAsk: _askAi,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _step > 0
                              ? OutlinedButton(
                                  onPressed: _previous,
                                  child: Text(l10n.actionPrevious),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: isLast ? _finish : _next,
                            style: FilledButton.styleFrom(
                              backgroundColor: kBrandGreen,
                              minimumSize: const Size(110, 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              isLast ? l10n.actionFinish : l10n.actionNext,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_step),
                    tween: Tween<double>(begin: _step / total, end: progress),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kBrandGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.guideSectionOf(_step + 1, total),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previous() {
    if (_step <= 0) return;
    setState(() {
      _step -= 1;
      _aiError = null;
    });
  }

  void _next() {
    final total =
        ref
            .read(staticGuideProvider(StaticGuideIds.housing))
            .value
            ?.sections
            .length ??
        0;
    if (_step >= total - 1) return;
    setState(() {
      _step += 1;
      _aiError = null;
    });
  }

  void _finish() {
    final route =
        ref
            .read(staticGuideProvider(StaticGuideIds.housing))
            .value
            ?.finishRoute
            .trim() ??
        '';
    context.goNamed(route.isEmpty ? Routes.home : route);
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _askAi() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _asking) return;

    final guide = ref.read(staticGuideProvider(StaticGuideIds.housing)).value;
    if (guide == null || guide.sections.isEmpty) return;
    final section = guide.sections[_step.clamp(0, guide.sections.length - 1)];
    final history = [
      for (final message in _messages)
        {'role': message.role, 'content': message.text},
    ];

    setState(() {
      _asking = true;
      _aiError = null;
      _messages.add(_HousingChatMessage(role: 'user', text: question));
      _questionController.clear();
    });
    _scrollChatToBottom();

    try {
      final answer = await ref
          .read(aiServiceProvider)
          .askHousingQuestion(
            question: question,
            sectionTitle: section.title,
            sectionSummary: [
              if (section.intro.isNotEmpty) section.intro,
              if (section.body.isNotEmpty) section.body,
              for (final topic in section.topics)
                [
                  topic.heading,
                  topic.paragraph,
                  if (topic.url != null) topic.url!,
                ].join('\n'),
            ].join('\n\n'),
            history: history,
            language: ref.read(appLocaleProvider).languageCode,
          );
      if (!mounted) return;
      setState(() {
        _messages.add(_HousingChatMessage(role: 'assistant', text: answer));
      });
      _scrollChatToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() => _aiError = describeAiServiceError(error));
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }
}

class _HousingChatMessage {
  const _HousingChatMessage({required this.role, required this.text});

  /// OpenAI-style role: `user` or `assistant`.
  final String role;
  final String text;

  bool get isUser => role == 'user';
}

class _AiAskBar extends StatelessWidget {
  const _AiAskBar({
    required this.controller,
    required this.scrollController,
    required this.asking,
    required this.messages,
    required this.error,
    required this.onAsk,
  });

  final TextEditingController controller;
  final ScrollController scrollController;
  final bool asking;
  final List<_HousingChatMessage> messages;
  final String? error;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBrandPageBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).housingAskTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (messages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBrandGreen.withValues(alpha: 0.2)),
                ),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: messages.length + (asking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final message = messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !asking,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onAsk(),
                    decoration: InputDecoration(
                      hintText: messages.isEmpty
                          ? AppLocalizations.of(context).housingAskHint
                          : AppLocalizations.of(context).housingAskFollowUpHint,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: asking ? null : onAsk,
                  style: IconButton.styleFrom(
                    backgroundColor: kBrandGreen,
                    foregroundColor: Colors.white,
                  ),
                  icon: asking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _HousingChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isUser
                  ? kBrandGreen.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    )
                  : AiBodyText(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
