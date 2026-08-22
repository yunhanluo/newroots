import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/theme/brand_colors.dart';

class _HousingSection {
  const _HousingSection({
    required this.title,
    this.intro = '',
    this.body = '',
    this.topics = const [],
  });

  final String title;
  final String intro;
  final String body;
  final List<_HousingTopic> topics;
}

class _HousingTopic {
  const _HousingTopic({
    required this.heading,
    required this.paragraph,
    this.url,
  });

  final String heading;
  final String paragraph;
  final String? url;
}

const _sections = <_HousingSection>[
  _HousingSection(
    title: 'Welcome',
    body:
        'Renting or buying in California comes with challenges. Rules, paperwork, '
        'and costs can feel unfamiliar, especially if you are new to the US.\n\n'
        'Continue reading to learn about rental requirements, other ways to '
        'qualify, trusted housing resources, tenant rights, and how to avoid '
        'housing scams.\n\n'
        'If at any time you feel lost, ask the AI at the bottom of the screen. '
        'It can explain the current section in simpler words or answer a '
        'question about your situation.',
  ),
  _HousingSection(
    title: 'Understand rental requirements',
    intro:
        'Most landlords ask for the same basic items when you apply to rent. '
        'Gathering them ahead of time makes applying faster and less stressful. '
        'Here is what each one usually means.',
    topics: [
      _HousingTopic(
        heading: 'Rental application',
        paragraph:
            'This is the form the landlord or property manager uses to collect '
            'your information. It usually asks for your full name, current and '
            'past addresses, phone number, email, employment details, income, '
            'and the names of everyone who will live in the unit. Some forms are '
            'on paper and some are online. Fill it out carefully and use the same '
            'name that appears on your ID. Keep a copy or screenshot of what you '
            'submit so you remember what you shared.',
      ),
      _HousingTopic(
        heading: 'Photo ID',
        paragraph:
            'Landlords need a government issued photo ID to confirm who you are. '
            'A passport, US driver license, state ID, or another official photo ID '
            'is usually accepted. Bring the original to show in person, and ask '
            'before you send copies online. Only share ID images through a '
            'trusted application portal or directly with the property office, not '
            'through random text or social media messages.',
      ),
      _HousingTopic(
        heading: 'Proof of income',
        paragraph:
            'This shows you can pay the rent each month. Common proof includes '
            'recent pay stubs, an offer letter with your salary, bank statements, '
            'tax forms, or a letter from your employer. Many landlords look for '
            'monthly income of about two to three times the rent, but policies '
            'vary. If you are paid in cash, self employed, or new to a job, ask '
            'what documents they will accept. Print or save clear copies so you '
            'can upload or hand them in quickly.',
      ),
      _HousingTopic(
        heading: 'References',
        paragraph:
            'References are people the landlord can contact to learn whether you '
            'are reliable. Past landlords are the most useful. If you have never '
            'rented in the US, you can often use an employer, teacher, case '
            'worker, or community organization contact instead. Ask permission '
            'first, then give their full name, relationship to you, phone number, '
            'and email. Tell your references that a landlord may call so they are '
            'ready to answer.',
      ),
      _HousingTopic(
        heading: 'Credit and background checks',
        paragraph:
            'A credit check looks at how you have handled bills and loans in the '
            'US. A background check may look for eviction or criminal records. '
            'Newcomers often have little or no US credit history, which is common '
            'and not the same as bad credit. Ask the landlord what they check and '
            'what they do if someone has no US credit file. You usually authorize '
            'these checks on the application. In California, application screening '
            'fees are limited by law, and you can ask for a copy of any consumer '
            'report used to deny your application.',
      ),
      _HousingTopic(
        heading: 'Application fee',
        paragraph:
            'This is a fee some landlords charge to cover screening costs such as '
            'credit or background checks. In California, the amount is capped and '
            'should only cover actual out of pocket screening costs. Ask whether '
            'the fee is required, how much it is, and whether it is refundable '
            'before you pay. Pay through the official office or portal, get a '
            'receipt, and never wire money or use gift cards to someone claiming '
            'to be a landlord.',
      ),
    ],
  ),
  _HousingSection(
    title: 'Learn alternative ways to qualify',
    intro:
        'Many newcomers do not have a US credit history yet. That does not '
        'always mean you cannot rent. Landlords sometimes accept other ways '
        'to show you are reliable. Ask what they allow, and consider these '
        'common options.',
    topics: [
      _HousingTopic(
        heading: 'Co-signer or guarantor',
        paragraph:
            'A co-signer is someone with stronger credit or income who agrees '
            'to pay the rent if you cannot. This is often a relative, friend, '
            'or sponsor who lives in the US. The landlord will usually ask that '
            'person to fill out an application and pass a credit check too. '
            'Only ask someone you trust, and make sure they understand they are '
            'legally responsible if rent is unpaid.',
      ),
      _HousingTopic(
        heading: 'Larger security deposit',
        paragraph:
            'Some landlords will accept a higher deposit when your credit '
            'history is short or missing. This is meant to lower their risk. '
            'California limits how much deposit a landlord can charge, so ask '
            'what is allowed for that unit. Get any deposit amount in writing, '
            'and keep proof of what you paid.',
      ),
      _HousingTopic(
        heading: 'Proof of income or savings',
        paragraph:
            'Even without credit history, strong bank statements, pay stubs, '
            'or proof of savings can help. Some landlords want to see several '
            'months of income or enough money in the bank to cover rent for a '
            'set period. Bring clear, recent documents. If income comes from '
            'more than one source, include all of it and label what each '
            'document shows.',
      ),
      _HousingTopic(
        heading: 'Employer or offer letter',
        paragraph:
            'A letter from your employer can confirm your job, start date, and '
            'pay. If you have a new job offer, the offer letter may work while '
            'you wait for your first pay stubs. Ask your employer or HR for a '
            'signed letter on company letterhead. Include a contact name and '
            'phone number the landlord can call to verify.',
      ),
      _HousingTopic(
        heading: 'Newcomer and housing programs',
        paragraph:
            'Some nonprofits, resettlement agencies, and local housing programs '
            'help immigrants find rentals or connect with landlords who work '
            'with newcomers. These programs may offer application help, '
            'references, rental assistance, or lists of friendly properties. '
            'Ask at a library, community center, or immigrant services office '
            'near you about housing help in your language.',
      ),
    ],
  ),
  _HousingSection(
    title: 'Access housing resources',
    intro:
        'You do not have to figure out housing alone. Libraries, nonprofit '
        'counselors, and government sites can help you find rentals, learn the '
        'rules, and get local support. Here are a few trustworthy websites to '
        'start with.',
    topics: [
      _HousingTopic(
        heading: 'HUD (US Department of Housing and Urban Development)',
        paragraph:
            'HUD is the main federal housing agency. Its website explains rental '
            'help, fair housing rules, and how to find approved housing counselors '
            'near you. Use it when you want official US government information.',
        url: 'https://www.hud.gov/',
      ),
      _HousingTopic(
        heading: 'HUD Find a Housing Counselor',
        paragraph:
            'This HUD tool helps you find a HUD approved housing counselor. '
            'Counselors can explain applications, budgets, and rental options. '
            'Many offer help by phone or in person, and some speak more than one '
            'language.',
        url: 'https://www.hud.gov/program_offices/housing/sfh/hcc',
      ),
      _HousingTopic(
        heading: 'California Courts Self-Help Housing',
        paragraph:
            'This is the official California courts self help site for housing. '
            'It covers eviction, deposits, repairs, and other tenant issues in '
            'plain language. It is a good place to learn what the court process '
            'looks like if you have a housing problem.',
        url: 'https://selfhelp.courts.ca.gov/housing',
      ),
      _HousingTopic(
        heading: 'California Landlord-Tenant Guide',
        paragraph:
            'The California Department of Consumer Affairs publishes a free '
            'landlord tenant guide. It explains deposits, rent increases, '
            'repairs, and notices. Read it when you want a clear overview of '
            'common rental rules in California.',
        url: 'https://www.dca.ca.gov/publications/landlordbook.shtml',
      ),
      _HousingTopic(
        heading: 'California Housing and Community Development',
        paragraph:
            'California HCD shares state housing programs and consumer resources. '
            'Check this site for statewide housing information and links to help '
            'finding affordable options.',
        url: 'https://www.hcd.ca.gov/',
      ),
      _HousingTopic(
        heading: '211',
        paragraph:
            '211 connects you to local health and human services, including '
            'housing and rental assistance in many areas. You can search online '
            'or dial 211 to ask about help near you in your language when it is '
            'available.',
        url: 'https://www.211.org/',
      ),
    ],
  ),
  _HousingSection(
    title: 'Understand tenant rights',
    intro:
        'Tenants in California have important rights. Rules can vary by city, '
        'so always check local laws too. Here are the basics, explained one '
        'topic at a time.',
    topics: [
      _HousingTopic(
        heading: 'Security deposits',
        paragraph:
            'A security deposit is money you pay up front that the landlord '
            'holds while you rent. It can cover unpaid rent or damage beyond '
            'normal wear and tear. California limits how much a landlord can '
            'charge. When you move out, the landlord must return what is left '
            'and give an itemized list of any deductions within the time the '
            'law requires. Take dated photos when you move in and when you '
            'leave so you have proof of the unit condition.',
      ),
      _HousingTopic(
        heading: 'Repairs and livable housing',
        paragraph:
            'Your rental must be safe and livable. That usually includes working '
            'heat, plumbing, electricity, locks, and freedom from serious '
            'hazards like major leaks or pest infestations. Tell the landlord '
            'in writing when something needs repair, keep a copy, and give a '
            'reasonable time to fix it. If the problem is serious and ignored, '
            'look up your local options or talk to a housing counselor or legal '
            'aid group before you withhold rent or move out.',
      ),
      _HousingTopic(
        heading: 'Privacy',
        paragraph:
            'You have a right to privacy in your home. In most cases a landlord '
            'must give advance notice before entering, except in emergencies. '
            'Ask what notice your lease and local law require. You can refuse '
            'entry that does not follow the rules. Keep a written record if a '
            'landlord enters without proper notice.',
      ),
      _HousingTopic(
        heading: 'Eviction notices',
        paragraph:
            'A landlord generally cannot lock you out or shut off utilities to '
            'force you to leave. Eviction usually starts with a written notice '
            'and, if needed, a court case. Read any notice carefully, note the '
            'deadlines, and get help quickly from legal aid or a self help '
            'court site. Do not ignore court papers. Showing up and responding '
            'on time protects your rights.',
      ),
      _HousingTopic(
        heading: 'Protection from discrimination',
        paragraph:
            'Federal and California fair housing laws ban discrimination based '
            'on things like race, national origin, religion, sex, disability, '
            'familial status, and other protected categories under state law. '
            'A landlord generally cannot refuse to rent, set different terms, '
            'or harass you for those reasons. If you think you were treated '
            'unfairly, you can contact HUD fair housing, California Civil Rights '
            'enforcement, or a local fair housing nonprofit for help.',
      ),
    ],
  ),
  _HousingSection(
    title: 'Avoid housing scams',
    intro:
        'Housing scams try to rush you into sending money or personal '
        'information before you can check that a rental is real. Here are '
        'common tricks, how they usually work, and how to spot them.',
    topics: [
      _HousingTopic(
        heading: 'Wire money and gift card payments',
        paragraph:
            'A scammer may claim to be out of town and ask you to wire money, '
            'send a money order, use Zelle, crypto, or buy gift cards to hold '
            'the unit. Once the money is sent, it is often gone. Real landlords '
            'almost never ask for gift cards or urgent wires before a signed '
            'lease. Pay only through a known office or trusted portal, and get '
            'a written receipt.',
      ),
      _HousingTopic(
        heading: 'Pay before you tour',
        paragraph:
            'Some scams demand a deposit, application fee, or first month rent '
            'before you have seen the place or met anyone from the property. '
            'They may say many people want it and you must pay today. A real '
            'rental process usually lets you view the unit first. If someone '
            'blocks a tour and still wants money, treat that as a warning.',
      ),
      _HousingTopic(
        heading: 'Rentals you cannot visit',
        paragraph:
            'Scammers often post nice photos of a home they do not control. They '
            'may say the keys are with a relative, the unit is being remodeled, '
            'or you can only see it after you pay. You arrive later and find it '
            'was never for rent, or someone else already lives there. Insist on '
            'seeing the exact unit in person, or on a live video walkthrough with '
            'a verified agent, before sending money.',
      ),
      _HousingTopic(
        heading: 'Fake listings and fake landlords',
        paragraph:
            'Stolen photos, copied ads, and fake landlord names appear on social '
            'media and listing sites. Prices that look far below the neighborhood '
            'average are a common lure. Check that the person can prove they own '
            'or manage the property. Look up the management company, visit the '
            'leasing office, and compare the listing to other ads for the same '
            'address. If details do not match, walk away.',
      ),
      _HousingTopic(
        heading: 'Phishing for documents and identity',
        paragraph:
            'Scammers may send a link and ask for your passport, Social Security '
            'number, bank login, or ID photos through email, text, or chat. They '
            'can use that information to steal your identity or money. Only share '
            'sensitive documents through a landlord or portal you have verified. '
            'Never click unexpected links, and never send full ID packets to '
            'strangers who contacted you first.',
      ),
    ],
  ),
];

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
    if (!_started) {
      return _buildIntro();
    }
    return _buildTutorial();
  }

  Widget _buildIntro() {
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
                    'Housing Navigator',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Icon(
                        Icons.home_outlined,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Learn all about housing in California.',
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
        title: const Text('Housing Navigator'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (section.intro.isNotEmpty)
                                        Text(
                                          section.intro,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      if (section.body.isNotEmpty) ...[
                                        if (section.intro.isNotEmpty)
                                          const SizedBox(height: 16),
                                        Text(
                                          section.body,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ],
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
                            if (section.body.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                section.body,
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
                      tween: Tween<double>(
                        begin: _step / total,
                        end: progress,
                      ),
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
    setState(() {
      _step -= 1;
      _aiError = null;
    });
  }

  void _next() {
    if (_step >= _sections.length - 1) return;
    setState(() {
      _step += 1;
      _aiError = null;
    });
  }

  void _finish() {
    context.goNamed(Routes.home);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    final section = _sections[_step];
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
      final answer = await ref.read(aiServiceProvider).askHousingQuestion(
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
            const Text(
              'Ask about housing',
              style: TextStyle(
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
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
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
                          ? 'Type a question…'
                          : 'Ask a follow-up…',
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
              child: Text(
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
