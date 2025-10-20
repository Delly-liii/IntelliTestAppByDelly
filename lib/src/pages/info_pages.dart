// info_pages.dart
import 'package:flutter/material.dart';

const kPrimary = Color(0xFF2563EB);
const kSecondary = Color(0xFF60A5FA);
const kAccent = Color(0xFFFBBF24);

EdgeInsets get kPagePadding =>
    const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
BoxConstraints get kMaxWidth => const BoxConstraints(maxWidth: 1100);

TextStyle h1(BuildContext c) =>
    Theme.of(c).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700);
TextStyle h2(BuildContext c) =>
    Theme.of(c).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700);
TextStyle body(BuildContext c) =>
    Theme.of(c).textTheme.bodyMedium!.copyWith(height: 1.6);

// ABOUT
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About IntelliTest')),
      body: Center(
        child: ConstrainedBox(
          constraints: kMaxWidth,
          child: ListView(
            padding: kPagePadding,
            children: [
              const _HeroBanner(
                title: 'A modern assessment platform for educators',
                subtitle:
                    'IntelliTest helps teams create high‑quality tests, analyze performance, and manage courses with speed and confidence.',
              ),
              const SizedBox(height: 24),
              _CardSection(
                title: 'Our Mission',
                child: Text(
                  'Empower educators with intuitive tooling and trustworthy analytics so they can focus on teaching—not busywork.',
                  style: body(context),
                ),
              ),
              const SizedBox(height: 16),
              const _CardSection(
                title: 'What We Offer',
                child: _Bullets(items: [
                  'ML‑assisted question generation (MCQ, short answer, essay)',
                  'Smart distractors and difficulty calibration',
                  'Flexible test assembly and versioning',
                  'Real‑time performance dashboards and insights',
                  'Role‑based access and secure data handling',
                ]),
              ),
              const SizedBox(height: 16),
              const _CardSection(
                title: 'Why IntelliTest',
                child: _GridFeatures(items: [
                  _Feature(
                      icon: Icons.auto_awesome,
                      title: 'Faster Authoring',
                      desc:
                          'Draft questions from course materials in minutes.'),
                  _Feature(
                      icon: Icons.analytics,
                      title: 'Deeper Insights',
                      desc:
                          'See trends, outliers, and topic mastery at a glance.'),
                  _Feature(
                      icon: Icons.security,
                      title: 'Secure by Design',
                      desc: 'RBAC, encryption, backups, and auditability.'),
                  _Feature(
                      icon: Icons.rocket_launch,
                      title: 'Scalable',
                      desc:
                          'Built to support programs from dozens to thousands.'),
                ]),
              ),
              const SizedBox(height: 16),
              const _CardSection(
                title: 'Values',
                child: _Bullets(items: [
                  'Trust and privacy first',
                  'Teacher‑in‑the‑loop by default',
                  'Accessibility and inclusion',
                  'Reliability and transparency',
                ]),
              ),
              const SizedBox(height: 32),
              _CtaBar(
                text: 'Ready to see IntelliTest in action?',
                buttonText: 'Get Started',
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PRIVACY POLICY
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
          constraints: kMaxWidth,
          child: ListView(
            padding: kPagePadding,
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
                  style: body(context),
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
                  style: body(context),
                ),
              ),
              _PolicySection(
                title: 'Data Retention',
                titleStyle: sectionTitle,
                child: Text(
                  'We retain information only as long as necessary for the purposes outlined or as required by law. You may request deletion, subject to legal and contractual limits.',
                  style: body(context),
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
                  style: body(context),
                ),
              ),
              _PolicySection(
                title: 'International Transfers',
                titleStyle: sectionTitle,
                child: Text(
                  'Where data is transferred across borders, we rely on appropriate safeguards, including Standard Contractual Clauses or equivalent frameworks.',
                  style: body(context),
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
                  style: body(context),
                ),
              ),
              _PolicySection(
                title: 'Changes to this Policy',
                titleStyle: sectionTitle,
                child: Text(
                  'We may update this policy to reflect changes in technology, law, or our services. We will post updates and revise the “Last updated” date.',
                  style: body(context),
                ),
              ),
              _PolicySection(
                title: 'Contact Us',
                titleStyle: sectionTitle,
                child: Text(
                  'For privacy questions or requests, contact: privacy@intellitest.app',
                  style: body(context),
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

// Reusable UI
class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeroBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [kPrimary, kSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: h1(context).copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: body(context).copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: h2(context)),
          const SizedBox(height: 10),
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
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.circle, size: 8, color: kPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e, style: body(context))),
              ]),
            ),
          )
          .toList(),
    );
  }
}

class _GridFeatures extends StatelessWidget {
  final List<_Feature> items;
  const _GridFeatures({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 900;
      final w = isNarrow ? c.maxWidth : (c.maxWidth - 32) / 2;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: items
            .map((f) => SizedBox(width: w, child: _FeatureCard(feature: f)))
            .toList(),
      );
    });
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  const _Feature({required this.icon, required this.title, required this.desc});
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(feature.icon, color: kPrimary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(feature.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(feature.desc, style: body(context)),
            ]),
          ),
        ],
      ),
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
        color: kAccent,
        borderRadius: BorderRadius.circular(12),
      ),
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
