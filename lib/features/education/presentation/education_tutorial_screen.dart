import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/brand_colors.dart';

class _EdSection {
  const _EdSection({
    required this.title,
    this.intro = '',
    this.body = '',
    this.topics = const [],
  });

  final String title;
  final String intro;
  final String body;
  final List<_EdTopic> topics;
}

class _EdTopic {
  const _EdTopic({required this.heading, required this.paragraph, this.url});

  final String heading;
  final String paragraph;
  final String? url;
}

const _sections = <_EdSection>[
  _EdSection(
    title: 'Welcome',
    body:
        'California public schools are free for children who live in the state. '
        'Rules, paperwork, and grade names can feel unfamiliar if you are new '
        'to the US.\n\n'
        'This short guide explains how K–12 schools are organized, how to find '
        'your district, what enrollment usually requires, English learner '
        'support, and where to find tutoring, libraries, and STEM programs.\n\n'
        'This is general information, not legal advice. District policies vary, '
        'so confirm details with your local school office.',
  ),
  _EdSection(
    title: 'How California K–12 works',
    intro:
        'Most children attend a public school assigned by where the family '
        'lives. Districts run the schools. Statewide rules come from the '
        'California Department of Education (CDE).',
    topics: [
      _EdTopic(
        heading: 'Public, charter, and private',
        paragraph:
            'Public schools are tuition free and open to local residents. '
            'Charter schools are public schools with more flexible programs; '
            'they may have lotteries or waitlists. Private schools charge '
            'tuition and set their own admissions rules. This app lists public '
            'and private schools, plus free or low cost support programs.',
      ),
      _EdTopic(
        heading: 'Grade bands',
        paragraph:
            'Elementary usually covers kindergarten through grade 5 or 6. '
            'Middle school covers grades 6–8 or 7–8. High school covers grades '
            '9–12. Some schools are K–8 or other combinations. Ask the '
            'district which school serves your child’s age.',
      ),
      _EdTopic(
        heading: 'California Department of Education',
        paragraph:
            'CDE publishes school directories, enrollment guidance, and English '
            'learner resources. Use official CDE and district sites when you '
            'need the latest rules.',
        url: 'https://www.cde.ca.gov/',
      ),
    ],
  ),
  _EdSection(
    title: 'Find your district and school',
    intro:
        'Your home address usually decides which school your child attends. '
        'Start with the district that serves your neighborhood.',
    topics: [
      _EdTopic(
        heading: 'School Locator',
        paragraph:
            'Use the CDE School Directory or your city/county district website '
            'to look up schools by address or city. In this app, the Find '
            'schools & programs map shows nearby public schools from the '
            'official California directory.',
        url: 'https://www.cde.ca.gov/SchoolDirectory/',
      ),
      _EdTopic(
        heading: 'Call the district office',
        paragraph:
            'If the website is confusing, call the district enrollment or '
            'student services office. Say your address, your child’s age or '
            'grade, and ask which school to contact. Ask for help in your '
            'language.',
      ),
      _EdTopic(
        heading: 'Open enrollment and transfers',
        paragraph:
            'Some districts allow requests to attend a school outside your '
            'assigned boundary. Rules and deadlines vary. Ask early; spots '
            'may be limited.',
      ),
    ],
  ),
  _EdSection(
    title: 'Enrollment documents',
    intro:
        'Schools need basic information to register a child. Exact lists vary '
        'by district, but these items are commonly requested.',
    topics: [
      _EdTopic(
        heading: 'Proof of age',
        paragraph:
            'A birth certificate, passport, or other official age document is '
            'usually enough. Ask what substitutes the district accepts if you '
            'do not have a US birth certificate.',
      ),
      _EdTopic(
        heading: 'Proof of address',
        paragraph:
            'Utility bills, a lease, or a letter from a shelter or host family '
            'may work. If you are temporarily living with relatives or in '
            'unstable housing, tell the school — California has protections '
            'for students experiencing homelessness.',
      ),
      _EdTopic(
        heading: 'Immunization records',
        paragraph:
            'California requires certain vaccines for school entry. Bring any '
            'immunization records you have. Ask the school nurse or county '
            'clinic how to catch up if records are incomplete.',
      ),
      _EdTopic(
        heading: 'Immigration status',
        paragraph:
            'Public schools must enroll children who live in the district '
            'regardless of immigration status. You should not be required to '
            'provide a Social Security number or immigration papers to enroll '
            'in K–12 public school.',
        url: 'https://www.cde.ca.gov/sp/hs/',
      ),
    ],
  ),
  _EdSection(
    title: 'English learners and academic support',
    intro:
        'Schools are used to helping children who are learning English and '
        'students who need extra academic or disability related support.',
    topics: [
      _EdTopic(
        heading: 'English learner (EL) programs',
        paragraph:
            'Schools assess English skills and provide English Language '
            'Development (ELD) support. Tell the school what languages your '
            'family speaks at home. Ask for interpreters at meetings.',
        url: 'https://www.cde.ca.gov/sp/el/',
      ),
      _EdTopic(
        heading: 'IEP and 504 plans',
        paragraph:
            'If your child has a disability or learning difference, ask about '
            'an evaluation. An IEP or 504 plan can provide classroom supports. '
            'You can request meetings and bring an advocate or interpreter.\n\n'
            'An IEP is created under the Individuals with Disabilities '
            'Education Act for a student who qualifies for special education. '
            'It is a written plan with learning goals, specialized instruction, '
            'services such as speech or occupational therapy, and a schedule '
            'for measuring progress. A 504 plan is for a student whose '
            'disability substantially limits a major life activity but who may '
            'not need special education; it focuses on equal access through '
            'accommodations such as extra test time, accessible seating, health '
            'supports, or assistive technology. You can request an evaluation '
            'in writing, and the school must follow formal timelines and obtain '
            'your consent before evaluating. You are part of the decision-making '
            'team, may ask for a free interpreter and copies of documents, and '
            'can request another meeting if the plan is not helping. Ask the '
            'school for its procedural safeguards if you disagree with an '
            'evaluation, eligibility decision, services, or placement.',
        url: 'https://www.cde.ca.gov/sp/se/qa/caprntorg.asp',
      ),
      _EdTopic(
        heading: 'After school and tutoring',
        paragraph:
            'Many districts, libraries, and nonprofits offer free or low cost '
            'homework help. Ask the school counselor and use this app’s '
            'program finder for nearby tutoring and STEM options.',
      ),
    ],
  ),
  _EdSection(
    title: 'Libraries, tutoring, and STEM',
    intro:
        'Support does not stop at the classroom. Local libraries and youth '
        'programs help with reading, homework, and hands on science.',
    topics: [
      _EdTopic(
        heading: 'Public libraries',
        paragraph:
            'Libraries offer free cards, books, Wi Fi, homework help, and '
            'family programs. Ask about bilingual storytimes and digital '
            'resources you can use at home.',
      ),
      _EdTopic(
        heading: 'Tutoring and enrichment',
        paragraph:
            'Look for district after school programs, community centers, and '
            'nonprofit tutoring. Confirm cost, ages served, and transportation '
            'before you enroll.',
      ),
      _EdTopic(
        heading: 'STEM opportunities',
        paragraph:
            'Museums, coding clubs, and science programs can build skills and '
            'confidence. Start with free public options near you, then ask the '
            'school about clubs and summer programs.',
      ),
      _EdTopic(
        heading: '211 California',
        paragraph:
            'Call 211 or search online for local education, youth, and family '
            'service referrals in your language when available.',
        url: 'https://www.211ca.org/',
      ),
    ],
  ),
];

/// Education basics tutorial (no AI ask bar).
class EducationTutorialScreen extends StatefulWidget {
  const EducationTutorialScreen({super.key});

  @override
  State<EducationTutorialScreen> createState() =>
      _EducationTutorialScreenState();
}

class _EducationTutorialScreenState extends State<EducationTutorialScreen> {
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
        title: const Text('Education basics'),
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
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Education basics',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A short guide to California public schools, enrollment, '
                    'English learner support, and academic programs.',
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
        title: const Text('Education basics'),
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
    context.goNamed(Routes.education);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
