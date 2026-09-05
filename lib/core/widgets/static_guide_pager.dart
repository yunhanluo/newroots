import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../models/static_guide.dart';
import '../services/static_guide_service.dart';
import '../theme/brand_colors.dart';
import 'static_guide_section_view.dart';

enum GuideLandingStyle {
  /// Large title, oversized icon, no app-bar title (safety / housing).
  hero,

  /// App-bar title plus a compact landing block (education / healthcare).
  compact,
}

/// Stepped tutorial for a cached static guide (no AI bar).
class StaticGuidePager extends ConsumerStatefulWidget {
  const StaticGuidePager({
    super.key,
    required this.guideId,
    required this.landingStyle,
  });

  final String guideId;
  final GuideLandingStyle landingStyle;

  @override
  ConsumerState<StaticGuidePager> createState() => _StaticGuidePagerState();
}

class _StaticGuidePagerState extends ConsumerState<StaticGuidePager> {
  bool _started = false;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guideAsync = ref.watch(staticGuideProvider(widget.guideId));
    return guideAsync.when(
      loading: () => const GuideStatusScaffold(busy: true),
      error: (error, _) => GuideStatusScaffold(message: l10n.guideLoadError),
      data: (guide) {
        if (!_started) return _buildLanding(guide, l10n);
        return _buildTutorial(guide, l10n);
      },
    );
  }

  Widget _buildLanding(StaticGuide guide, AppLocalizations l10n) {
    final icon = staticGuideIcon(guide.icon);
    final compact = widget.landingStyle == GuideLandingStyle.compact;

    return Scaffold(
      backgroundColor: kBrandGreen,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: compact ? Text(guide.displayTitle) : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 28 : 24,
            compact ? 12 : 16,
            compact ? 28 : 24,
            compact ? 28 : 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 480 : 620),
              child: Column(
                children: [
                  if (compact) ...[
                    const Spacer(),
                    Icon(icon, size: 64, color: Colors.white),
                    const SizedBox(height: 24),
                    Text(
                      guide.displayTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      guide.landingBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _StartButton(label: l10n.actionStart, onPressed: _start),
                    const Spacer(),
                  ] else ...[
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
                        child: Icon(icon, size: 72, color: Colors.white),
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
                    _StartButton(label: l10n.actionStart, onPressed: _start),
                    const Spacer(),
                  ],
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
                          child: step > 0
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
                            onPressed: isLast
                                ? () => _finish(guide)
                                : () => _next(total),
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
                    key: ValueKey(step),
                    tween: Tween<double>(begin: step / total, end: progress),
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
                    l10n.guideSectionOf(step + 1, total),
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

  void _start() {
    setState(() {
      _started = true;
      _step = 0;
    });
  }

  void _previous() {
    if (_step <= 0) return;
    setState(() => _step -= 1);
  }

  void _next(int total) {
    if (_step >= total - 1) return;
    setState(() => _step += 1);
  }

  void _finish(StaticGuide guide) {
    final route = guide.finishRoute.trim();
    context.goNamed(route.isEmpty ? 'home' : route);
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kBrandGreen,
        minimumSize: const Size(180, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class GuideStatusScaffold extends StatelessWidget {
  const GuideStatusScaffold({super.key, this.busy = false, this.message});

  final bool busy;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandGreen,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: busy
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  message ?? AppLocalizations.of(context).guideLoadError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ),
    );
  }
}

IconData staticGuideIcon(String name) {
  switch (name) {
    case 'emergency':
      return Icons.emergency_outlined;
    case 'school':
      return Icons.school_outlined;
    case 'health':
      return Icons.local_hospital_outlined;
    case 'home':
      return Icons.home_outlined;
    default:
      return Icons.menu_book_outlined;
  }
}
