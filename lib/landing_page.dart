import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'booking_dialog.dart';
import 'theme.dart';

// ============================ Reviews ============================
class Review {
  final String name;
  final int rating; // 1..5
  final String text;
  final String when; // "Jan 2025"
  Review({
    required this.name,
    required this.rating,
    required this.text,
    required this.when,
  });
}

final kReviews = <Review>[
  Review(
    name: 'Ayesha Khan.',
    rating: 5,
    when: 'Feb 2025',
    text:
        'Booked home sample collection. Phlebotomist was on time and very professional. Reports were quick!',
  ),
  Review(
    name: 'Hassan Rana.',
    rating: 5,
    when: 'Jan 2025',
    text:
        'Clean facility and friendly staff. CBC and thyroid tests delivered same day.',
  ),
  Review(
    name: 'Maria Slam.',
    rating: 4,
    when: 'Dec 2024',
    text:
        'Affordable packages. Reception helped me pick the right tests for annual checkup.',
  ),
  Review(
    name: 'Bilal Abdullah.',
    rating: 5,
    when: 'Nov 2024',
    text: 'Accurate results and smooth experience. Will return for follow-ups.',
  ),
  Review(
    name: 'Zainab Tehreem.',
    rating: 5,
    when: 'Oct 2024',
    text:
        'Great communication. Got results on email and WhatsApp. Highly recommended.',
  ),
  Review(
    name: 'Omar Noman.',
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
    if (!mounted) return;
    await Navigator.of(context).pushNamed('/admin');
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
                    _DrawerHeaderBrand(
                      onTap: () => _scrollTo(_homeKey),
                      onSecret: _goToAdmin, // 5 taps on logo → admin
                    ),
                    _NavTile('Home', () => _scrollTo(_homeKey)),
                    _NavTile('Services', () => _scrollTo(_servicesKey)),
                    _NavTile('About', () => _scrollTo(_featuresKey)),
                    _NavTile('Reviews', () => _scrollTo(_reviewsKey)),
                    _NavTile('Contact', () => _scrollTo(_contactKey)),
                    const Divider(),
                  ],
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          // base background now plain white (removed red hero background)
          Container(color: Colors.white),
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
                                _SecretTapDetector(
                                  taps: 5,
                                  window: const Duration(seconds: 2),
                                  onUnlocked: _goToAdmin,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      height: 52,
                                      width: 52,
                                      fit: BoxFit.cover,
                                    ),
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

              // ===== Full-screen hero with background slider =====
              SliverToBoxAdapter(
                child: _HeroSection(
                  key: _homeKey,
                  onCTAPressed: _openBookingDialog,
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

              // ===== Gallery (NEW) =====
              const SliverToBoxAdapter(child: _GallerySection()),

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

// ===================== Hero image slider (reusable) =====================
class HeroImageSlider extends StatefulWidget {
  const HeroImageSlider({
    super.key,
    required this.images,
    this.interval = const Duration(seconds: 4),
    this.height,
    this.borderRadius = 0, // now default to 0 for full-bleed
  });

  final List<String> images; // asset or http URLs
  final Duration interval;
  final double? height;
  final double borderRadius;

  @override
  State<HeroImageSlider> createState() => _HeroImageSliderState();
}

class _HeroImageSliderState extends State<HeroImageSlider> {
  final _ctrl = PageController();
  int _index = 0;
  bool _hover = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.images.length < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || _hover) return;
      final next = (_index + 1) % widget.images.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? 420;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: h,
              width: double.infinity,
              child: PageView.builder(
                controller: _ctrl,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = widget.images[i];
                  final ImageProvider provider = p.startsWith('http')
                      ? NetworkImage(p)
                      : AssetImage(p);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image(image: provider, fit: BoxFit.cover),
                      ),
                      // darker overlay for readability
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x55000000),
                                Color(0x22000000),
                                Color(0x66000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // tiny dots
            Positioned(
              bottom: 12,
              child: Row(
                children: List.generate(widget.images.length, (i) {
                  final active = _index == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 18 : 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ Sections ============================

class _HeroSection extends StatelessWidget {
  const _HeroSection({super.key, required this.onCTAPressed});
  final VoidCallback onCTAPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // fill ~90% of viewport height under the app bar
    final double heroH = (size.height * 0.9).clamp(520.0, 900.0);

    return SizedBox(
      height: heroH,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // full-screen background slider
          HeroImageSlider(
            images: const [
              'assets/hero/1.jpeg',
              'assets/hero/2.jpeg',
              'assets/hero/3.jpeg',
              'assets/hero/4.jpeg',
            ],
            height: heroH,
            borderRadius: 0,
          ),

          // centered text + CTA on top
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MIRABELLA ESHIFA LAB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width < 900 ? 42 : 64,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        shadows: const [
                          Shadow(
                            blurRadius: 12,
                            offset: Offset(0, 3),
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Health, Our Priority',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.98),
                        fontSize: size.width < 900 ? 18 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accurate, reliable, and timely diagnostics — with convenient home sample collection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: size.width < 900 ? 15 : 18,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _GradientButton(
                      onPressed: onCTAPressed,
                      label: 'Book Your Test Today',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionWrapper extends StatelessWidget {
  const _SectionWrapper({required this.child});
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

// ============================ GALLERY (NEW) ============================
class _GallerySection extends StatefulWidget {
  const _GallerySection();

  @override
  State<_GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<_GallerySection> {
  // If your files are at a different path, change basePath accordingly.
  static const String basePath = 'assets/gallery/';
  final List<String> _images = List.generate(
    8,
    (i) => '${basePath}${i + 1}.jpeg',
  );

  late final PageController _pageCtrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _go(int targetPage, int totalPages) {
    if (targetPage < 0 || targetPage >= totalPages) return;
    _pageCtrl.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _SectionWrapper(
        child: LayoutBuilder(
          builder: (context, c) {
            final maxW = c.maxWidth;
            final itemsPerPage = maxW > 1100 ? 4 : (maxW > 750 ? 2 : 1);
            final totalPages =
                (_images.length + itemsPerPage - 1) ~/ itemsPerPage;

            const gap = 16.0;
            const tileHeight = 230.0;

            return Column(
              children: [
                const Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'A quick look at our facility, team, and recent work.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BrandColors.subtle),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: tileHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: totalPages,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, pageIndex) {
                          final start = pageIndex * itemsPerPage;
                          final end = (start + itemsPerPage) > _images.length
                              ? _images.length
                              : (start + itemsPerPage);

                          final children = <Widget>[];
                          for (var i = 0; i < itemsPerPage; i++) {
                            if (i > 0) children.add(const SizedBox(width: gap));
                            final imgIndex = start + i;
                            if (imgIndex < end) {
                              children.add(
                                Expanded(
                                  child: _GalleryTile(path: _images[imgIndex]),
                                ),
                              );
                            } else {
                              children.add(const Expanded(child: SizedBox()));
                            }
                          }
                          return Row(children: children);
                        },
                      ),

                      // Left Arrow
                      Positioned(
                        left: 0,
                        child: _ArrowBtn(
                          icon: Icons.chevron_left,
                          enabled: _page > 0,
                          onTap: () => _go(_page - 1, totalPages),
                        ),
                      ),

                      // Right Arrow
                      Positioned(
                        right: 0,
                        child: _ArrowBtn(
                          icon: Icons.chevron_right,
                          enabled: _page < totalPages - 1,
                          onTap: () => _go(_page + 1, totalPages),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: enabled ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: enabled
                  ? const Color(0x1A000000)
                  : const Color(0x11000000),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: enabled ? BrandColors.ink : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String path;
  const _GalleryTile({required this.path});

  @override
  Widget build(BuildContext context) {
    return _HoverScale(
      scale: 1.015,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.asset(path, fit: BoxFit.contain),
                  ),
                ),
              ),
            );
          },
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ============================ Reviews ============================

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
                              'bookings@mirabellaeshifa.com\nQuick response guaranteed',
                        ),
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
                                          'https://instagram.com/eshifamirabella',
                                        ),
                                      ),
                                      _SocialButton(
                                        label: 'Facebook',
                                        icon: Icons.facebook_rounded,
                                        onTap: () => _open(
                                          'https://facebook.com/eshifamirabella',
                                        ),
                                      ),
                                      _SocialButton(
                                        label: 'WhatsApp',
                                        icon: Icons.chat_rounded,
                                        onTap: () =>
                                            _open('https://wa.me/923001234567'),
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
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: redHeroGradient),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: _SectionWrapper(
        child: Column(
          children: const [
            Text(
              '© 2025 Mirabella eShifa Lab. All rights reserved. | Committed to your health and wellbeing.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ============================ Small UI Pieces ============================

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.onTap, {this.fontSize});
  final String label;
  final VoidCallback onTap;
  final double? fontSize;

  double _autoSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 480) return 12;
    if (w < 768) return 13;
    if (w < 1024) return 14;
    return 15;
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
  const _DrawerHeaderBrand({required this.onTap, this.onSecret});
  final VoidCallback onTap;
  final VoidCallback? onSecret;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _SecretTapDetector(
        taps: 5,
        window: const Duration(seconds: 2),
        onUnlocked: onSecret ?? () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/logo.png',
            height: 28,
            width: 28,
            fit: BoxFit.cover,
          ),
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
  const _ServiceItem({required this.title, required this.text});
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

// ============================ Secret multi-tap helper ============================

class _SecretTapDetector extends StatefulWidget {
  const _SecretTapDetector({
    required this.child,
    required this.onUnlocked,
    this.taps = 5,
    this.window = const Duration(seconds: 2),
    Key? key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onUnlocked;
  final int taps;
  final Duration window;

  @override
  State<_SecretTapDetector> createState() => _SecretTapDetectorState();
}

class _SecretTapDetectorState extends State<_SecretTapDetector> {
  int _count = 0;
  Timer? _timer;

  void _registerTap() {
    _timer?.cancel();
    _count++;
    if (_count >= widget.taps) {
      _count = 0;
      widget.onUnlocked();
      return;
    }
    _timer = Timer(widget.window, () {
      _count = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _registerTap, child: widget.child);
  }
}
