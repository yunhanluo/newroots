import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/brand_colors.dart';

class _SafetySection {
  const _SafetySection({
    required this.title,
    this.intro = '',
    this.body = '',
    this.topics = const [],
  });

  final String title;
  final String intro;
  final String body;
  final List<_SafetyTopic> topics;
}

class _SafetyTopic {
  const _SafetyTopic({
    required this.heading,
    required this.paragraph,
    this.url,
    this.phone,
    this.phoneLabel,
  });

  final String heading;
  final String paragraph;
  final String? url;
  /// Digits for `tel:` links, e.g. `911` or `18002221222`.
  final String? phone;
  final String? phoneLabel;
}

const _sections = <_SafetySection>[
  _SafetySection(
    title: 'Welcome',
    body:
        'Feeling safe in a new country takes time. Knowing who to call, what '
        'your rights are, and how to prepare for emergencies can reduce fear '
        'and help your family act quickly when something goes wrong.\n\n'
        'This guide covers emergency numbers you can tap to call, Know Your '
        'Rights basics, disaster preparedness, and trusted safety resources '
        'in California and the US.\n\n'
        'This is general information, not legal advice. For your own case, '
        'talk to a lawyer or a trusted legal aid clinic.',
  ),
  _SafetySection(
    title: 'Emergency numbers',
    intro:
        'Save these numbers in your phone. In a real emergency, call right '
        'away. Tap a number below to dial. If you are not sure whether '
        'something is an emergency, call anyway and explain what is happening.',
    topics: [
      _SafetyTopic(
        heading: '911 — Police, fire, and medical emergency',
        paragraph:
            'Use 911 for immediate danger: fire, serious injury, a crime in '
            'progress, or someone who cannot breathe. Tell the dispatcher your '
            'location first, then what happened. You can ask for an interpreter. '
            'Stay on the line until they say you can hang up.',
        phone: '911',
        phoneLabel: 'Call 911',
      ),
      _SafetyTopic(
        heading: '988 — Suicide and Crisis Lifeline',
        paragraph:
            'Call or text 988 if you or someone you love is in emotional '
            'crisis, thinking about suicide, or needs urgent mental health '
            'support. Help is free and confidential. Interpreters are available.',
        phone: '988',
        phoneLabel: 'Call 988',
      ),
      _SafetyTopic(
        heading: '211 — Local help and community resources',
        paragraph:
            '211 connects you to local food, shelter, utilities help, and '
            'community services. It is useful when you need support but it is '
            'not a life threatening emergency.',
        phone: '211',
        phoneLabel: 'Call 211',
      ),
      _SafetyTopic(
        heading: 'Poison Control — 1-800-222-1222',
        paragraph:
            'Call if someone may have swallowed medicine, cleaning products, '
            'plants, or chemicals by mistake. Have the product nearby if you '
            'can. They will tell you what to do next.',
        phone: '18002221222',
        phoneLabel: 'Call Poison Control',
      ),
      _SafetyTopic(
        heading: 'National Domestic Violence Hotline — 1-800-799-7233',
        paragraph:
            'Call if you or someone you know is being hurt, controlled, or '
            'threatened by a partner or family member. Help is confidential. '
            'You can also visit thehotline.org for chat options.',
        phone: '18007997233',
        phoneLabel: 'Call the hotline',
      ),
      _SafetyTopic(
        heading: 'Non-emergency police line',
        paragraph:
            'For noise complaints, theft reports after the fact, or questions '
            'that are not urgent, use your city non-emergency police number '
            'instead of 911. Search “[your city] police non emergency” or ask '
            'a librarian. Save that number next to 911.',
      ),
    ],
  ),
  _SafetySection(
    title: 'Know Your Rights',
    intro:
        'In the United States, people have important rights when dealing with '
        'police and immigration officers. Rules can be complex, and every '
        'situation is different. The points below are common basics many '
        'newcomers find useful. They are not a substitute for advice from an '
        'immigration or criminal defense lawyer. If you are ever unsure, ask '
        'for a lawyer and avoid guessing.',
    topics: [
      _SafetyTopic(
        heading: 'You can stay silent',
        paragraph:
            'You generally have the right to remain silent. You can say clearly, '
            '“I want to remain silent. I want a lawyer.” Then stop answering '
            'questions about your immigration status, where you were born, or '
            'how you entered the country. Do not lie and do not show fake '
            'documents. Lying to federal officers can create serious legal '
            'problems. Staying silent is not the same as running away or '
            'arguing. Speak calmly, keep your hands visible, and repeat that '
            'you want a lawyer if questions continue.',
      ),
      _SafetyTopic(
        heading: 'Ask if you are free to leave',
        paragraph:
            'If officers stop you on the street or in a public place, you can '
            'ask, “Am I free to leave?” If they say yes, you may calmly walk '
            'away. If they say no, you can remain silent and ask for a lawyer. '
            'You do not have to consent to a search of your bag, pockets, or '
            'phone. You can say, “I do not consent to a search.” Officers may '
            'still search in some situations, but clear words help protect you '
            'later. Do not physically resist a search. Stay calm and remember '
            'details so you can tell a lawyer what happened.',
      ),
      _SafetyTopic(
        heading: 'Home entry',
        paragraph:
            'In many situations, officers need a warrant signed by a judge to '
            'enter your home. You can ask them to slide the warrant under the '
            'door or hold it up to a window so you can read it. Check that it '
            'has your address and a judge’s signature. You do not have to open '
            'the door just because someone knocks or says they are the police. '
            'If you are unsure, do not open the door. Call a trusted lawyer, '
            'legal aid hotline, or a family member who can help you get advice '
            'in your language. Opening the door and inviting someone in can '
            'make it harder to challenge the entry later.',
      ),
      _SafetyTopic(
        heading: 'Carry important documents carefully',
        paragraph:
            'Keep copies of key documents in a safe place at home, and consider '
            'a small set of copies in a locked folder if you travel. Useful '
            'copies can include ID, immigration paperwork, and emergency '
            'contacts. Only share sensitive papers when you trust the person '
            'or office asking, such as a court, licensed lawyer, or official '
            'government appointment. Be careful with people who demand money '
            'or original documents for “immigration help” without a license. '
            'If someone pressures you to hand over passports or pay cash '
            'immediately, pause and check with a legal aid clinic first.',
      ),
      _SafetyTopic(
        heading: 'Get help from trusted legal organizations',
        paragraph:
            'For immigration questions, use licensed attorneys or accredited '
            'representatives. The Executive Office for Immigration Review and '
            'nonprofit legal aid clinics can help you find low cost help. Be '
            'careful of anyone who is not a licensed lawyer or accredited '
            'representative but offers immigration legal advice, fills out '
            'forms for a fee, or promises a guaranteed visa or green card. '
            'Scammers sometimes use official sounding titles to look '
            'trustworthy. Ask for their full name, license or accreditation, '
            'and a written receipt. If they refuse, walk away and check with a '
            'legal aid clinic before you pay.',
        url: 'https://www.justice.gov/eoir/find-legal-representation',
      ),
    ],
  ),
  _SafetySection(
    title: 'Disaster preparedness',
    intro:
        'California faces earthquakes, wildfires, heat waves, and floods. A '
        'simple family plan makes emergencies less chaotic, especially if '
        'English is not your first language. You do not need expensive gear. '
        'Start with a meeting place, a small bag, and a way to get alerts.',
    topics: [
      _SafetyTopic(
        heading: 'Make a family plan',
        paragraph:
            'Decide where you will meet if phones stop working, such as a '
            'neighbor’s house, a school, or a park nearby. Also choose a second '
            'meeting place farther away in case your block is closed. Write '
            'down out of area contact numbers for a relative or friend who '
            'lives in another city. Practice how you would leave your home '
            'quickly, including at night. Make sure children know their full '
            'name, address, and a parent phone number. If someone in your home '
            'needs medicine, mobility help, or language support, plan who will '
            'assist them.',
      ),
      _SafetyTopic(
        heading: 'Build a small go bag',
        paragraph:
            'Keep a bag ready that you can grab in one minute. Include water, '
            'snacks, flashlight, batteries, copies of IDs and important papers, '
            'a small first aid kit, masks, medications, cash in small bills, '
            'and phone chargers. Add a whistle, a warm layer, and any baby or '
            'elder supplies your family needs. Store the bag where everyone can '
            'reach it. Check it every few months and replace expired food, '
            'water, and medicine. Keep a shorter version in your car if you '
            'drive.',
      ),
      _SafetyTopic(
        heading: 'Know local alerts',
        paragraph:
            'Turn on Wireless Emergency Alerts on your phone so urgent warnings '
            'can reach you even if you are not watching the news. Sign up for '
            'your city or county emergency alerts if available. During '
            'wildfires, storms, and floods, follow official updates from your '
            'city, county Office of Emergency Services, or Cal OES. Do not '
            'rely only on social media rumors. If an alert says to evacuate, '
            'leave early rather than waiting to see if conditions improve.',
        url: 'https://www.caloes.ca.gov/',
      ),
      _SafetyTopic(
        heading: 'Earthquakes',
        paragraph:
            'If you feel shaking, Drop, Cover, and Hold On under a sturdy table '
            'or desk if you can. Protect your head and neck. Stay away from '
            'windows, mirrors, and tall furniture that can fall. If you are '
            'outside, move to an open area away from buildings, trees, and '
            'power lines. If you are in bed, stay there and cover your head '
            'with a pillow unless you are under a heavy light fixture. After '
            'shaking stops, check for injuries and gas smells. If you smell '
            'gas, leave the building and call for help from outside. Expect '
            'aftershocks. If you must evacuate, take your go bag and follow '
            'official instructions.',
      ),
      _SafetyTopic(
        heading: 'Wildfire and smoke',
        paragraph:
            'If officials tell you to evacuate, leave early. Roads can close '
            'quickly. Pack documents, medications, phones, chargers, and pets '
            'first. Wear long sleeves and sturdy shoes if you can. During '
            'heavy smoke, stay indoors when possible, close windows, and set '
            'air conditioning to recirculate if you have it. If you must go '
            'outside, use a well fitted mask designed to filter fine particles '
            'when you have one. Check airnow.gov for air quality. People with '
            'asthma, heart problems, young children, and older adults should '
            'be especially careful during smoke days.',
        url: 'https://www.airnow.gov/',
      ),
      _SafetyTopic(
        heading: 'Floods',
        paragraph:
            'Floods can happen after heavy rain, dam releases, or when storm '
            'drains overflow. Move to higher ground as soon as local officials '
            'warn you. Never walk, swim, or drive through flood water. Water '
            'that looks shallow can hide strong currents, open drains, or '
            'washed out roads. Six inches of moving water can knock a person '
            'down, and one to two feet can carry a car away. If your car stalls '
            'in rising water, get out and move to higher ground if it is safe. '
            'Turn around if a road is closed or covered with water. After a '
            'flood, avoid damaged buildings until they are checked, throw out '
            'food that touched flood water, and watch for contaminated water '
            'and downed power lines. Listen for boil water notices from your '
            'city or county.',
        url: 'https://www.ready.gov/floods',
      ),
      _SafetyTopic(
        heading: 'Heat waves',
        paragraph:
            'Extreme heat can be dangerous, especially for children, older '
            'adults, pregnant people, and anyone working outside. Drink water '
            'often, even if you do not feel thirsty. Stay in cool indoor '
            'places during the hottest part of the day. Use fans, cool '
            'showers, and damp cloths if you do not have air conditioning. '
            'Check on neighbors and family members who live alone. Never leave '
            'children or pets in a parked car. Warning signs of heat illness '
            'include dizziness, headache, nausea, confusion, and stopping '
            'sweat. If someone becomes confused or passes out from heat, call '
            '911.',
        url: 'https://www.ready.gov/heat',
      ),
    ],
  ),
  _SafetySection(
    title: 'Trusted safety resources',
    intro:
        'Use official and well known organizations when you need deeper help. '
        'These sites are a safe starting point.',
    topics: [
      _SafetyTopic(
        heading: 'Ready.gov',
        paragraph:
            'Federal emergency preparedness guides for families, including '
            'checklists and hazard information in multiple languages.',
        url: 'https://www.ready.gov/',
      ),
      _SafetyTopic(
        heading: 'California Office of Emergency Services (Cal OES)',
        paragraph:
            'State emergency information, alerts, and preparedness resources '
            'for California residents.',
        url: 'https://www.caloes.ca.gov/',
      ),
      _SafetyTopic(
        heading: 'American Red Cross',
        paragraph:
            'Disaster relief, first aid classes, and local chapter support '
            'after fires, floods, and other emergencies.',
        url: 'https://www.redcross.org/',
      ),
      _SafetyTopic(
        heading: 'Immigrant Legal Resource Center (ILRC)',
        paragraph:
            'Educational Know Your Rights materials and referrals related to '
            'immigration. This is information, not a substitute for your own '
            'lawyer.',
        url: 'https://www.ilrc.org/',
      ),
      _SafetyTopic(
        heading: 'findhelp.org',
        paragraph:
            'Search by ZIP code for free or low cost local help with food, '
            'housing, health, and more.',
        url: 'https://www.findhelp.org/',
      ),
    ],
  ),
];

/// Feature 10: Community Safety Guide.
class SafetyGuideScreen extends StatefulWidget {
  const SafetyGuideScreen({super.key});

  @override
  State<SafetyGuideScreen> createState() => _SafetyGuideScreenState();
}

class _SafetyGuideScreenState extends State<SafetyGuideScreen> {
  bool _started = false;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    if (!_started) return _buildIntro();
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
                    'Community Safety Guide',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Icon(
                        Icons.emergency_outlined,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Emergency numbers, your rights, and how to prepare.',
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
        title: const Text('Community Safety Guide'),
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
                              if (topic.phone != null) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FilledButton.icon(
                                    onPressed: () => _callPhone(topic.phone!),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: kBrandGreen,
                                      minimumSize: const Size(0, 44),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.call, size: 18),
                                    label: Text(
                                      topic.phoneLabel ?? 'Call ${topic.phone}',
                                    ),
                                  ),
                                ),
                              ],
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
    setState(() => _step -= 1);
  }

  void _next() {
    if (_step >= _sections.length - 1) return;
    setState(() => _step += 1);
  }

  void _finish() {
    context.goNamed(Routes.home);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callPhone(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: digits);
    await launchUrl(uri);
  }
}
