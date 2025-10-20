import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intellitest_app/src/pages/contact_page.dart';
import 'package:intellitest_app/src/pages/dashboard_page.dart';
import 'package:intellitest_app/src/pages/info_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Brand colors
  static const Color kPrimary = Color(0xFF2563EB);
  static const Color kSecondary = Color(0xFF60A5FA);
  static const Color kAccent = Color(0xFFFBBF24);

  final PageController _controller = PageController();
  final ScrollController _scrollController = ScrollController();

  // Section anchors
  final _featuresKey = GlobalKey();
  final _testimonialsKey = GlobalKey();
  final _pricingKey = GlobalKey();
  final _ctaKey = GlobalKey();
  final _footerKey = GlobalKey();
  final _about = GlobalKey();
  int _currentPage = 0;

  final List<_Slide> slides = const [
    _Slide(
      title: 'Create Tests Effortlessly',
      subtitle:
          'Generate questions with AI assistance and customize in seconds.',
      icon: Icons.edit_note_rounded,
    ),
    _Slide(
      title: 'Analyze Performance',
      subtitle: 'Beautiful dashboards to understand progress instantly.',
      icon: Icons.analytics_rounded,
    ),
    _Slide(
      title: 'Manage Courses',
      subtitle: 'Organize cohorts, resources, and permissions with ease.',
      icon: Icons.school_rounded,
    ),
  ];

  // Typography
  TextStyle get _h1 => GoogleFonts.poppins(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      );
  TextStyle get _subtitle => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
        height: 1.5,
      );
  TextStyle get _cardTitle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      );
  TextStyle get _cardBody => GoogleFonts.roboto(
        fontSize: 14,
        color: Colors.black87,
        height: 1.5,
      );

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goLogin() => Navigator.pushNamed(context, '/login');
  void _goRegister() => Navigator.pushNamed(context, '/register');

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildMobileDrawer(),
      body: ScrollConfiguration(
        behavior: const _NoGlowBehavior(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildHeader(context),
              _buildHero(context),
              _sectionSpacer(),
              _featuresSectionWrapper(
                child: Container(
                    key: _featuresKey, child: _buildFeatures(context)),
              ),
              _sectionSpacer(),
              _testimonialsSectionWrapper(
                child: Container(
                    key: _testimonialsKey, child: _buildTestimonials(context)),
              ),
              _sectionSpacer(),
              Container(key: _pricingKey, child: _buildPricing(context)),
              _sectionSpacer(),
              Container(key: _ctaKey, child: _buildCta(context)),
              Container(key: _footerKey, child: _buildFooter(context)),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER with NavBar
  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          children: [
            // Logo
            Text("IntelliTest",
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kPrimary)),
            const Spacer(),
            if (!isMobile) ...[
              _navLink(
                  "About",
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ))),
              _navLink(
                  "Privacy & Terms",
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ))),
              _navLink(
                  "Contacts",
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ))),
              _navLink(
                  "dashboardr",
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ))),
              const SizedBox(width: 20),
              _HoverButton(
                builder: (hovered) => TextButton(
                  onPressed: _goLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: hovered ? kPrimary : Colors.black87,
                  ),
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(width: 8),
              _HoverButton(
                builder: (hovered) => ElevatedButton(
                  onPressed: _goRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: hovered ? 6 : 2,
                  ),
                  child: const Text("Register"),
                ),
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Text(
          text,
          style: GoogleFonts.roboto(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
    );
  }

  Drawer _buildMobileDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              child: Text("IntelliTest",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kPrimary)),
            ),
            ListTile(
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_featuresKey);
              },
            ),
            ListTile(
              title: const Text("Contacts"),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_testimonialsKey);
              },
            ),
            ListTile(
              title: const Text("Privacy & Terms"),
              onTap: () {
                Navigator.pop(context);
                _scrollTo(_pricingKey);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _goRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text("Register"),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _goLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HERO
  Widget _buildHero(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 900;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 28 : 56),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              child: Column(
                children: [
                  SizedBox(
                    height: isMobile ? 540 : 500,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        final slide = slides[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 0 : 12,
                          ),
                          child: isMobile
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSlideText(slide, isMobile),
                                    const SizedBox(height: 24),
                                    _buildSlideIllustration(slide, isMobile),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child:
                                            _buildSlideText(slide, isMobile)),
                                    Expanded(
                                        child: _buildSlideIllustration(
                                            slide, isMobile)),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: slides.length,
                    effect: const ExpandingDotsEffect(
                      expansionFactor: 3,
                      spacing: 8,
                      dotHeight: 8,
                      dotWidth: 8,
                      dotColor: Colors.white54,
                      activeDotColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Slide Text
  Widget _buildSlideText(_Slide slide, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 620 : 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slide.title, style: _h1),
              const SizedBox(height: 16),
              Text(slide.subtitle, style: _subtitle),
              const SizedBox(height: 36),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: _goRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      textStyle: GoogleFonts.roboto(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Get started'),
                  ),
                  OutlinedButton(
                    onPressed: _goLogin,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      textStyle: GoogleFonts.roboto(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Wrap(
                spacing: 14,
                runSpacing: 10,
                children: [
                  _Bullet('AI-assisted question generation'),
                  _Bullet('Real-time analytics'),
                  _Bullet('Role-based access'),
                  _Bullet('Secure and reliable'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Slide Illustration
  Widget _buildSlideIllustration(_Slide slide, bool isMobile) {
    final size = isMobile ? 220.0 : 320.0;
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Colors.white24, Colors.white10, Colors.transparent],
                  stops: [0.2, 0.7, 1.0],
                ),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
            Container(
              height: size * 0.7,
              width: size * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(slide.icon, size: size * 0.35, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Features
  Widget _featuresSectionWrapper({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      );

  Widget _buildFeatures(BuildContext context) {
    const items = [
      _Feature(
          Icons.edit, 'Create Tests', 'Build quizzes easily with ML help.'),
      _Feature(
          Icons.analytics, 'Analyze Performance', 'Track trends and outcomes.'),
      _Feature(Icons.book, 'Manage Courses', 'Organize courses and students.'),
      _Feature(Icons.security_rounded, 'Secure & Reliable',
          'Role-based access & backups.'),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _sectionHeader('Powerful Features',
                'Focused tools to help you teach and assess better.'),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                final isNarrow = c.maxWidth < 900;
                final cardWidth = isNarrow ? c.maxWidth : (c.maxWidth - 48) / 3;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: items
                      .map((f) =>
                          SizedBox(width: cardWidth, child: _featureCard(f)))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(_Feature f) => Card(
        elevation: 4,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Icon(f.icon, size: 46, color: kPrimary),
              const SizedBox(height: 14),
              Text(f.title, style: _cardTitle),
              const SizedBox(height: 8),
              Text(f.desc, style: _cardBody, textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  // Testimonials
  Widget _testimonialsSectionWrapper({required Widget child}) => Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 56),
        child: child,
      );

  Widget _buildTestimonials(BuildContext context) {
    const items = [
      _Testimonial('“IntelliTest saved me hours grading!”', 'Jane Doe'),
      _Testimonial('“My students love the analytics!”', 'John Smith'),
      _Testimonial('“The dashboards are a game changer.”', 'Abeni A.'),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _sectionHeader('What Educators Say',
                'Trusted by teachers and departments worldwide.'),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: items
                  .map((t) => SizedBox(width: 300, child: _testimonialCard(t)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _testimonialCard(_Testimonial t) => Card(
        margin: const EdgeInsets.all(4),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(Icons.format_quote_rounded,
                  size: 36, color: kSecondary),
              const SizedBox(height: 10),
              Text(t.quote,
                  style: _cardBody.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('— ${t.author}',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  // Pricing
  Widget _buildPricing(BuildContext context) => Container(
        width: double.infinity,
        color: const Color(0xFFF6F7FB),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              _sectionHeader(
                  'Simple pricing', 'Start free, upgrade when you grow.'),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isNarrow = c.maxWidth < 800;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _planCard(
                      title: 'Free',
                      subtitle: 'Everything you need to begin.',
                      features: const ['Unlimited quizzes', 'Basic analytics'],
                      cta: 'Choose Free',
                      onTap: _goRegister,
                      highlighted: false,
                      width: isNarrow ? c.maxWidth : (c.maxWidth - 16) / 2,
                    ),
                    _planCard(
                      title: 'Pro',
                      subtitle: 'Advanced insights and controls.',
                      features: const [
                        'AI generation',
                        'Advanced dashboards',
                        'Priority support'
                      ],
                      cta: 'Choose Pro',
                      onTap: _goRegister,
                      highlighted: true,
                      width: isNarrow ? c.maxWidth : (c.maxWidth - 16) / 2,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      );

  Widget _planCard({
    required String title,
    required String subtitle,
    required List<String> features,
    required String cta,
    required VoidCallback onTap,
    required bool highlighted,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: highlighted ? 5 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 20)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style:
                      GoogleFonts.roboto(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 14),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: kAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(f,
                                style: GoogleFonts.roboto(fontSize: 14))),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlighted ? kPrimary : Colors.white,
                  foregroundColor: highlighted ? Colors.white : Colors.black87,
                  side: highlighted
                      ? BorderSide.none
                      : const BorderSide(color: Colors.black12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(cta),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CTA
  Widget _buildCta(BuildContext context) => Container(
        width: double.infinity,
        color: kAccent,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text('Start your free account now',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                'Create tests, analyze performance, and manage courses with ease.',
                style: GoogleFonts.roboto(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      );

  // Footer
  Widget _buildFooter(BuildContext context) => Container(
        width: double.infinity,
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 8,
                children: [
                  _footerLink('Features', () => _scrollTo(_featuresKey)),
                  _footerLink(
                      'Testimonials', () => _scrollTo(_testimonialsKey)),
                  _footerLink('Pricing', () => _scrollTo(_pricingKey)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '© 2025 IntelliTest. All rights reserved.',
                style: GoogleFonts.roboto(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );

  Widget _footerLink(String text, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Text(text,
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14)),
      );

  Widget _sectionHeader(String title, String subtitle) => Column(
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center),
        ],
      );

  Widget _sectionSpacer() => const SizedBox(height: 48);
}

class _HoverButton extends StatefulWidget {
  final Widget Function(bool hovered) builder;
  const _HoverButton({required this.builder});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  void _setHovered(bool v) {
    if (_hovered == v) return;
    setState(() => _hovered = v);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _setHovered(true),
        onTapUp: (_) => _setHovered(false),
        onTapCancel: () => _setHovered(false),
        child: widget.builder(_hovered),
      ),
    );
  }
}

// Helpers
class _Slide {
  final String title, subtitle;
  final IconData icon;
  const _Slide(
      {required this.title, required this.subtitle, required this.icon});
}

class _Feature {
  final IconData icon;
  final String title, desc;
  const _Feature(this.icon, this.title, this.desc);
}

class _Testimonial {
  final String quote, author;
  const _Testimonial(this.quote, this.author);
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: _State.kAccent),
        const SizedBox(width: 6),
        Text(text,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}

// No overscroll glow (updated API)
class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

// Access to constants in _Bullet
class _State {
  static const kAccent = _WelcomePageState.kAccent;
}
