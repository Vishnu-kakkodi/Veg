// // ─────────────────────────────────────────
// //  coupons_screen.dart  (scratch-card edition)
// // ─────────────────────────────────────────

// import 'dart:math' as math;
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/CouponModel/coupon_model.dart';
// import 'package:veegify/provider/CouponProvider/coupon_provider.dart';

// // ══════════════════════════════════════════
// //  SCREEN
// // ══════════════════════════════════════════
// class CouponsScreen extends StatefulWidget {
//   const CouponsScreen({super.key});

//   @override
//   State<CouponsScreen> createState() => _CouponsScreenState();
// }

// class _CouponsScreenState extends State<CouponsScreen> {
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       setState(() => userId = user.userId);
//     }
//     // ✅ FIX: use addPostFrameCallback so context is ready,
//     // and pass the resolved userId (fallback to '' if null)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CouponProvider>().fetchCoupons(userId ?? '');
//     });
//   }

//   // ✅ FIX: extracted as a plain method so it matches VoidCallback
//   void _retry() {
//     context.read<CouponProvider>().fetchCoupons(userId ?? '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F3EE),
//       appBar: _buildAppBar(),
//       body: Consumer<CouponProvider>(
//         builder: (context, provider, _) {
//           // ✅ FIX: onRetry now receives _retry which is a VoidCallback
//           return switch (provider.status) {
//             CouponStatus.idle || CouponStatus.loading => const _LoadingView(),
//             CouponStatus.error => _ErrorView(
//                 message: provider.errorMessage,
//                 onRetry: _retry,
//               ),
//             CouponStatus.loaded => provider.coupons.isEmpty
//                 ? const _EmptyView()
//                 : _CouponList(coupons: provider.coupons),
//           };
//         },
//       ),
//     );
//   }

//   AppBar _buildAppBar() {
//     return AppBar(
//       backgroundColor: const Color(0xFFF5F3EE),
//       elevation: 0,
//       centerTitle: true,
//       title: const Text(
//         'Your Coupons',
//         style: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.w800,
//           color: Color(0xFF1A1A1A),
//           letterSpacing: -0.5,
//         ),
//       ),
//       toolbarHeight: 70,
//     );
//   }
// }

// // ══════════════════════════════════════════
// //  COUPON LIST
// // ══════════════════════════════════════════
// class _CouponList extends StatelessWidget {
//   final List<CouponModel> coupons;
//   const _CouponList({required this.coupons});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
//       itemCount: coupons.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 16),
//       itemBuilder: (context, index) => CouponTicket(coupon: coupons[index]),
//     );
//   }
// }

// // ══════════════════════════════════════════
// //  TICKET WIDGET
// // ══════════════════════════════════════════
// class CouponTicket extends StatelessWidget {
//   final CouponModel coupon;

//   const CouponTicket({super.key, required this.coupon});

//   static const List<Color> _palette = [
//     Color(0xFF4CAF82),
//     Color(0xFFE8705A),
//     Color(0xFF5B8FD4),
//     Color(0xFFF0A500),
//     Color(0xFF9B5DE5),
//   ];

//   Color _accentColor() => _palette[
//       coupon.couponCode.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

//   @override
//   Widget build(BuildContext context) {
//     final accent = _accentColor();
//     final dateFormat = DateFormat('dd MMM yyyy');
//     final expired = coupon.isExpired;

//     return Opacity(
//       opacity: expired ? 0.55 : 1.0,
//       child: _TicketShape(
//         accentColor: accent,
//         child: Column(
//           children: [
//             // ── Top section ─────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 72,
//                     height: 72,
//                     decoration: BoxDecoration(
//                       color: accent.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Center(
//                       child: Text(
//                         coupon.discountType == 'percentage'
//                             ? '${coupon.discountValue.toStringAsFixed(0)}%'
//                             : '₹${coupon.discountValue.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w900,
//                           color: accent,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           coupon.title,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF1A1A1A),
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           coupon.description,
//                           style: const TextStyle(
//                               fontSize: 13, color: Color(0xFF666666)),
//                         ),
//                         const SizedBox(height: 6),
//                         Wrap(
//                           spacing: 6,
//                           children: [
//                             _Pill(
//                               label:
//                                   'Max ₹${coupon.maxDiscountAmount.toInt()}',
//                               color: accent,
//                             ),
//                             _Pill(
//                               label:
//                                   'Min ₹${coupon.minOrderAmount.toInt()}',
//                               color: const Color(0xFF999999),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (expired)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade50,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         'EXPIRED',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.red.shade400,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // ── Dotted divider ───────────────────
//             _DottedDivider(color: accent),

//             // ── Bottom: scratch card section ─────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'USE CODE',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFFAAAAAA),
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         ScratchCard(
//                           couponCode: coupon.couponCode,
//                           accentColor: accent,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'VALID TILL',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFFAAAAAA),
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         dateFormat.format(coupon.endDate),
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF444444),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════
// //  SCRATCH CARD
// // ══════════════════════════════════════════
// class ScratchCard extends StatefulWidget {
//   final String couponCode;
//   final Color accentColor;

//   const ScratchCard({
//     super.key,
//     required this.couponCode,
//     required this.accentColor,
//   });

//   @override
//   State<ScratchCard> createState() => _ScratchCardState();
// }

// class _ScratchCardState extends State<ScratchCard>
//     with TickerProviderStateMixin {
//   final List<Offset> _scratchPoints = [];
//   double _scratchPercent = 0.0;
//   bool _revealed = false;
//   bool _fullyRevealed = false;

//   late AnimationController _confettiCtrl;
//   late AnimationController _scaleCtrl;
//   late Animation<double> _scaleAnim;
//   final List<_Particle> _particles = [];
//   final math.Random _rng = math.Random();

//   static const double _revealThreshold = 0.55;
//   static const double _cardW = 160.0;
//   static const double _cardH = 44.0;
//   static const double _brushR = 18.0;

//   @override
//   void initState() {
//     super.initState();

//     _confettiCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _scaleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     _scaleAnim = TweenSequence<double>([
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 1.18)
//               .chain(CurveTween(curve: Curves.easeOut)),
//           weight: 40),
//       TweenSequenceItem(
//           tween: Tween(begin: 1.18, end: 1.0)
//               .chain(CurveTween(curve: Curves.elasticOut)),
//           weight: 60),
//     ]).animate(_scaleCtrl);

//     _confettiCtrl.addListener(() => setState(() {}));
//     _scaleCtrl.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     _confettiCtrl.dispose();
//     _scaleCtrl.dispose();
//     super.dispose();
//   }

//   void _onPanUpdate(DragUpdateDetails d) {
//     if (_fullyRevealed) return;
//     final box = context.findRenderObject() as RenderBox?;
//     if (box == null) return;
//     final local = box.globalToLocal(d.globalPosition);
//     setState(() {
//       _scratchPoints.add(local);
//       _scratchPercent = _calculateScratchPercent();
//       if (_scratchPercent >= _revealThreshold && !_revealed) {
//         _revealCode();
//       }
//     });
//   }

//   double _calculateScratchPercent() {
//     if (_scratchPoints.isEmpty) return 0;
//     const gridSize = 8;
//     final cols = (_cardW / gridSize).ceil();
//     final rows = (_cardH / gridSize).ceil();
//     final total = cols * rows;
//     final covered = <String>{};
//     for (final p in _scratchPoints) {
//       final minC =
//           ((p.dx - _brushR) / gridSize).floor().clamp(0, cols - 1);
//       final maxC = ((p.dx + _brushR) / gridSize).ceil().clamp(0, cols);
//       final minR =
//           ((p.dy - _brushR) / gridSize).floor().clamp(0, rows - 1);
//       final maxR = ((p.dy + _brushR) / gridSize).ceil().clamp(0, rows);
//       for (var c = minC; c < maxC; c++) {
//         for (var r = minR; r < maxR; r++) {
//           covered.add('$c,$r');
//         }
//       }
//     }
//     return covered.length / total;
//   }

//   void _revealCode() {
//     _revealed = true;
//     _particles.clear();
//     for (var i = 0; i < 28; i++) {
//       _particles.add(_Particle(
//         color: _particleColors[_rng.nextInt(_particleColors.length)],
//         angle: _rng.nextDouble() * 2 * math.pi,
//         speed: 60 + _rng.nextDouble() * 100,
//         size: 4 + _rng.nextDouble() * 5,
//         startX: _cardW / 2 + (_rng.nextDouble() - 0.5) * _cardW * 0.8,
//         startY: _cardH / 2,
//         rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
//       ));
//     }
//     _confettiCtrl.forward(from: 0);
//     _scaleCtrl.forward(from: 0);

//     Future.delayed(const Duration(milliseconds: 900), () {
//       if (mounted) setState(() => _fullyRevealed = true);
//     });
//   }

//   static const _particleColors = [
//     Color(0xFFFF6B6B),
//     Color(0xFFFFD93D),
//     Color(0xFF6BCB77),
//     Color(0xFF4D96FF),
//     Color(0xFFFF922B),
//     Color(0xFFCC5DE8),
//     Color(0xFFFF6EB4),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanUpdate: _onPanUpdate,
//       child: SizedBox(
//         width: _cardW,
//         height: _cardH + 30,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // ── Revealed code (always underneath) ──
//             Positioned(
//               top: 15,
//               left: 0,
//               width: _cardW,
//               height: _cardH,
//               child: ScaleTransition(
//                 scale: _revealed
//                     ? _scaleAnim
//                     : const AlwaysStoppedAnimation(1),
//                 child: _CodeChip(
//                   code: widget.couponCode,
//                   accentColor: widget.accentColor,
//                 ),
//               ),
//             ),

//             // ── Scratch overlay (foil) ───────────
//             if (!_fullyRevealed)
//               Positioned(
//                 top: 15,
//                 left: 0,
//                 width: _cardW,
//                 height: _cardH,
//                 child: CustomPaint(
//                   painter: _ScratchPainter(
//                     points: _scratchPoints,
//                     brushRadius: _brushR,
//                     accentColor: widget.accentColor,
//                   ),
//                   size: const Size(_cardW, _cardH),
//                 ),
//               ),

//             // ── Hint label ───────────────────────
//             if (_scratchPoints.isEmpty && !_fullyRevealed)
//               Positioned(
//                 top: 15,
//                 left: 0,
//                 width: _cardW,
//                 height: _cardH,
//                 child: IgnorePointer(
//                   child: Center(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.back_hand_outlined,
//                             size: 13,
//                             color: Colors.white.withOpacity(0.85)),
//                         const SizedBox(width: 5),
//                         Text(
//                           'Scratch me!',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white.withOpacity(0.9),
//                             letterSpacing: 0.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             // ── Confetti particles ───────────────
//             if (_revealed && _confettiCtrl.isAnimating)
//               ..._particles.map((p) {
//                 final t = _confettiCtrl.value;
//                 final x = p.startX + math.cos(p.angle) * p.speed * t;
//                 final y = p.startY -
//                     math.sin(p.angle).abs() * p.speed * t +
//                     0.5 * 300 * t * t;
//                 final opacity = (1 - t).clamp(0.0, 1.0);
//                 final rotation = p.rotationSpeed * t * math.pi;
//                 return Positioned(
//                   left: x - p.size / 2,
//                   top: y - p.size / 2 + 15,
//                   child: Opacity(
//                     opacity: opacity,
//                     child: Transform.rotate(
//                       angle: rotation,
//                       child: Container(
//                         width: p.size,
//                         height: p.size * 0.6,
//                         decoration: BoxDecoration(
//                           color: p.color,
//                           borderRadius: BorderRadius.circular(1),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Particle ─────────────────────────────
// class _Particle {
//   final Color color;
//   final double angle;
//   final double speed;
//   final double size;
//   final double startX;
//   final double startY;
//   final double rotationSpeed;

//   const _Particle({
//     required this.color,
//     required this.angle,
//     required this.speed,
//     required this.size,
//     required this.startX,
//     required this.startY,
//     required this.rotationSpeed,
//   });
// }

// // ── Scratch painter ──────────────────────
// class _ScratchPainter extends CustomPainter {
//   final List<Offset> points;
//   final double brushRadius;
//   final Color accentColor;

//   const _ScratchPainter({
//     required this.points,
//     required this.brushRadius,
//     required this.accentColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final rrect =
//         RRect.fromRectAndRadius(rect, const Radius.circular(10));

//     final foilPaint = Paint()
//       ..shader = ui.Gradient.linear(
//         Offset.zero,
//         Offset(size.width, size.height),
//         [
//           accentColor.withOpacity(0.90),
//           accentColor
//               .withRed((accentColor.red + 40).clamp(0, 255))
//               .withOpacity(0.95),
//           accentColor
//               .withBlue((accentColor.blue + 30).clamp(0, 255))
//               .withOpacity(0.85),
//         ],
//         [0.0, 0.5, 1.0],
//       );

//     canvas.saveLayer(rect, Paint());
//     canvas.drawRRect(rrect, foilPaint);

//     if (points.isNotEmpty) {
//       final erasePaint = Paint()
//         ..blendMode = BlendMode.dstOut
//         ..style = PaintingStyle.fill;

//       for (final p in points) {
//         canvas.drawCircle(p, brushRadius, erasePaint);
//       }

//       final pathPaint = Paint()
//         ..blendMode = BlendMode.dstOut
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = brushRadius * 2
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round;

//       final path = Path()
//         ..moveTo(points.first.dx, points.first.dy);
//       for (var i = 1; i < points.length; i++) {
//         final prev = points[i - 1];
//         final curr = points[i];
//         if ((curr - prev).distance < brushRadius * 3) {
//           path.lineTo(curr.dx, curr.dy);
//         } else {
//           path.moveTo(curr.dx, curr.dy);
//         }
//       }
//       canvas.drawPath(path, pathPaint);
//     }

//     canvas.restore();

//     canvas.drawRRect(
//       rrect,
//       Paint()
//         ..color = Colors.white.withOpacity(0.25)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1,
//     );
//   }

//   @override
//   bool shouldRepaint(_ScratchPainter old) =>
//       old.points.length != points.length;
// }

// // ── Revealed code chip ───────────────────
// class _CodeChip extends StatelessWidget {
//   final String code;
//   final Color accentColor;

//   const _CodeChip({required this.code, required this.accentColor});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Clipboard.setData(ClipboardData(text: code));
//         ScaffoldMessenger.of(context)
//           ..clearSnackBars()
//           ..showSnackBar(
//             SnackBar(
//               content: Text('$code copied! 🎉'),
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               duration: const Duration(seconds: 2),
//             ),
//           );
//       },
//       child: Container(
//         height: 44,
//         decoration: BoxDecoration(
//           color: accentColor.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: accentColor.withOpacity(0.35),
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               code,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w900,
//                 color: accentColor,
//                 letterSpacing: 2,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Icon(Icons.copy_rounded, size: 14, color: accentColor),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════
// //  TICKET SHAPE
// // ══════════════════════════════════════════
// class _TicketShape extends StatelessWidget {
//   final Widget child;
//   final Color accentColor;

//   const _TicketShape({required this.child, required this.accentColor});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _TicketPainter(accentColor: accentColor),
//       child: ClipPath(
//         clipper: _TicketClipper(),
//         child: Container(
//           decoration: const BoxDecoration(color: Colors.white),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

// class _TicketPainter extends CustomPainter {
//   final Color accentColor;
//   _TicketPainter({required this.accentColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawRRect(
//       RRect.fromLTRBR(0, 0, 5, size.height, const Radius.circular(3)),
//       Paint()..color = accentColor,
//     );
//   }

//   @override
//   bool shouldRepaint(_TicketPainter old) => old.accentColor != accentColor;
// }

// class _TicketClipper extends CustomClipper<Path> {
//   static const double _notchR = 12.0;
//   static const double _notchY = 168.0;

//   @override
//   Path getClip(Size size) {
//     const r = 16.0;
//     return Path()
//       ..moveTo(r, 0)
//       ..lineTo(size.width - r, 0)
//       ..arcToPoint(Offset(size.width, r),
//           radius: const Radius.circular(r), clockwise: true)
//       ..lineTo(size.width, _notchY - _notchR)
//       ..arcToPoint(Offset(size.width, _notchY + _notchR),
//           radius: const Radius.circular(_notchR), clockwise: false)
//       ..lineTo(size.width, size.height - r)
//       ..arcToPoint(Offset(size.width - r, size.height),
//           radius: const Radius.circular(r), clockwise: true)
//       ..lineTo(r, size.height)
//       ..arcToPoint(Offset(0, size.height - r),
//           radius: const Radius.circular(r), clockwise: true)
//       ..lineTo(0, _notchY + _notchR)
//       ..arcToPoint(Offset(0, _notchY - _notchR),
//           radius: const Radius.circular(_notchR), clockwise: false)
//       ..lineTo(0, r)
//       ..arcToPoint(Offset(r, 0),
//           radius: const Radius.circular(r), clockwise: true)
//       ..close();
//   }

//   @override
//   bool shouldReclip(_TicketClipper old) => false;
// }

// // ══════════════════════════════════════════
// //  DOTTED DIVIDER
// // ══════════════════════════════════════════
// class _DottedDivider extends StatelessWidget {
//   final Color color;
//   const _DottedDivider({required this.color});

//   @override
//   Widget build(BuildContext context) => CustomPaint(
//         size: const Size(double.infinity, 1),
//         painter: _DottedLinePainter(color: color),
//       );
// }

// class _DottedLinePainter extends CustomPainter {
//   final Color color;
//   _DottedLinePainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color.withOpacity(0.35)
//       ..strokeWidth = 1.5;
//     const dashW = 6.0, gap = 4.0;
//     double x = 20;
//     while (x < size.width - 20) {
//       canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
//       x += dashW + gap;
//     }
//   }

//   @override
//   bool shouldRepaint(_DottedLinePainter old) => old.color != color;
// }

// // ══════════════════════════════════════════
// //  PILL BADGE
// // ══════════════════════════════════════════
// class _Pill extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Pill({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) => Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               color: color),
//         ),
//       );
// }

// // ══════════════════════════════════════════
// //  STATES
// // ══════════════════════════════════════════
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();

//   @override
//   Widget build(BuildContext context) => const Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           CircularProgressIndicator(strokeWidth: 2.5),
//           SizedBox(height: 16),
//           Text('Fetching coupons…',
//               style:
//                   TextStyle(color: Color(0xFF888888), fontSize: 14)),
//         ]),
//       );
// }

// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry; // ✅ correct type
//   const _ErrorView({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child:
//               Column(mainAxisSize: MainAxisSize.min, children: [
//             const Icon(Icons.wifi_off_rounded,
//                 size: 52, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     color: Color(0xFF666666), fontSize: 14)),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: onRetry, // ✅ just pass it directly
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A1A1A),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 28, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ]),
//         ),
//       );
// }

// class _EmptyView extends StatelessWidget {
//   const _EmptyView();

//   @override
//   Widget build(BuildContext context) => const Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Icon(Icons.local_offer_outlined,
//               size: 52, color: Colors.grey),
//           SizedBox(height: 12),
//           Text('No active coupons right now.',
//               style: TextStyle(
//                   color: Color(0xFF888888), fontSize: 15)),
//         ]),
//       );
// }





















// ─────────────────────────────────────────
//  coupons_screen.dart  (scratch-card edition)
// ─────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/CouponModel/coupon_model.dart';
import 'package:veegify/provider/CouponProvider/coupon_provider.dart';

// ══════════════════════════════════════════
//  SCREEN
// ══════════════════════════════════════════
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() => userId = user.userId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().fetchCoupons(userId ?? '');
    });
  }

  void _retry() {
    context.read<CouponProvider>().fetchCoupons(userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: _buildAppBar(),
      body: Consumer<CouponProvider>(
        builder: (context, provider, _) {
          return switch (provider.status) {
            CouponStatus.idle || CouponStatus.loading => const _LoadingView(),
            CouponStatus.error => _ErrorView(
                message: provider.errorMessage,
                onRetry: _retry,
              ),
            CouponStatus.loaded => provider.coupons.isEmpty
                ? const _EmptyView()
                : _CouponList(coupons: provider.coupons),
          };
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return AppBar(
      backgroundColor: const Color(0xFFF5F3EE),
      elevation: 0,
      centerTitle: true,
      title: Text(
        isWebOrTablet ? 'My Coupons' : 'Your Coupons',
        style: TextStyle(
          fontSize: isWebOrTablet ? 28 : 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),
      toolbarHeight: isWebOrTablet ? 80 : 70,
    );
  }
}

// ══════════════════════════════════════════
//  COUPON LIST
// ══════════════════════════════════════════
class _CouponList extends StatelessWidget {
  final List<CouponModel> coupons;
  const _CouponList({required this.coupons});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebOrTablet = screenWidth > 600;
    
    if (isWebOrTablet) {
      // Grid layout for web/tablet
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
        ),
        itemCount: coupons.length,
        itemBuilder: (context, index) => CouponTicket(coupon: coupons[index]),
      );
    } else {
      // List layout for mobile
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: coupons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => CouponTicket(coupon: coupons[index]),
      );
    }
  }
}

// ══════════════════════════════════════════
//  TICKET WIDGET
// ══════════════════════════════════════════
class CouponTicket extends StatelessWidget {
  final CouponModel coupon;

  const CouponTicket({super.key, required this.coupon});

  static const List<Color> _palette = [
    Color(0xFF4CAF82),
    Color(0xFFE8705A),
    Color(0xFF5B8FD4),
    Color(0xFFF0A500),
    Color(0xFF9B5DE5),
  ];

  Color _accentColor() => _palette[
      coupon.couponCode.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final dateFormat = DateFormat('dd MMM yyyy');
    final expired = coupon.isExpired;
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;

    return Opacity(
      opacity: expired ? 0.55 : 1.0,
      child: _TicketShape(
        accentColor: accent,
        child: Column(
          children: [
            // ── Top section ─────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWebOrTablet ? 24 : 20,
                isWebOrTablet ? 24 : 20,
                isWebOrTablet ? 24 : 20,
                16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isWebOrTablet ? 84 : 72,
                    height: isWebOrTablet ? 84 : 72,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(isWebOrTablet ? 18 : 16),
                    ),
                    child: Center(
                      child: Text(
                        coupon.discountType == 'percentage'
                            ? '${coupon.discountValue.toStringAsFixed(0)}%'
                            : '₹${coupon.discountValue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isWebOrTablet ? 24 : 20,
                          fontWeight: FontWeight.w900,
                          color: accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: TextStyle(
                            fontSize: isWebOrTablet ? 20 : 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon.description,
                          style: TextStyle(
                            fontSize: isWebOrTablet ? 14 : 13,
                            color: const Color(0xFF666666),
                          ),
                          maxLines: isWebOrTablet ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Pill(
                              label: 'Max ₹${coupon.maxDiscountAmount.toInt()}',
                              color: accent,
                              isWebOrTablet: isWebOrTablet,
                            ),
                            _Pill(
                              label: 'Min ₹${coupon.minOrderAmount.toInt()}',
                              color: const Color(0xFF999999),
                              isWebOrTablet: isWebOrTablet,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (expired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EXPIRED',
                        style: TextStyle(
                          fontSize: isWebOrTablet ? 11 : 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Dotted divider ───────────────────
            _DottedDivider(color: accent),

            // ── Bottom: scratch card section ─────
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWebOrTablet ? 24 : 20,
                14,
                isWebOrTablet ? 24 : 20,
                isWebOrTablet ? 24 : 18,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'USE CODE',
                          style: TextStyle(
                            fontSize: isWebOrTablet ? 11 : 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFAAAAAA),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ScratchCard(
                          couponCode: coupon.couponCode,
                          accentColor: accent,
                          isWebOrTablet: isWebOrTablet,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'VALID TILL',
                        style: TextStyle(
                          fontSize: isWebOrTablet ? 11 : 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFAAAAAA),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(coupon.endDate),
                        style: TextStyle(
                          fontSize: isWebOrTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF444444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  SCRATCH CARD
// ══════════════════════════════════════════
class ScratchCard extends StatefulWidget {
  final String couponCode;
  final Color accentColor;
  final bool isWebOrTablet;

  const ScratchCard({
    super.key,
    required this.couponCode,
    required this.accentColor,
    this.isWebOrTablet = false,
  });

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard>
    with TickerProviderStateMixin {
  final List<Offset> _scratchPoints = [];
  double _scratchPercent = 0.0;
  bool _revealed = false;
  bool _fullyRevealed = false;

  late AnimationController _confettiCtrl;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();

  static const double _revealThreshold = 0.55;
  late double _cardW;
  late double _cardH;
  late double _brushR;

  @override
  void initState() {
    super.initState();
    
    // Set dimensions based on platform
    _cardW = widget.isWebOrTablet ? 220.0 : 160.0;
    _cardH = widget.isWebOrTablet ? 52.0 : 44.0;
    _brushR = widget.isWebOrTablet ? 24.0 : 18.0;

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.18)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.18, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
    ]).animate(_scaleCtrl);

    _confettiCtrl.addListener(() => setState(() {}));
    _scaleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_fullyRevealed) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    setState(() {
      _scratchPoints.add(local);
      _scratchPercent = _calculateScratchPercent();
      if (_scratchPercent >= _revealThreshold && !_revealed) {
        _revealCode();
      }
    });
  }

  double _calculateScratchPercent() {
    if (_scratchPoints.isEmpty) return 0;
    const gridSize = 8;
    final cols = (_cardW / gridSize).ceil();
    final rows = (_cardH / gridSize).ceil();
    final total = cols * rows;
    final covered = <String>{};
    for (final p in _scratchPoints) {
      final minC = ((p.dx - _brushR) / gridSize).floor().clamp(0, cols - 1);
      final maxC = ((p.dx + _brushR) / gridSize).ceil().clamp(0, cols);
      final minR = ((p.dy - _brushR) / gridSize).floor().clamp(0, rows - 1);
      final maxR = ((p.dy + _brushR) / gridSize).ceil().clamp(0, rows);
      for (var c = minC; c < maxC; c++) {
        for (var r = minR; r < maxR; r++) {
          covered.add('$c,$r');
        }
      }
    }
    return covered.length / total;
  }

  void _revealCode() {
    _revealed = true;
    _particles.clear();
    for (var i = 0; i < (widget.isWebOrTablet ? 40 : 28); i++) {
      _particles.add(_Particle(
        color: _particleColors[_rng.nextInt(_particleColors.length)],
        angle: _rng.nextDouble() * 2 * math.pi,
        speed: 60 + _rng.nextDouble() * 100,
        size: widget.isWebOrTablet ? 5 + _rng.nextDouble() * 6 : 4 + _rng.nextDouble() * 5,
        startX: _cardW / 2 + (_rng.nextDouble() - 0.5) * _cardW * 0.8,
        startY: _cardH / 2,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
      ));
    }
    _confettiCtrl.forward(from: 0);
    _scaleCtrl.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _fullyRevealed = true);
    });
  }

  static const _particleColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFF922B),
    Color(0xFFCC5DE8),
    Color(0xFFFF6EB4),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      child: SizedBox(
        width: _cardW,
        height: _cardH + 30,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Revealed code (always underneath) ──
            Positioned(
              top: 15,
              left: 0,
              width: _cardW,
              height: _cardH,
              child: ScaleTransition(
                scale: _revealed
                    ? _scaleAnim
                    : const AlwaysStoppedAnimation(1),
                child: _CodeChip(
                  code: widget.couponCode,
                  accentColor: widget.accentColor,
                  isWebOrTablet: widget.isWebOrTablet,
                ),
              ),
            ),

            // ── Scratch overlay (foil) ───────────
            if (!_fullyRevealed)
              Positioned(
                top: 15,
                left: 0,
                width: _cardW,
                height: _cardH,
                child: CustomPaint(
                  painter: _ScratchPainter(
                    points: _scratchPoints,
                    brushRadius: _brushR,
                    accentColor: widget.accentColor,
                    cardWidth: _cardW,
                    cardHeight: _cardH,
                  ),
                  // size: const Size(_cardW, _cardH),
                ),
              ),

            // ── Hint label ───────────────────────
            if (_scratchPoints.isEmpty && !_fullyRevealed)
              Positioned(
                top: 15,
                left: 0,
                width: _cardW,
                height: _cardH,
                child: IgnorePointer(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.back_hand_outlined,
                            size: widget.isWebOrTablet ? 16 : 13,
                            color: Colors.white.withOpacity(0.85)),
                        const SizedBox(width: 5),
                        Text(
                          widget.isWebOrTablet ? 'Scratch to reveal' : 'Scratch me!',
                          style: TextStyle(
                            fontSize: widget.isWebOrTablet ? 13 : 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Confetti particles ───────────────
            if (_revealed && _confettiCtrl.isAnimating)
              ..._particles.map((p) {
                final t = _confettiCtrl.value;
                final x = p.startX + math.cos(p.angle) * p.speed * t;
                final y = p.startY -
                    math.sin(p.angle).abs() * p.speed * t +
                    0.5 * 300 * t * t;
                final opacity = (1 - t).clamp(0.0, 1.0);
                final rotation = p.rotationSpeed * t * math.pi;
                return Positioned(
                  left: x - p.size / 2,
                  top: y - p.size / 2 + 15,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Container(
                        width: p.size,
                        height: p.size * 0.6,
                        decoration: BoxDecoration(
                          color: p.color,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ── Particle ─────────────────────────────
class _Particle {
  final Color color;
  final double angle;
  final double speed;
  final double size;
  final double startX;
  final double startY;
  final double rotationSpeed;

  const _Particle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
    required this.startX,
    required this.startY,
    required this.rotationSpeed,
  });
}

// ── Scratch painter ──────────────────────
class _ScratchPainter extends CustomPainter {
  final List<Offset> points;
  final double brushRadius;
  final Color accentColor;
  final double cardWidth;
  final double cardHeight;

  const _ScratchPainter({
    required this.points,
    required this.brushRadius,
    required this.accentColor,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    final foilPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          accentColor.withOpacity(0.90),
          accentColor
              .withRed((accentColor.red + 40).clamp(0, 255))
              .withOpacity(0.95),
          accentColor
              .withBlue((accentColor.blue + 30).clamp(0, 255))
              .withOpacity(0.85),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.saveLayer(rect, Paint());
    canvas.drawRRect(rrect, foilPaint);

    if (points.isNotEmpty) {
      final erasePaint = Paint()
        ..blendMode = BlendMode.dstOut
        ..style = PaintingStyle.fill;

      for (final p in points) {
        canvas.drawCircle(p, brushRadius, erasePaint);
      }

      final pathPaint = Paint()
        ..blendMode = BlendMode.dstOut
        ..style = PaintingStyle.stroke
        ..strokeWidth = brushRadius * 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()
        ..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        if ((curr - prev).distance < brushRadius * 3) {
          path.lineTo(curr.dx, curr.dy);
        } else {
          path.moveTo(curr.dx, curr.dy);
        }
      }
      canvas.drawPath(path, pathPaint);
    }

    canvas.restore();

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ScratchPainter old) =>
      old.points.length != points.length;
}

// ── Revealed code chip ───────────────────
class _CodeChip extends StatelessWidget {
  final String code;
  final Color accentColor;
  final bool isWebOrTablet;

  const _CodeChip({
    required this.code,
    required this.accentColor,
    this.isWebOrTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('$code copied! 🎉'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
      },
      child: Container(
        height: isWebOrTablet ? 52 : 44,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: TextStyle(
                fontSize: isWebOrTablet ? 18 : 15,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.copy_rounded,
              size: isWebOrTablet ? 18 : 14,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  TICKET SHAPE
// ══════════════════════════════════════════
class _TicketShape extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const _TicketShape({required this.child, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TicketPainter(accentColor: accentColor),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: child,
        ),
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  final Color accentColor;
  _TicketPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 5, size.height, const Radius.circular(3)),
      Paint()..color = accentColor,
    );
  }

  @override
  bool shouldRepaint(_TicketPainter old) => old.accentColor != accentColor;
}

class _TicketClipper extends CustomClipper<Path> {
  static const double _notchR = 12.0;
  static const double _notchY = 168.0;

  @override
  Path getClip(Size size) {
    const r = 16.0;
    return Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(size.width, _notchY - _notchR)
      ..arcToPoint(Offset(size.width, _notchY + _notchR),
          radius: const Radius.circular(_notchR), clockwise: false)
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(0, _notchY + _notchR)
      ..arcToPoint(Offset(0, _notchY - _notchR),
          radius: const Radius.circular(_notchR), clockwise: false)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),
          radius: const Radius.circular(r), clockwise: true)
      ..close();
  }

  @override
  bool shouldReclip(_TicketClipper old) => false;
}

// ══════════════════════════════════════════
//  DOTTED DIVIDER
// ══════════════════════════════════════════
class _DottedDivider extends StatelessWidget {
  final Color color;
  const _DottedDivider({required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DottedLinePainter(color: color),
      );
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.5;
    const dashW = 6.0, gap = 4.0;
    double x = 20;
    while (x < size.width - 20) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter old) => old.color != color;
}

// ══════════════════════════════════════════
//  PILL BADGE
// ══════════════════════════════════════════
class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool isWebOrTablet;

  const _Pill({
    required this.label,
    required this.color,
    this.isWebOrTablet = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWebOrTablet ? 10 : 8,
          vertical: isWebOrTablet ? 4 : 3,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isWebOrTablet ? 12 : 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );
}

// ══════════════════════════════════════════
//  STATES
// ══════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(strokeWidth: 2.5),
        const SizedBox(height: 16),
        Text(
          isWebOrTablet ? 'Fetching your coupons...' : 'Fetching coupons…',
          style: TextStyle(
            color: const Color(0xFF888888),
            fontSize: isWebOrTablet ? 16 : 14,
          ),
        ),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isWebOrTablet ? 48 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: isWebOrTablet ? 72 : 52,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: isWebOrTablet ? 16 : 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isWebOrTablet ? 'Try Again' : 'Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isWebOrTablet ? 36 : 28,
                  vertical: isWebOrTablet ? 18 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: isWebOrTablet ? 72 : 52,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            isWebOrTablet ? 'No active coupons available right now.' : 'No active coupons right now.',
            style: TextStyle(
              color: const Color(0xFF888888),
              fontSize: isWebOrTablet ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}