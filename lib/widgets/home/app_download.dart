import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Main Widget ────────────────────────────────────────────────────────────

Widget buildAppDownloadSection({
  required ThemeData theme,
  required bool isDesktop,
}) {
  return _AppDownloadSection(theme: theme, isDesktop: isDesktop);
}

class _AppDownloadSection extends StatefulWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _AppDownloadSection({required this.theme, required this.isDesktop});

  @override
  State<_AppDownloadSection> createState() => _AppDownloadSectionState();
}

class _AppDownloadSectionState extends State<_AppDownloadSection>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = widget.isDesktop;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0F),
      ),
      child: Stack(
        children: [
          // ── Background decorative elements ──
          Positioned.fill(child: _BackgroundDecor(controller: _shimmerController)),

          // ── Top border gradient ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF4ADE80),
                    Color(0xFF22D3EE),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 72 : 48,
              horizontal: isDesktop ? 80 : 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _LeftContent(
                              isDesktop: isDesktop,
                              shimmerController: _shimmerController,
                            ),
                          ),
                          const SizedBox(width: 60),
                          Expanded(
                            flex: 4,
                            child: _RightQRCard(
                              isDesktop: isDesktop,
                              floatController: _floatController,
                              pulseController: _pulseController,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LeftContent(
                            isDesktop: isDesktop,
                            shimmerController: _shimmerController,
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: _RightQRCard(
                              isDesktop: isDesktop,
                              floatController: _floatController,
                              pulseController: _pulseController,
                            ),
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

// ─── Background Decoration ──────────────────────────────────────────────────

class _BackgroundDecor extends StatelessWidget {
  final AnimationController controller;
  const _BackgroundDecor({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _BgPainter(progress: controller.value),
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double progress;
  _BgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Large green glow — left
    final Paint glow1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4ADE80).withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.5),
        radius: size.height * 0.9,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.5), size.height * 0.9, glow1);

    // Cyan glow — right
    final Paint glow2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF22D3EE).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.3),
        radius: size.height * 0.8,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.3), size.height * 0.8, glow2);

    // Subtle grid dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }

    // Animated shimmer line
    final shimmerX = size.width * progress;
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4ADE80).withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(shimmerX - 80, 0, 160, size.height));
    canvas.drawRect(
      Rect.fromLTWH(shimmerX - 80, 0, 160, size.height),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.progress != progress;
}

// ─── Left Content ───────────────────────────────────────────────────────────

class _LeftContent extends StatelessWidget {
  final bool isDesktop;
  final AnimationController shimmerController;

  const _LeftContent({
    required this.isDesktop,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo badge
        _LogoBadge(),
        SizedBox(height: isDesktop ? 28 : 20),

        // Badge pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF4ADE80).withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF4ADE80).withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Now available on iOS & Android',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 20 : 16),

        // Heading
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 42 : 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -1,
            ),
            children: [
              const TextSpan(
                text: 'Get the ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Vegiffy',
                style: TextStyle(
                  foreground:  Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                ),
              ),
              const TextSpan(
                text: '\nApp now!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 18 : 14),

        // Description
        Text(
          'Best offers and discounts curated\nspecially for you — every single day.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: isDesktop ? 17 : 15,
            height: 1.7,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: isDesktop ? 36 : 28),

        // Stats row
        _StatsRow(isDesktop: isDesktop),
        SizedBox(height: isDesktop ? 36 : 28),

        // Store buttons
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _StoreButton(
              icon: _AppleIconPainter(),
              topLabel: 'Download on the',
              label: 'App Store',
              isPrimary: true,
              onTap: () => launchUrl(
                Uri.parse('https://apps.apple.com/in/app/vegiffyy/id6757138352'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            _StoreButton(
              icon: _AndroidIconPainter(),
              topLabel: 'Get it on',
              label: 'Google Play',
              isPrimary: false,
              onTap: () => launchUrl(
                Uri.parse('https://play.google.com/store/apps/details?id=com.veggify.veegify'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Logo Badge ─────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'V',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
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
    );
  }
}

// ─── Stats Row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final bool isDesktop;
  const _StatsRow({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('50K+', 'Downloads'),
      ('4.8★', 'Rating'),
      ('100%', 'Free'),
    ];

    return Row(
      children: stats
          .asMap()
          .entries
          .map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Row(
              children: [
                if (i != 0) ...[
                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.$1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 20 : 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      s.$2,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            );
          })
          .toList(),
    );
  }
}

// ─── Store Button ────────────────────────────────────────────────────────────

class _StoreButton extends StatefulWidget {
  final Widget icon;
  final String topLabel;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _StoreButton({
    required this.icon,
    required this.topLabel,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _hoverController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isPrimary
                  ? null
                  : (_hovered
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.04)),
              borderRadius: BorderRadius.circular(14),
              border: widget.isPrimary
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(_hovered ? 0.2 : 0.1),
                      width: 1,
                    ),
              boxShadow: widget.isPrimary
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4ADE80).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 22, height: 22, child: widget.icon),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topLabel,
                      style: TextStyle(
                        color: widget.isPrimary
                            ? Colors.black.withOpacity(0.6)
                            : Colors.white.withOpacity(0.45),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isPrimary ? Colors.black : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── QR Card ────────────────────────────────────────────────────────────────

class _RightQRCard extends StatelessWidget {
  final bool isDesktop;
  final AnimationController floatController;
  final AnimationController pulseController;

  const _RightQRCard({
    required this.isDesktop,
    required this.floatController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = isDesktop ? 200.0 : 160.0;

    return AnimatedBuilder(
      animation: floatController,
      builder: (_, child) {
        final offset = Tween(begin: -6.0, end: 6.0)
            .evaluate(CurvedAnimation(parent: floatController, curve: Curves.easeInOut));
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Center(
        child: Column(
          children: [
            // Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF161618),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.07),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ADE80).withOpacity(0.08),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // QR header
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: pulseController,
                        builder: (_, __) {
                          final opacity =
                              Tween(begin: 0.5, end: 1.0).evaluate(pulseController);
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xFF4ADE80),
                                const Color(0xFF22D3EE),
                                pulseController.value,
                              )!.withOpacity(opacity),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4ADE80)
                                      .withOpacity(0.5 * opacity),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Scan to download',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // QR Box
                  Container(
                    width: qrSize,
                    height: qrSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ADE80).withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/qr_code.png',
                        width: qrSize,
                        height: qrSize,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _QRFallback(size: qrSize),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Platform chips
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PlatformChip(label: 'iOS', icon: Icons.apple),
                      const SizedBox(width: 8),
                      _PlatformChip(label: 'Android', icon: Icons.android),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rating stars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: i < 4
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFFBBF24).withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '4.8 · 2.1k reviews',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Platform Chip ───────────────────────────────────────────────────────────

class _PlatformChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlatformChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QR Fallback ─────────────────────────────────────────────────────────────

class _QRFallback extends StatelessWidget {
  final double size;
  const _QRFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _QRPatternPainter()),
    );
  }
}

class _QRPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final p = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.fill;

    final accent = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final cell = size.width / 21;

    void drawFinder(double x, double y) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * cell, y * cell, 7 * cell, 7 * cell),
          Radius.circular(cell * 0.5),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((x + 1) * cell, (y + 1) * cell, 5 * cell, 5 * cell),
          Radius.circular(cell * 0.3),
        ),
        bg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((x + 2) * cell, (y + 2) * cell, 3 * cell, 3 * cell),
          Radius.circular(cell * 0.3),
        ),
        accent,
      );
    }

    drawFinder(1, 1);
    drawFinder(13, 1);
    drawFinder(1, 13);

    // Data dots
    final rand = math.Random(42);
    for (int row = 0; row < 21; row++) {
      for (int col = 0; col < 21; col++) {
        final inFinder = (row < 8 && col < 8) ||
            (row < 8 && col > 12) ||
            (row > 12 && col < 8);
        if (!inFinder && rand.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                col * cell + cell * 0.1,
                row * cell + cell * 0.1,
                cell * 0.8,
                cell * 0.8,
              ),
              Radius.circular(cell * 0.2),
            ),
            p,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Platform Icon Painters ──────────────────────────────────────────────────

class _AppleIconPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Colors.black, size: 22);
  }
}

class _AndroidIconPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.android, color: Colors.white, size: 22);
  }
}