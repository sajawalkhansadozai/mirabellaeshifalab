import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'booking_dialog.dart';
import 'theme.dart';

// ============================ Reviews ============================
class Review {
  final String name;
  final int rating; // 1..5
  final String text;
  final String when; // short label like "Jan 2025"
  Review({
    required this.name,
    required this.rating,
    required this.text,
    required this.when,
  });
}

final kReviews = <Review>[
  Review(
    name: 'Ayesha K.',
    rating: 5,
    when: 'Feb 2025',
    text:
        'Booked home sample collection. Phlebotomist was on time and very professional. Reports were quick!',
  ),
  Review(
    name: 'Hassan R.',
    rating: 5,
    when: 'Jan 2025',
    text:
        'Clean facility and friendly staff. CBC and thyroid tests delivered same day.',
  ),
  Review(
    name: 'Maria S.',
    rating: 4,
    when: 'Dec 2024',
    text:
        'Affordable packages. Reception helped me pick the right tests for annual checkup.',
  ),
  Review(
    name: 'Bilal A.',
    rating: 5,
    when: 'Nov 2024',
    text: 'Accurate results and smooth experience. Will return for follow-ups.',
  ),
  Review(
    name: 'Zainab T.',
    rating: 5,
    when: 'Oct 2024',
    text:
        'Great communication. Got results on email and WhatsApp. Highly recommended.',
  ),
  Review(
    name: 'Omar N.',
    rating: 4,
    when: 'Sep 2024',
    text: 'Quick turnaround and courteous staff. Parking was easy too.',
  ),
];

// ============================ Landing ============================
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _reviewsKey = GlobalKey();
  final _contactKey = GlobalKey();

  late final AnimationController _staggerCtrl;
  double _scrollY = 0;

  // Lock → unlock state when navigating to admin
  bool _adminUnlocking = false;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scroll.addListener(() => setState(() => _scrollY = _scroll.offset));
  }

  @override
  void dispose() {
    _scroll.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  Future<void> _openBookingDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BookingDialog(),
    );
  }

  Future<void> _goToAdmin() async {
    if (_adminUnlocking) return;
    setState(() => _adminUnlocking = true);
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    await Navigator.of(context).pushNamed('/admin');
    if (!mounted) return;
    setState(() => _adminUnlocking = false);
  }

  @override
  Widget build(BuildContext context) {
    final topBarOpaque = (_scrollY > 50) ? 0.98 : 0.95;
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _DrawerHeaderBrand(onTap: () => _scrollTo(_homeKey)),
                    _NavTile('Home', () => _scrollTo(_homeKey)),
                    _NavTile('Services', () => _scrollTo(_servicesKey)),
                    _NavTile('About', () => _scrollTo(_featuresKey)),
                    _NavTile('Reviews', () => _scrollTo(_reviewsKey)),
                    _NavTile('Contact', () => _scrollTo(_contactKey)),
                    const Divider(),
                    // Lock item (replaces "Admin" text)
                    ListTile(
                      leading: Icon(
                        _adminUnlocking
                            ? Icons.lock_open_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      title: const Text('Admin'),
                      onTap: () async {
                        Navigator.of(context).maybePop(); // close drawer
                        await _goToAdmin();
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Brand gradient background
          Container(decoration: const BoxDecoration(gradient: redHeroGradient)),
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 72,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      color: Colors.white.withOpacity(topBarOpaque),
                    ),
                  ),
                ),
                titleSpacing: 0,
                title: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _scrollTo(_homeKey),
                            child: Row(
                              children: [
                                // LOGO
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/logo.png', // <-- add this in pubspec.yaml
                                    height: 52,
                                    width: 52,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Mirabella eShifa Lab',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: BrandColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (!isMobile)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _NavLink('Home', () => _scrollTo(_homeKey)),
                                _NavLink(
                                  'Services',
                                  () => _scrollTo(_servicesKey),
                                ),
                                _NavLink(
                                  'About',
                                  () => _scrollTo(_featuresKey),
                                ),
                                _NavLink(
                                  'Reviews',
                                  () => _scrollTo(_reviewsKey),
                                ),
                                _NavLink(
                                  'Contact',
                                  () => _scrollTo(_contactKey),
                                ),
                                const SizedBox(width: 4),
                                // Lock icon instead of "Admin" text
                                IconButton(
                                  tooltip: _adminUnlocking
                                      ? 'Unlocking…'
                                      : 'Admin',
                                  onPressed: _goToAdmin,
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    transitionBuilder: (child, anim) =>
                                        FadeTransition(
                                          opacity: anim,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.9,
                                              end: 1.0,
                                            ).animate(anim),
                                            child: child,
                                          ),
                                        ),
                                    child: Icon(
                                      _adminUnlocking
                                          ? Icons.lock_open_rounded
                                          : Icons.lock_outline_rounded,
                                      key: ValueKey<bool>(_adminUnlocking),
                                      color: BrandColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Builder(
                              builder: (ctx) => IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                                tooltip: 'Menu',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Hero
              SliverToBoxAdapter(
                child: _SectionWrapper(
                  key: _homeKey,
                  child: _HeroSection(onCTAPressed: _openBookingDialog),
                ),
              ),

              // Features (About)
              SliverToBoxAdapter(
                child: _FeaturesSection(
                  controller: _staggerCtrl,
                  key: _featuresKey,
                ),
              ),

              // Services
              SliverToBoxAdapter(
                child: _ServicesSection(
                  controller: _staggerCtrl,
                  key: _servicesKey,
                ),
              ),

              // Reviews
              SliverToBoxAdapter(child: _ReviewsSection(key: _reviewsKey)),

              // Contact
              SliverToBoxAdapter(
                child: _ContactSection(
                  controller: _staggerCtrl,
                  key: _contactKey,
                ),
              ),

              // Footer
              const SliverToBoxAdapter(child: _Footer()),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================ Sections ============================

class _SectionWrapper extends StatelessWidget {
  const _SectionWrapper({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onCTAPressed});
  final VoidCallback onCTAPressed;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isNarrow = w < 900;

    return Padding(
      padding: EdgeInsets.only(top: isNarrow ? 120 : 140, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'MIRABELLA ESHIFA LAB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isNarrow ? 34 : 54,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              shadows: const [
                Shadow(
                  blurRadius: 8,
                  offset: Offset(0, 2),
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Health, Our Priority',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: isNarrow ? 18 : 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accurate, reliable, and timely diagnostics — with convenient home sample collection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: isNarrow ? 15 : 18,
            ),
          ),
          const SizedBox(height: 28),
          _GradientButton(
            onPressed: onCTAPressed,
            label: 'Book Your Test Today',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({super.key, required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final titleAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
    );
    final gridAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.15, 1.00, curve: Curves.easeOut),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _SectionWrapper(
        child: Column(
          children: [
            FadeTransition(
              opacity: titleAnim,
              child: const Text(
                'Why Choose Mirabella eShifa Lab?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: gridAnim,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, (1 - gridAnim.value) * 30),
                  child: Opacity(
                    opacity: gridAnim.value,
                    child: const _ResponsiveGrid(
                      minTileWidth: 300,
                      gap: 20,
                      children: [
                        _FeatureCard(
                          icon: '🏥',
                          title: 'Modern, Fully Equipped Lab',
                          text:
                              'Clean, purpose-built facility with modern analyzers.',
                        ),
                        _FeatureCard(
                          icon: '👩‍⚕️',
                          title: 'Certified & Trained Staff',
                          text: 'Experienced phlebotomists and pathologists.',
                        ),
                        _FeatureCard(
                          icon: '⚡',
                          title: 'Quick, Accurate Results',
                          text: 'Turnaround-focused workflow with QA checks.',
                        ),
                        _FeatureCard(
                          icon: '🏠',
                          title: 'Home Sample Collection',
                          text: 'Book convenient at-home collection.',
                        ),
                        _FeatureCard(
                          icon: '💰',
                          title: 'Affordable Packages',
                          text: 'Value bundles for routine screening needs.',
                        ),
                        _FeatureCard(
                          icon: '🛡️',
                          title: 'Trusted Diagnostics',
                          text: 'Backed by strong quality standards.',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({super.key, required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final titleAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
    );
    final listAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.15, 1.00, curve: Curves.easeOut),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: const BoxDecoration(gradient: redHeroGradient),
      child: _SectionWrapper(
        child: Column(
          children: [
            FadeTransition(
              opacity: titleAnim,
              child: const Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: listAnim,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, (1 - listAnim.value) * 30),
                  child: Opacity(
                    opacity: listAnim.value,
                    child: const _ResponsiveGrid(
                      minTileWidth: 250,
                      maxWidth: 800,
                      gap: 16,
                      children: [
                        _ServiceItem(
                          title: '🩸 Complete Blood Count (CBC)',
                          text: 'Core screening for overall health.',
                        ),
                        _ServiceItem(
                          title: '🩺 Diabetes & Cholesterol Screening',
                          text: 'HbA1c, fasting glucose, lipid profile.',
                        ),
                        _ServiceItem(
                          title: '🧪 Liver & Kidney Function Tests',
                          text: 'LFTs and RFTs for organ health.',
                        ),
                        _ServiceItem(
                          title: '🦋 Thyroid Profile',
                          text: 'TSH, T3, T4 and related markers.',
                        ),
                        _ServiceItem(
                          title: '🧬 Vitamin & Mineral Deficiency Tests',
                          text: 'Vitamin D, B12 and more.',
                        ),
                        _ServiceItem(
                          title: '🦠 Urine & Stool Analysis',
                          text: 'Routine & microscopic examinations.',
                        ),
                        _ServiceItem(
                          title: '📦 Customized Health Packages',
                          text: 'Tailored bundles for individual needs.',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _SectionWrapper(
        child: Column(
          children: [
            const Text(
              'Patient Reviews',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: BrandColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            _ResponsiveGrid(
              minTileWidth: 300,
              gap: 16,
              children: kReviews
                  .map(
                    (r) => _HoverScale(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                          color: const Color(0xFFF8F9FA),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: BrandColors.primary
                                      .withOpacity(.12),
                                  child: Text(
                                    r.name[0],
                                    style: const TextStyle(
                                      color: BrandColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        r.when,
                                        style: const TextStyle(
                                          color: BrandColors.subtle,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (i) {
                                    final filled = i < r.rating;
                                    return Icon(
                                      filled
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 18,
                                      color: filled
                                          ? BrandColors.accent
                                          : Colors.black26,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(r.text, style: const TextStyle(height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({super.key, required this.controller});
  final AnimationController controller;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final titleAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
    );
    final gridAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.15, 1.00, curve: Curves.easeOut),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _SectionWrapper(
        child: Column(
          children: [
            FadeTransition(
              opacity: titleAnim,
              child: const Text(
                'Get In Touch',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: gridAnim,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, (1 - gridAnim.value) * 30),
                  child: Opacity(
                    opacity: gridAnim.value,
                    child: _ResponsiveGrid(
                      minTileWidth: 300,
                      maxWidth: 900,
                      gap: 20,
                      children: [
                        const _ContactCard(
                          icon: '📍',
                          title: 'Visit Us',
                          text:
                              'Mirabella Complex,\n25th OFF CPEC, Main Paswal Road, E-18',
                        ),
                        const _ContactCard(
                          icon: '📞',
                          title: 'Call Us',
                          text: '051-6120416\nAvailable 24/7',
                        ),
                        const _ContactCard(
                          icon: '✉️',
                          title: 'Email Us',
                          text:
                              'eshifamirabella@gmail.com\nQuick response guaranteed',
                        ),
                        // NEW: Socials card
                        _HoverScale(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: redCardGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33D7263D),
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: DefaultTextStyle.merge(
                              style: const TextStyle(color: Colors.white),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '💬',
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Follow & Chat',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Stay updated and reach us quickly on social media.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _SocialButton(
                                        label: 'Instagram',
                                        icon: Icons.camera_alt_rounded,
                                        onTap: () => _open(
                                          'https://instagram.com/eshifamirabella', // TODO: replace with your real link
                                        ),
                                      ),
                                      _SocialButton(
                                        label: 'Facebook',
                                        icon: Icons.facebook_rounded,
                                        onTap: () => _open(
                                          'https://facebook.com/eshifamirabella', // TODO: replace with your real link
                                        ),
                                      ),
                                      _SocialButton(
                                        label: 'WhatsApp',
                                        icon: Icons.chat_rounded,
                                        onTap: () => _open(
                                          'https://wa.me/923001234567', // TODO: replace with your real number (in international format)
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Match app brand color (reddish gradient)
      decoration: const BoxDecoration(gradient: redHeroGradient),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: _SectionWrapper(
        child: Column(
          children: [
            const Text(
              '© 2025 Mirabella eShifa Lab. All rights reserved. | Committed to your health and wellbeing.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Keep admin link (optional), or remove if you prefer only the lock in the header.
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              onPressed: () => Navigator.of(context).pushNamed('/admin'),
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ Small UI Pieces ============================

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.onTap, {this.fontSize, super.key});
  final String label;
  final VoidCallback onTap;
  final double? fontSize;

  double _autoSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 480) return 12; // small phones
    if (w < 768) return 13; // large phones / small tablets
    if (w < 1024) return 14; // tablets
    return 15; // desktop
  }

  @override
  Widget build(BuildContext context) {
    final size = fontSize ?? _autoSize(context);
    final isSmall = MediaQuery.sizeOf(context).width < 768;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 6 : 8,
            vertical: isSmall ? 4 : 6,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w600,
              color: BrandColors.ink,
              height: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _DrawerHeaderBrand extends StatelessWidget {
  const _DrawerHeaderBrand({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/logo.png', // <-- add this in pubspec.yaml
          height: 28,
          width: 28,
          fit: BoxFit.cover,
        ),
      ),
      title: const Text(
        'Mirabella eShifa Lab',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile(this.title, this.onTap);
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.of(context).maybePop();
        onTap();
      },
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({required this.onPressed, required this.label});
  final VoidCallback onPressed;
  final String label;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hover ? 1.03 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BrandColors.accent, BrandColors.primary],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [softBrandShadow(_hover)],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    required this.minTileWidth,
    this.maxWidth,
    this.gap = 20,
    this.maxColumns = 6,
    super.key,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double? maxWidth;
  final double gap;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        if (maxWidth != null) {
          available = available.clamp(0.0, maxWidth!);
        }

        int count = (available / (minTileWidth + gap)).floor();
        count = count.clamp(1, maxColumns);

        final itemWidth = (available - gap * (count - 1)) / count;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((w) => SizedBox(width: itemWidth, child: w))
              .toList(),
        );
      },
    );
  }
}

class _HoverScale extends StatefulWidget {
  const _HoverScale({
    required this.child,
    this.scale = 1.02,
    this.duration = const Duration(milliseconds: 140),
    super.key,
  });
  final Widget child;
  final double scale;
  final Duration duration;

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? widget.scale : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });
  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _HoverScale(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Color(0x66FFFFFF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: BrandColors.subtle,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({required this.title, required this.text, super.key});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _HoverScale(
      scale: 1.015,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });
  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _HoverScale(
      scale: 1.02,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: redCardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33D7263D),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
