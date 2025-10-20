// privacy_policy_page.dart
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF2563EB);
const _kSecondary = Color(0xFF60A5FA);
const _kMaxWidth = BoxConstraints(maxWidth: 1100);
const _kPagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 24);

TextStyle _body(BuildContext c) =>
    Theme.of(c).textTheme.bodyMedium!.copyWith(height: 1.6);

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionTitle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w700);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Center(
        child: ConstrainedBox(
          constraints: _kMaxWidth,
          child: ListView(
            padding: _kPagePadding,
            children: [
              const _HeroBanner(
                title: 'Your privacy matters',
                subtitle:
                    'We collect only what we need, protect it carefully, and give you control.',
              ),
              const SizedBox(height: 24),
              _PolicySection(
                title: 'Introduction',
                titleStyle: sectionTitle,
                child: Text(
                  'This Privacy Policy explains how IntelliTest (“we”, “us”) collects, uses, and safeguards your information when you use our services.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'Information We Collect',
                titleStyle: sectionTitle,
                child: const _Bullets(items: [
                  'Account data: name, email, role, institution.',
                  'Content data: uploaded materials, generated questions, tests.',
                  'Usage data: app interactions, device/browser metadata.',
                  'Support data: messages and correspondence.',
                ]),
              ),
              _PolicySection(
                title: 'How We Use Information',
                titleStyle: sectionTitle,
                child: const _Bullets(items: [
                  'Provide and improve the platform’s features and reliability.',
                  'Generate questions, distractors, and difficulty estimates.',
                  'Analyze performance trends and deliver dashboards.',
                  'Detect abuse, ensure security, and comply with law.',
                  'Communicate updates, support, and important notices.',
                ]),
              ),
              _PolicySection(
                title: 'Legal Bases',
                titleStyle: sectionTitle,
                child: Text(
                  'We process data based on performance of a contract, legitimate interests (e.g., product improvement, security), consent where required, and legal obligations.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'Data Retention',
                titleStyle: sectionTitle,
                child: Text(
                  'We retain information only as long as necessary for the purposes outlined or as required by law. You may request deletion, subject to legal and contractual limits.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'Security',
                titleStyle: sectionTitle,
                child: const _Bullets(items: [
                  'Encryption in transit and at rest where applicable.',
                  'Role‑based access control and audit trails.',
                  'Backups and disaster recovery procedures.',
                ]),
              ),
              _PolicySection(
                title: 'Sharing & Third Parties',
                titleStyle: sectionTitle,
                child: Text(
                  'We do not sell your data. We may share with service providers under strict agreements to operate the platform (e.g., hosting, analytics) and to comply with legal requests.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'International Transfers',
                titleStyle: sectionTitle,
                child: Text(
                  'Where data is transferred across borders, we rely on appropriate safeguards, including Standard Contractual Clauses or equivalent frameworks.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'Your Rights',
                titleStyle: sectionTitle,
                child: const _Bullets(items: [
                  'Access, correct, or delete your personal data.',
                  'Object to or restrict certain processing.',
                  'Port data where technically feasible.',
                  'Withdraw consent where processing relies on consent.',
                ]),
              ),
              _PolicySection(
                title: 'Children’s Privacy',
                titleStyle: sectionTitle,
                child: Text(
                  'Our services are intended for authorized educational use. Where required, additional consent and safeguards apply for minors.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'Changes to this Policy',
                titleStyle: sectionTitle,
                child: Text(
                  'We may update this policy to reflect changes in technology, law, or our services. We will post updates and revise the “Last updated” date.',
                  style: _body(context),
                ),
              ),
              _PolicySection(
                title: 'Contact Us',
                titleStyle: sectionTitle,
                child: Text(
                  'For privacy questions or requests, contact: privacy@intellitest.app',
                  style: _body(context),
                ),
              ),
              const SizedBox(height: 16),
              _CtaBar(
                text: 'Have questions about your privacy?',
                buttonText: 'Contact Privacy Team',
                onPressed: () => Navigator.pushNamed(context, '/contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeroBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_kPrimary, _kSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(height: 1.6, color: Colors.white70)),
      ]),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final Widget child;
  const _PolicySection(
      {required this.title, required this.titleStyle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          child,
        ]),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Icon(Icons.circle, size: 8, color: _kPrimary)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e, style: _body(context))),
                    ]),
              ))
          .toList(),
    );
  }
}

class _CtaBar extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback onPressed;
  const _CtaBar(
      {required this.text, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFFBBF24),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w700)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.black87, foregroundColor: Colors.white),
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
