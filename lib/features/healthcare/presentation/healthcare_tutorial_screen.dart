import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/brand_colors.dart';

class _HcSection {
  const _HcSection({
    required this.title,
    this.intro = '',
    this.body = '',
    this.topics = const [],
  });

  final String title;
  final String intro;
  final String body;
  final List<_HcTopic> topics;
}

class _HcTopic {
  const _HcTopic({required this.heading, required this.paragraph, this.url});

  final String heading;
  final String paragraph;
  final String? url;
}

const _sections = <_HcSection>[
  _HcSection(
    title: 'Welcome',
    body:
        'Getting care in California can feel confusing when you are new to the '
        'US. Insurance names, clinic types, and paperwork are different from '
        'many other countries.\n\n'
        'This short guide covers insurance basics, what to expect at a visit, '
        'why community health centers are a trusted first stop, and how to ask '
        'for an interpreter.\n\n'
        'This is general information, not medical or legal advice. For your '
        'own health decisions, talk with a clinician or a trusted counselor.',
  ),
  _HcSection(
    title: 'Insurance basics',
    intro:
        'Health insurance helps pay for doctor visits, hospital care, and '
        'medicines. California has several common options. You do not need to '
        'memorize every rule; start by knowing which program might fit you.',
    topics: [
      _HcTopic(
        heading: 'Medi-Cal',
        paragraph:
            'Medi-Cal is California Medicaid. It covers many low income '
            'residents, including many immigrants who qualify under state '
            'rules. Coverage can include doctor visits, emergency care, '
            'pregnancy care, and more. Apply through Covered California or '
            'your county social services office. Bring ID, income info, and '
            'immigration documents if you have them. Ask for help in your '
            'language.',
        url: 'https://www.coveredca.com/',
      ),
      _HcTopic(
        heading: 'Covered California',
        paragraph:
            'Covered California is the state marketplace where you can buy a '
            'private plan and see if you qualify for help paying premiums. '
            'Open enrollment usually runs in the fall, but you may qualify for '
            'a special enrollment period after a life change such as moving or '
            'losing other coverage.',
        url: 'https://www.coveredca.com/',
      ),
      _HcTopic(
        heading: 'Employer and school plans',
        paragraph:
            'Some jobs and schools offer insurance. Ask HR or student services '
            'what is available, when you can enroll, and what it costs each '
            'month. Compare the premium (monthly cost) with the deductible '
            '(what you pay before insurance starts paying more).',
      ),
      _HcTopic(
        heading: 'If you are uninsured',
        paragraph:
            'You can still get care. Community health centers (next section) '
            'often offer sliding scale fees based on income. Emergency rooms '
            'must stabilize emergency conditions, but ER care can be very '
            'expensive for non emergencies. For routine care, a community '
            'clinic is usually a better first step.',
      ),
    ],
  ),
  _HcSection(
    title: 'How care works',
    intro:
        'In the US, people often start with a primary care clinic for checkups '
        'and common problems, then get referrals to specialists when needed.',
    topics: [
      _HcTopic(
        heading: 'Primary care',
        paragraph:
            'Primary care is your main doctor or clinic for colds, chronic '
            'conditions like diabetes, checkups, vaccines, and referrals. '
            'Building a relationship with one clinic helps them know your '
            'history and keep records together.',
      ),
      _HcTopic(
        heading: 'Urgent care vs emergency room',
        paragraph:
            'Urgent care is for problems that need same day attention but are '
            'not life threatening, such as a sprained ankle or a bad cold. '
            'Go to the emergency room or call 911 for severe chest pain, '
            'trouble breathing, heavy bleeding, or other life threatening '
            'symptoms.',
      ),
      _HcTopic(
        heading: 'What to bring',
        paragraph:
            'Bring photo ID if you have it, insurance card or Medi-Cal info, '
            'a list of medicines you take, and any past test results you have. '
            'Arrive early for paperwork. Ask the front desk what forms you '
            'need and whether walk ins are accepted.',
      ),
      _HcTopic(
        heading: 'Paying and bills',
        paragraph:
            'Ask about cost before non urgent visits when you can. You may get '
            'a bill weeks later for lab work or a specialist. Call the billing '
            'office if something looks wrong or you cannot pay. Many clinics '
            'offer payment plans or financial assistance applications.',
      ),
    ],
  ),
  _HcSection(
    title: 'Community health centers',
    intro:
        'Federally supported community health centers are a trusted place to '
        'start. In this app, clinic pins come from the US Health Resources '
        'and Services Administration (HRSA) list of Health Center Service '
        'Delivery and Look Alike sites in California.',
    topics: [
      _HcTopic(
        heading: 'What they are',
        paragraph:
            'These clinics (often called FQHCs or look alikes) provide primary '
            'care in underserved areas. Many offer dental, behavioral health, '
            'and pharmacy services too. They serve people with insurance, '
            'Medi-Cal, and people with no insurance.',
      ),
      _HcTopic(
        heading: 'Sliding scale and welcoming care',
        paragraph:
            'Fees often adjust based on income. Staff are used to helping '
            'patients with paperwork and different languages. You do not need '
            'to be a citizen to seek care at many of these sites. Ask the '
            'clinic what documents they need for a sliding scale visit.',
      ),
      _HcTopic(
        heading: 'Why we show them on the map',
        paragraph:
            'HRSA publishes an official directory of these sites. NewRoots '
            'uses that California extract so pins point to verified community '
            'health locations, not random listings. Always call ahead to '
            'confirm hours, services, and whether they accept new patients.',
        url: 'https://data.hrsa.gov/',
      ),
    ],
  ),
  _HcSection(
    title: 'Language and interpreters',
    intro:
        'You have the right to understand your care. Many clinics must provide '
        'language help at no cost for common languages. Do not rely on a child '
        'to interpret medical details when you can ask for a professional.',
    topics: [
      _HcTopic(
        heading: 'Ask when you book',
        paragraph:
            'When you call or check in, say: “I need an interpreter in '
            '[your language].” Ask whether they have in person staff, phone '
            'interpreters, or video interpreters. Confirm the language before '
            'your appointment starts.',
      ),
      _HcTopic(
        heading: 'What clinics can usually provide',
        paragraph:
            'Many community health centers and hospitals offer interpreter '
            'services. Availability varies by language and location. If your '
            'language is less common, ask how much notice they need. Bring a '
            'trusted adult only if you want extra support, not as a substitute '
            'for clinic interpreting when one is available.',
      ),
      _HcTopic(
        heading: 'During the visit',
        paragraph:
            'Speak to the clinician through the interpreter. Pause so they can '
            'translate fully. Ask them to repeat anything you did not '
            'understand, including medicine names, doses, and follow up dates. '
            'You can ask for written instructions in simple English or your '
            'language when available.',
      ),
    ],
  ),
  _HcSection(
    title: 'Trusted starting points',
    intro:
        'Use official sites and local clinics for the latest rules. Programs '
        'change, so verify details before you apply or travel far for care.',
    topics: [
      _HcTopic(
        heading: 'Covered California',
        paragraph:
            'Find Medi-Cal and marketplace coverage options, and get help in '
            'multiple languages.',
        url: 'https://www.coveredca.com/',
      ),
      _HcTopic(
        heading: 'Find a Health Center (HRSA)',
        paragraph:
            'Official federal tool to search community health centers. Our app '
            'map uses the same California directory data for nearby pins.',
        url: 'https://findahealthcenter.hrsa.gov/',
      ),
      _HcTopic(
        heading: '211 California',
        paragraph:
            'Call 211 or search online for local health, food, and social '
            'service referrals near you.',
        url: 'https://www.211ca.org/',
      ),
    ],
  ),
];

/// Healthcare basics tutorial (no AI ask bar).
class HealthcareTutorialScreen extends StatefulWidget {
  const HealthcareTutorialScreen({super.key});

  @override
  State<HealthcareTutorialScreen> createState() =>
      _HealthcareTutorialScreenState();
}

class _HealthcareTutorialScreenState extends State<HealthcareTutorialScreen> {
  bool _started = false;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    if (!_started) return _buildLanding();
    return _buildTutorial();
  }

  Widget _buildLanding() {
    return Scaffold(
      backgroundColor: kBrandGreen,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        title: const Text('Healthcare basics'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const Spacer(),
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Healthcare basics',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A short guide to insurance, clinic visits, community '
                    'health centers, and asking for an interpreter in California.',
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
                    }),
                    child: const Text('Start'),
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

  Widget _buildTutorial() {
    final section = _sections[_step];
    final total = _sections.length;
    final progress = (_step + 1) / total;
    final isLast = _step == total - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        title: const Text('Healthcare basics'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: section.topics.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              section.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SingleChildScrollView(
                                  child: Text(
                                    section.body,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              section.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            if (section.intro.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                section.intro,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                            for (final topic in section.topics) ...[
                              const SizedBox(height: 24),
                              Text(
                                topic.heading,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                topic.paragraph,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                              if (topic.url != null) ...[
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () => _openUrl(topic.url!),
                                    style: TextButton.styleFrom(
                                      foregroundColor: kBrandGreen,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      topic.url!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
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
                          child: _step > 0
                              ? OutlinedButton(
                                  onPressed: _previous,
                                  child: const Text('Previous'),
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
                            child: Text(isLast ? 'Finish' : 'Next'),
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
                    'Section ${_step + 1} of $total',
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
    setState(() => _step -= 1);
  }

  void _next() {
    if (_step >= _sections.length - 1) return;
    setState(() => _step += 1);
  }

  void _finish() {
    context.goNamed(Routes.healthcare);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
