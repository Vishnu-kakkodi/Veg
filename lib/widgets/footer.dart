import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildFooterSection({
  required ThemeData theme,
  required bool isDesktop,
}) {
  return const _FooterSection();
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  static const _bg = Color(0xFF0A0F0A);
  static const _cardBg = Color(0xFF111811);
  static const _border = Color(0xFF1E2E1E);
  static const _heading = Colors.white;
  static const _muted = Color(0xFF6B8F6B);
  static const _accent = Color(0xFF4ADE80);
  static const _accentCyan = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      color: _bg,
      child: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentCyan.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Top gradient border
              Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _accent,
                      _accentCyan,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 64 : 48,
                  horizontal: isDesktop ? 64 : 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        // Top: Brand + Nav columns
                        isDesktop
                            ? _DesktopGrid()
                            : _MobileLayout(),

                        const SizedBox(height: 56),

                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _border,
                                _border,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Bottom bar
                        _BottomBar(isDesktop: isDesktop),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Desktop Grid ─────────────────────────────────────────────────────────────

class _DesktopGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column (wider)
        const Expanded(flex: 3, child: _BrandColumn()),
        const SizedBox(width: 48),
        // Nav columns
        const Expanded(flex: 2, child: _NavColumn(
          title: 'Company',
          items: [
            _LinkItem('About Us', 'https://vegiffy.com/'),
            _LinkItem('Careers', null),
            _LinkItem('Help & Support', null),
          ],
        )),
        const SizedBox(width: 32),
        const Expanded(flex: 2, child: _NavColumn(
          title: 'Legal',
          items: [
            _LinkItem('Privacy Policy', 'https://vegiffy-policy.onrender.com/privacy-and-policy'),
            _LinkItem('Terms & Conditions', 'https://vegiffy-policy.onrender.com/terms-and-conditions'),
          ],
        )),
        const SizedBox(width: 32),
        const Expanded(flex: 2, child: _PartnerColumn()),
      ],
    );
  }
}

// ── Mobile Layout ─────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandColumn(),
        const SizedBox(height: 40),
        // 2-column grid for nav
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: _NavColumn(
              title: 'Company',
              items: [
                _LinkItem('About Us', 'https://vegiffy.com/'),
                _LinkItem('Careers', null),
                _LinkItem('Help & Support', null),
              ],
            )),
            SizedBox(width: 24),
            Expanded(child: _NavColumn(
              title: 'Legal',
              items: [
                _LinkItem('Privacy Policy', 'https://vegiffy-policy.onrender.com/privacy-and-policy'),
                _LinkItem('Terms & Conditions', 'https://vegiffy-policy.onrender.com/terms-and-conditions'),
              ],
            )),
          ],
        ),
        const SizedBox(height: 36),
        const _PartnerColumn(),
      ],
    );
  }
}

// ── Brand Column ──────────────────────────────────────────────────────────────

class _BrandColumn extends StatelessWidget {
  const _BrandColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ADE80).withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
              ).createShader(bounds),
              child: const Text(
                'Vegiffy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Tagline
        Text(
          'Fresh veg food \ndelivered to your doorstep.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 14,
            height: 1.7,
            letterSpacing: 0.1,
          ),
        ),

        const SizedBox(height: 28),

        // Social icons row
        Row(
          children: [
            _SocialButton(icon: Icons.language, url: 'https://vegiffy.com/'),
            const SizedBox(width: 10),
            _SocialButton(icon: Icons.shopping_bag_outlined, url: 'https://vendor.vegiffy.in/'),
            const SizedBox(width: 10),
            _SocialButton(icon: Icons.delivery_dining_outlined, url: 'https://play.google.com/store/apps/details?id=com.pixelmind.vegiffydeliveryapp'),
          ],
        ),
      ],
    );
  }
}

// ── Nav Column ────────────────────────────────────────────────────────────────

class _LinkItem {
  final String label;
  final String? url;
  const _LinkItem(this.label, this.url);
}

class _NavColumn extends StatelessWidget {
  final String title;
  final List<_LinkItem> items;

  const _NavColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading with accent bar
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...items.map((item) => _FooterLink(item: item)),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final _LinkItem item;
  const _FooterLink({required this.item});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasLink = widget.item.url != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: hasLink
              ? () => launchUrl(Uri.parse(widget.item.url!),
                  mode: LaunchMode.externalApplication)
              : null,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: hasLink
                  ? (_hovered
                      ? const Color(0xFF4ADE80)
                      : Colors.white.withOpacity(0.5))
                  : Colors.white.withOpacity(0.3),
              letterSpacing: 0.1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasLink && _hovered) ...[
                  const Icon(Icons.arrow_forward, size: 10, color: Color(0xFF4ADE80)),
                  const SizedBox(width: 4),
                ],
                Text(widget.item.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Partner Column ────────────────────────────────────────────────────────────

class _PartnerColumn extends StatelessWidget {
  const _PartnerColumn();

  static const _partners = [
    (emoji: '🛒', label: 'Become a Vendor', url: 'https://vendor.vegiffy.in/'),
    (emoji: '🏍️', label: 'Ride with Us', url: 'https://play.google.com/store/apps/details?id=com.pixelmind.vegiffydeliveryapp'),
    (emoji: '🌟', label: 'Become an Ambassador', url: 'https://vegiffypanel.vegiffy.in/'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Partner With Us',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._partners.map((p) => _PartnerTile(
              emoji: p.emoji,
              label: p.label,
              url: p.url,
            )),
      ],
    );
  }
}

class _PartnerTile extends StatefulWidget {
  final String emoji;
  final String label;
  final String url;
  const _PartnerTile({required this.emoji, required this.label, required this.url});

  @override
  State<_PartnerTile> createState() => _PartnerTileState();
}

class _PartnerTileState extends State<_PartnerTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse(widget.url),
              mode: LaunchMode.externalApplication),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: _hovered
                  ? const Color(0xFF4ADE80).withOpacity(0.07)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _hovered
                    ? const Color(0xFF4ADE80).withOpacity(0.25)
                    : Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: _hovered
                        ? const Color(0xFF4ADE80)
                        : Colors.white.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.north_east_rounded,
                  size: 11,
                  color: _hovered
                      ? const Color(0xFF4ADE80)
                      : Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final String url;
  const _SocialButton({required this.icon, required this.url});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url),
            mode: LaunchMode.externalApplication),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFF4ADE80).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF4ADE80).withOpacity(0.4)
                  : Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered
                ? const Color(0xFF4ADE80)
                : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isDesktop;
  const _BottomBar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/applogo.png',
          height: 28,
          errorBuilder: (_, __, ___) => ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
            ).createShader(b),
            child: const Text(
              'Vegiffy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
      ],
    );

    final copyright = Text(
      '© ${DateTime.now().year} Vegiffy. All rights reserved.',
      style: TextStyle(
        color: Colors.white.withOpacity(0.25),
        fontSize: 12,
        letterSpacing: 0.3,
      ),
    );

    final madeWith = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Made with ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 12,
          ),
        ),
        const Icon(Icons.favorite_rounded, size: 11, color: Color(0xFF4ADE80)),
        Text(
          ' in India',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 12,
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          logo,
          copyright,
          madeWith,
        ],
      );
    } else {
      return Column(
        children: [
          logo,
          const SizedBox(height: 12),
          copyright,
          const SizedBox(height: 8),
          madeWith,
        ],
      );
    }
  }
}