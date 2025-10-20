// contact_page.dart
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF2563EB);
const _kSecondary = Color(0xFF60A5FA);
const _kAccent = Color(0xFFFBBF24);
const _kMaxWidth = BoxConstraints(maxWidth: 1100);
const _kPagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 24);

TextStyle _h1(BuildContext c) =>
    Theme.of(c).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700);
TextStyle _h2(BuildContext c) =>
    Theme.of(c).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700);
TextStyle _body(BuildContext c) =>
    Theme.of(c).textTheme.bodyMedium!.copyWith(height: 1.6);

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Center(
        child: ConstrainedBox(
          constraints: _kMaxWidth,
          child: ListView(
            padding: _kPagePadding,
            children: [
              const _HeroBanner(
                title: 'Get in Touch',
                subtitle:
                    'We’d love to hear from you! Reach out for support, feedback, or inquiries.',
              ),
              const SizedBox(height: 24),
              const _CardSection(
                title: 'Our Contact Information',
                child: _Bullets(items: [
                  'Email: support@intellitest.app',
                  'Phone: +1 234 567 890',
                  'Address: 123 IntelliTest Avenue, Suite 400, Tech City, USA',
                  'Working Hours: Mon-Fri, 9 AM - 6 PM',
                ]),
              ),
              const SizedBox(height: 16),
              _CardSection(
                title: 'Send Us a Message',
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14)),
                        onPressed: () {
                          // TODO: Add form submission logic
                        },
                        child: const Text('Send Message'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _CtaBar(
                text: 'Need immediate assistance?',
                buttonText: 'Contact Support',
                onPressed: () {
                  // Navigate or trigger support action
                },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _h1(context).copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: _body(context).copyWith(color: Colors.white70)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _h2(context)),
            const SizedBox(height: 10),
            child,
          ],
        ),
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
                  ],
                ),
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
          color: _kAccent, borderRadius: BorderRadius.circular(12)),
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
