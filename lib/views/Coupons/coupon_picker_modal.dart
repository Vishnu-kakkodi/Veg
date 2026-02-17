// // coupon_picker_modal.dart
// // Self-contained — no provider, no external state.
// // Call showCouponPickerModal(...) from anywhere.

// import 'dart:convert';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// const String _kGetCouponsUrl =
//     'https://api.vegiffyy.com/api/getallactivecoupons';
// const String _kApplyCouponUrl = 'https://api.vegiffyy.com/api/apply-coupon';

// // ─── Entry point ───────────────────────────────────────────────────────────
// // Callback passes back couponId + couponCode so the cart screen
// // stores them locally — zero provider involvement.
// typedef CouponAppliedCallback = void Function({
//   required String couponId,
//   required String couponCode,
// });

// Future<void> showCouponPickerModal({
//   required BuildContext context,
//   required String userId,
//   required CouponAppliedCallback onCouponApplied,
// }) {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => CouponPickerModal(
//       userId: userId,
//       onCouponApplied: onCouponApplied,
//     ),
//   );
// }

// // ─── Internal model ────────────────────────────────────────────────────────
// class _Coupon {
//   final String id;
//   final String code;
//   final String title;
//   final String description;
//   final String discountType;
//   final double discountValue;
//   final double minOrder;
//   final double maxDiscount;
//   final DateTime endDate;

//   const _Coupon({
//     required this.id,
//     required this.code,
//     required this.title,
//     required this.description,
//     required this.discountType,
//     required this.discountValue,
//     required this.minOrder,
//     required this.maxDiscount,
//     required this.endDate,
//   });

//   factory _Coupon.fromJson(Map<String, dynamic> j) => _Coupon(
//         id: j['_id'] as String,
//         code: j['couponCode'] as String,
//         title: j['title'] as String,
//         description: j['description'] as String? ?? '',
//         discountType: j['discountType'] as String,
//         discountValue: (j['discountValue'] as num).toDouble(),
//         minOrder: (j['minOrderAmount'] as num).toDouble(),
//         maxDiscount: (j['maxDiscountAmount'] as num).toDouble(),
//         endDate: DateTime.parse(j['endDate'] as String),
//       );
// }

// // ─── Modal ─────────────────────────────────────────────────────────────────
// class CouponPickerModal extends StatefulWidget {
//   final String userId;
//   final CouponAppliedCallback onCouponApplied;

//   const CouponPickerModal({
//     super.key,
//     required this.userId,
//     required this.onCouponApplied,
//   });

//   @override
//   State<CouponPickerModal> createState() => _CouponPickerModalState();
// }

// class _CouponPickerModalState extends State<CouponPickerModal>
//     with TickerProviderStateMixin {
//   List<_Coupon> _coupons = [];
//   bool _loading = true;
//   String? _error;
//   String? _applyingId;
//   bool _showSuccess = false;

//   late AnimationController _successCtrl;
//   late Animation<double> _successScale;
//   late Animation<double> _successFade;
//   late AnimationController _confettiCtrl;
//   final List<_Particle> _particles = [];
//   final math.Random _rng = math.Random();

//   static const _confettiColors = [
//     Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77),
//     Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFCC5DE8),
//   ];

//   static const _palette = [
//     Color(0xFF4CAF82), Color(0xFFE8705A), Color(0xFF5B8FD4),
//     Color(0xFFF0A500), Color(0xFF9B5DE5),
//   ];

//   Color _accentFor(String code) =>
//       _palette[code.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

//   @override
//   void initState() {
//     super.initState();
//     _successCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 600));
//     _successScale =
//         CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
//     _successFade =
//         CurvedAnimation(parent: _successCtrl, curve: Curves.easeIn);
//     _confettiCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1400))
//       ..addListener(() => setState(() {}));
//     _fetchCoupons();
//   }

//   @override
//   void dispose() {
//     _successCtrl.dispose();
//     _confettiCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchCoupons() async {
//     setState(() { _loading = true; _error = null; });
//     try {
//       final res = await http
//           .get(Uri.parse("$_kGetCouponsUrl/${widget.userId}"))
//           .timeout(const Duration(seconds: 12));
//       if (res.statusCode == 200) {
//         final data = (json.decode(res.body)['data'] as List)
//             .map((e) => _Coupon.fromJson(e as Map<String, dynamic>))
//             .toList();
//         setState(() { _coupons = data; _loading = false; });
//       } else {
//         setState(() { _error = 'HTTP ${res.statusCode}'; _loading = false; });
//       }
//     } catch (e) {
//       setState(() { _error = e.toString(); _loading = false; });
//     }
//   }

//   Future<void> _applyCoupon(_Coupon coupon) async {
//     setState(() => _applyingId = coupon.id);
//     try {
//       final res = await http
//           .post(
//             Uri.parse(_kApplyCouponUrl),
//             headers: {'Content-Type': 'application/json'},
//             body: json.encode({'userId': widget.userId, 'couponId': coupon.id}),
//           )
//           .timeout(const Duration(seconds: 12));

//       if (!mounted) return;

//       if (res.statusCode == 200) {
//         setState(() => _applyingId = null);
//         await _playSuccess();
//         if (mounted) {
//           Navigator.of(context).pop();
//           // Pass id + code back — cart screen stores them locally
//           widget.onCouponApplied(
//             couponId: coupon.id,
//             couponCode: coupon.code,
//           );
//         }
//       } else {
//         final msg = (json.decode(res.body) as Map<String, dynamic>)['message']
//                 as String? ??
//             'Failed to apply coupon';
//         setState(() => _applyingId = null);
//         _snack(msg, Colors.red.shade400);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _applyingId = null);
//       _snack(e.toString(), Colors.red.shade400);
//     }
//   }

//   Future<void> _playSuccess() async {
//     _particles.clear();
//     final cx = MediaQuery.of(context).size.width / 2;
//     for (var i = 0; i < 36; i++) {
//       _particles.add(_Particle(
//         color: _confettiColors[_rng.nextInt(_confettiColors.length)],
//         angle: _rng.nextDouble() * 2 * math.pi,
//         speed: 80 + _rng.nextDouble() * 130,
//         size: 5 + _rng.nextDouble() * 6,
//         startX: cx + (_rng.nextDouble() - 0.5) * 120,
//         startY: 160,
//         rot: (_rng.nextDouble() - 0.5) * 10,
//       ));
//     }
//     setState(() => _showSuccess = true);
//     _successCtrl.forward(from: 0);
//     _confettiCtrl.forward(from: 0);
//     await Future.delayed(const Duration(milliseconds: 1300));
//   }

//   void _snack(String msg, Color color) {
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(SnackBar(
//         content: Text(msg),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // ── Sheet ──────────────────────────────────────────────────────────
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.75,
//             decoration: const BoxDecoration(
//               color: Color(0xFFF5F3EE),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(height: 12),
//                 Container(
//                   width: 42, height: 4,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFCCCCCC),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       const Text(
//                         'Available Coupons',
//                         style: TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.w800,
//                           color: Color(0xFF1A1A1A), letterSpacing: -0.4,
//                         ),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () => Navigator.of(context).pop(),
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE8E6E0),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Icon(Icons.close_rounded,
//                               size: 18, color: Color(0xFF444444)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Tap Apply on any coupon to use it',
//                       style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 Expanded(child: _buildBody()),
//               ],
//             ),
//           ),
//         ),

//         // ── Confetti ───────────────────────────────────────────────────────
//         if (_confettiCtrl.isAnimating)
//           IgnorePointer(
//             child: Stack(
//               children: _particles.map((p) {
//                 final t = _confettiCtrl.value;
//                 final x = p.startX + math.cos(p.angle) * p.speed * t;
//                 final y = p.startY -
//                     math.sin(p.angle).abs() * p.speed * t +
//                     0.5 * 350 * t * t;
//                 return Positioned(
//                   left: x, top: y,
//                   child: Opacity(
//                     opacity: (1.0 - t).clamp(0.0, 1.0),
//                     child: Transform.rotate(
//                       angle: p.rot * t * math.pi,
//                       child: Container(
//                         width: p.size, height: p.size * 0.55,
//                         decoration: BoxDecoration(
//                           color: p.color,
//                           borderRadius: BorderRadius.circular(1),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//         // ── Success badge ──────────────────────────────────────────────────
//         if (_showSuccess)
//           Positioned.fill(
//             child: IgnorePointer(
//               child: Center(
//                 child: FadeTransition(
//                   opacity: _successFade,
//                   child: ScaleTransition(
//                     scale: _successScale,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 36, vertical: 28),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.12),
//                             blurRadius: 24, offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 64, height: 64,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFE8F5EE),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(Icons.check_circle_rounded,
//                                 color: Color(0xFF4CAF82), size: 38),
//                           ),
//                           const SizedBox(height: 14),
//                           const Text('Coupon Applied! 🎉',
//                               style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.w800,
//                                 color: Color(0xFF1A1A1A),
//                               )),
//                           const SizedBox(height: 6),
//                           const Text('Discount added to your cart',
//                               style: TextStyle(
//                                   fontSize: 13, color: Color(0xFF888888))),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildBody() {
//     if (_loading) {
//       return const Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           CircularProgressIndicator(strokeWidth: 2.5),
//           SizedBox(height: 14),
//           Text('Loading coupons…',
//               style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
//         ]),
//       );
//     }
//     if (_error != null) {
//       return Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
//           const SizedBox(height: 12),
//           Text(_error!,
//               style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: _fetchCoupons,
//             icon: const Icon(Icons.refresh_rounded),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1A1A1A),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//           ),
//         ]),
//       );
//     }
//     if (_coupons.isEmpty) {
//       return const Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
//           SizedBox(height: 12),
//           Text('No active coupons available',
//               style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
//         ]),
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
//       itemCount: _coupons.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 14),
//       itemBuilder: (_, i) => _CouponTile(
//         coupon: _coupons[i],
//         accent: _accentFor(_coupons[i].code),
//         isApplying: _applyingId == _coupons[i].id,
//         blockAll: _applyingId != null,
//         onApply: () => _applyCoupon(_coupons[i]),
//       ),
//     );
//   }
// }

// // ─── Ticket tile ───────────────────────────────────────────────────────────
// class _CouponTile extends StatelessWidget {
//   final _Coupon coupon;
//   final Color accent;
//   final bool isApplying;
//   final bool blockAll;
//   final VoidCallback onApply;

//   const _CouponTile({
//     required this.coupon,
//     required this.accent,
//     required this.isApplying,
//     required this.blockAll,
//     required this.onApply,
//   });

//   void _copy(BuildContext ctx) {
//     Clipboard.setData(ClipboardData(text: coupon.code));
//     ScaffoldMessenger.of(ctx)
//       ..clearSnackBars()
//       ..showSnackBar(SnackBar(
//         content: Text('${coupon.code} copied!'),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 2),
//       ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final disabled = blockAll && !isApplying;
//     return Opacity(
//       opacity: disabled ? 0.45 : 1.0,
//       child: _TicketShell(
//         accent: accent,
//         child: Column(children: [
//           // Top
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
//             child: Row(children: [
//               Container(
//                 width: 60, height: 60,
//                 decoration: BoxDecoration(
//                   color: accent.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     coupon.discountType == 'percentage'
//                         ? '${coupon.discountValue.toStringAsFixed(0)}%'
//                         : '₹${coupon.discountValue.toStringAsFixed(0)}',
//                     style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w900,
//                       color: accent, letterSpacing: -0.3,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(coupon.title,
//                         style: const TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.w800,
//                             color: Color(0xFF1A1A1A))),
//                     const SizedBox(height: 3),
//                     Text(coupon.description,
//                         style: const TextStyle(
//                             fontSize: 12, color: Color(0xFF888888))),
//                     const SizedBox(height: 6),
//                     Wrap(spacing: 6, children: [
//                       _Pill('Max ₹${coupon.maxDiscount.toInt()}', accent),
//                       _Pill('Min ₹${coupon.minOrder.toInt()}',
//                           const Color(0xFF999999)),
//                     ]),
//                   ],
//                 ),
//               ),
//             ]),
//           ),
//           // Dotted divider
//           _DottedLine(color: accent),
//           // Bottom
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
//             child: Row(children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('CODE',
//                         style: TextStyle(
//                             fontSize: 9, fontWeight: FontWeight.w600,
//                             color: Color(0xFFAAAAAA), letterSpacing: 1.4)),
//                     const SizedBox(height: 4),
//                     GestureDetector(
//                       onTap: () => _copy(context),
//                       child: Row(children: [
//                         Text(coupon.code,
//                             style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.w900,
//                               color: accent, letterSpacing: 2,
//                             )),
//                         const SizedBox(width: 5),
//                         Icon(Icons.copy_rounded, size: 13, color: accent),
//                       ]),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 36,
//                 child: ElevatedButton(
//                   onPressed: disabled || isApplying ? null : onApply,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accent,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: accent.withOpacity(0.3),
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                     elevation: 0,
//                   ),
//                   child: isApplying
//                       ? const SizedBox(
//                           width: 16, height: 16,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white))
//                       : const Text('Apply',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w700, fontSize: 13)),
//                 ),
//               ),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // ─── Ticket shell with notches ─────────────────────────────────────────────
// class _TicketShell extends StatelessWidget {
//   final Widget child;
//   final Color accent;
//   const _TicketShell({required this.child, required this.accent});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _StripePainter(accent),
//       child: ClipPath(
//         clipper: _TicketClipper(),
//         child: Container(color: Colors.white, child: child),
//       ),
//     );
//   }
// }

// class _StripePainter extends CustomPainter {
//   final Color color;
//   _StripePainter(this.color);
//   @override
//   void paint(Canvas canvas, Size size) => canvas.drawRRect(
//       RRect.fromLTRBR(0, 0, 5, size.height, const Radius.circular(3)),
//       Paint()..color = color);
//   @override
//   bool shouldRepaint(_StripePainter o) => o.color != color;
// }

// class _TicketClipper extends CustomClipper<Path> {
//   static const _nr = 11.0;
//   static const _ny = 112.0;
//   @override
//   Path getClip(Size s) {
//     const r = 14.0;
//     return Path()
//       ..moveTo(r, 0)
//       ..lineTo(s.width - r, 0)
//       ..arcToPoint(Offset(s.width, r),
//           radius: const Radius.circular(r), clockwise: true)
//       ..lineTo(s.width, _ny - _nr)
//       ..arcToPoint(Offset(s.width, _ny + _nr),
//           radius: const Radius.circular(_nr), clockwise: false)
//       ..lineTo(s.width, s.height - r)
//       ..arcToPoint(Offset(s.width - r, s.height),
//           radius: const Radius.circular(r), clockwise: true)
//       ..lineTo(r, s.height)
//       ..arcToPoint(Offset(0, s.height - r),
//           radius: const Radius.circular(r), clockwise: true)
//       ..lineTo(0, _ny + _nr)
//       ..arcToPoint(Offset(0, _ny - _nr),
//           radius: const Radius.circular(_nr), clockwise: false)
//       ..lineTo(0, r)
//       ..arcToPoint(Offset(r, 0),
//           radius: const Radius.circular(r), clockwise: true)
//       ..close();
//   }
//   @override
//   bool shouldReclip(_TicketClipper o) => false;
// }

// // ─── Dotted line ───────────────────────────────────────────────────────────
// class _DottedLine extends StatelessWidget {
//   final Color color;
//   const _DottedLine({required this.color});
//   @override
//   Widget build(BuildContext context) => CustomPaint(
//       size: const Size(double.infinity, 1),
//       painter: _DotPainter(color));
// }

// class _DotPainter extends CustomPainter {
//   final Color color;
//   _DotPainter(this.color);
//   @override
//   void paint(Canvas canvas, Size size) {
//     final p = Paint()..color = color.withOpacity(0.3)..strokeWidth = 1.5;
//     double x = 16;
//     while (x < size.width - 16) {
//       canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), p);
//       x += 10;
//     }
//   }
//   @override
//   bool shouldRepaint(_DotPainter o) => o.color != color;
// }

// // ─── Pill ──────────────────────────────────────────────────────────────────
// class _Pill extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Pill(this.label, this.color);
//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(label,
//             style: TextStyle(
//                 fontSize: 9, fontWeight: FontWeight.w600, color: color)),
//       );
// }

// // ─── Confetti particle ─────────────────────────────────────────────────────
// class _Particle {
//   final Color color;
//   final double angle, speed, size, startX, startY, rot;
//   const _Particle({
//     required this.color, required this.angle, required this.speed,
//     required this.size, required this.startX, required this.startY,
//     required this.rot,
//   });
// }























// coupon_picker_modal.dart
// Self-contained — no provider, no external state.
// Call showCouponPickerModal(...) from anywhere.

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const String _kGetCouponsUrl =
    'https://api.vegiffyy.com/api/getallactivecoupons';
const String _kApplyCouponUrl = 'https://api.vegiffyy.com/api/apply-coupon';

// ─── Entry point ───────────────────────────────────────────────────────────
// Callback passes back couponId + couponCode so the cart screen
// stores them locally — zero provider involvement.
typedef CouponAppliedCallback = void Function({
  required String couponId,
  required String couponCode,
});

Future<void> showCouponPickerModal({
  required BuildContext context,
  required String userId,
  required CouponAppliedCallback onCouponApplied,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CouponPickerModal(
      userId: userId,
      onCouponApplied: onCouponApplied,
    ),
  );
}

// ─── Internal model ────────────────────────────────────────────────────────
class _Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final double minOrder;
  final double maxDiscount;
  final DateTime endDate;
  final bool isApplied; // Added isApplied field

  const _Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrder,
    required this.maxDiscount,
    required this.endDate,
    required this.isApplied, // Added isApplied field
  });

  factory _Coupon.fromJson(Map<String, dynamic> j) => _Coupon(
        id: j['_id'] as String,
        code: j['couponCode'] as String,
        title: j['title'] as String,
        description: j['description'] as String? ?? '',
        discountType: j['discountType'] as String,
        discountValue: (j['discountValue'] as num).toDouble(),
        minOrder: (j['minOrderAmount'] as num).toDouble(),
        maxDiscount: (j['maxDiscountAmount'] as num).toDouble(),
        endDate: DateTime.parse(j['endDate'] as String),
        isApplied: j['isApplied'] as bool? ?? false, // Parse isApplied field
      );
}

// ─── Modal ─────────────────────────────────────────────────────────────────
class CouponPickerModal extends StatefulWidget {
  final String userId;
  final CouponAppliedCallback onCouponApplied;

  const CouponPickerModal({
    super.key,
    required this.userId,
    required this.onCouponApplied,
  });

  @override
  State<CouponPickerModal> createState() => _CouponPickerModalState();
}

class _CouponPickerModalState extends State<CouponPickerModal>
    with TickerProviderStateMixin {
  List<_Coupon> _coupons = [];
  bool _loading = true;
  String? _error;
  String? _applyingId;
  bool _showSuccess = false;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;
  late Animation<double> _successFade;
  late AnimationController _confettiCtrl;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();

  static const _confettiColors = [
    Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77),
    Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFCC5DE8),
  ];

  static const _palette = [
    Color(0xFF4CAF82), Color(0xFFE8705A), Color(0xFF5B8FD4),
    Color(0xFFF0A500), Color(0xFF9B5DE5),
  ];

  Color _accentFor(String code) =>
      _palette[code.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successScale =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
    _successFade =
        CurvedAnimation(parent: _successCtrl, curve: Curves.easeIn);
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..addListener(() => setState(() {}));
    _fetchCoupons();
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCoupons() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http
          .get(Uri.parse("$_kGetCouponsUrl/${widget.userId}"))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final List<dynamic> dataList = json.decode(res.body)['data'] as List;
        final allCoupons = dataList
            .map((e) => _Coupon.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // Filter out coupons where isApplied is true
        final availableCoupons = allCoupons.where((coupon) => !coupon.isApplied).toList();
        
        setState(() { 
          _coupons = availableCoupons; 
          _loading = false; 
        });
      } else {
        setState(() { _error = 'HTTP ${res.statusCode}'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _applyCoupon(_Coupon coupon) async {
    setState(() => _applyingId = coupon.id);
    try {
      final res = await http
          .post(
            Uri.parse(_kApplyCouponUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'userId': widget.userId, 'couponId': coupon.id}),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() => _applyingId = null);
        await _playSuccess();
        if (mounted) {
          Navigator.of(context).pop();
          // Pass id + code back — cart screen stores them locally
          widget.onCouponApplied(
            couponId: coupon.id,
            couponCode: coupon.code,
          );
        }
      } else {
        final msg = (json.decode(res.body) as Map<String, dynamic>)['message']
                as String? ??
            'Failed to apply coupon';
        setState(() => _applyingId = null);
        _snack(msg, Colors.red.shade400);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _applyingId = null);
      _snack(e.toString(), Colors.red.shade400);
    }
  }

  Future<void> _playSuccess() async {
    _particles.clear();
    final cx = MediaQuery.of(context).size.width / 2;
    for (var i = 0; i < 36; i++) {
      _particles.add(_Particle(
        color: _confettiColors[_rng.nextInt(_confettiColors.length)],
        angle: _rng.nextDouble() * 2 * math.pi,
        speed: 80 + _rng.nextDouble() * 130,
        size: 5 + _rng.nextDouble() * 6,
        startX: cx + (_rng.nextDouble() - 0.5) * 120,
        startY: 160,
        rot: (_rng.nextDouble() - 0.5) * 10,
      ));
    }
    setState(() => _showSuccess = true);
    _successCtrl.forward(from: 0);
    _confettiCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1300));
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Sheet ──────────────────────────────────────────────────────────
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3EE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Available Coupons',
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A), letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E6E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: Color(0xFF444444)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tap Apply on any coupon to use it',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),

        // ── Confetti ───────────────────────────────────────────────────────
        if (_confettiCtrl.isAnimating)
          IgnorePointer(
            child: Stack(
              children: _particles.map((p) {
                final t = _confettiCtrl.value;
                final x = p.startX + math.cos(p.angle) * p.speed * t;
                final y = p.startY -
                    math.sin(p.angle).abs() * p.speed * t +
                    0.5 * 350 * t * t;
                return Positioned(
                  left: x, top: y,
                  child: Opacity(
                    opacity: (1.0 - t).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: p.rot * t * math.pi,
                      child: Container(
                        width: p.size, height: p.size * 0.55,
                        decoration: BoxDecoration(
                          color: p.color,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // ── Success badge ──────────────────────────────────────────────────
        if (_showSuccess)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: FadeTransition(
                  opacity: _successFade,
                  child: ScaleTransition(
                    scale: _successScale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 24, offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5EE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF4CAF82), size: 38),
                          ),
                          const SizedBox(height: 14),
                          const Text('Coupon Applied! 🎉',
                              style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              )),
                          const SizedBox(height: 6),
                          const Text('Discount added to your cart',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF888888))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(strokeWidth: 2.5),
          SizedBox(height: 14),
          Text('Loading coupons…',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
        ]),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchCoupons,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      );
    }
    if (_coupons.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No active coupons available',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: _coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _CouponTile(
        coupon: _coupons[i],
        accent: _accentFor(_coupons[i].code),
        isApplying: _applyingId == _coupons[i].id,
        blockAll: _applyingId != null,
        onApply: () => _applyCoupon(_coupons[i]),
      ),
    );
  }
}

// ─── Ticket tile ───────────────────────────────────────────────────────────
class _CouponTile extends StatelessWidget {
  final _Coupon coupon;
  final Color accent;
  final bool isApplying;
  final bool blockAll;
  final VoidCallback onApply;

  const _CouponTile({
    required this.coupon,
    required this.accent,
    required this.isApplying,
    required this.blockAll,
    required this.onApply,
  });

  void _copy(BuildContext ctx) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    ScaffoldMessenger.of(ctx)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('${coupon.code} copied!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final disabled = blockAll && !isApplying;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: _TicketShell(
        accent: accent,
        child: Column(children: [
          // Top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    coupon.discountType == 'percentage'
                        ? '${coupon.discountValue.toStringAsFixed(0)}%'
                        : '₹${coupon.discountValue.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900,
                      color: accent, letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coupon.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 3),
                    Text(coupon.description,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888))),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: [
                      _Pill('Max ₹${coupon.maxDiscount.toInt()}', accent),
                      _Pill('Min ₹${coupon.minOrder.toInt()}',
                          const Color(0xFF999999)),
                    ]),
                  ],
                ),
              ),
            ]),
          ),
          // Dotted divider
          _DottedLine(color: accent),
          // Bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CODE',
                        style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w600,
                            color: Color(0xFFAAAAAA), letterSpacing: 1.4)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _copy(context),
                      child: Row(children: [
                        Text(coupon.code,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900,
                              color: accent, letterSpacing: 2,
                            )),
                        const SizedBox(width: 5),
                        Icon(Icons.copy_rounded, size: 13, color: accent),
                      ]),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: disabled || isApplying ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: isApplying
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Apply',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Ticket shell with notches ─────────────────────────────────────────────
class _TicketShell extends StatelessWidget {
  final Widget child;
  final Color accent;
  const _TicketShell({required this.child, required this.accent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(accent),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: Container(color: Colors.white, child: child),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color color;
  _StripePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 5, size.height, const Radius.circular(3)),
      Paint()..color = color);
  @override
  bool shouldRepaint(_StripePainter o) => o.color != color;
}

class _TicketClipper extends CustomClipper<Path> {
  static const _nr = 11.0;
  static const _ny = 112.0;
  @override
  Path getClip(Size s) {
    const r = 14.0;
    return Path()
      ..moveTo(r, 0)
      ..lineTo(s.width - r, 0)
      ..arcToPoint(Offset(s.width, r),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(s.width, _ny - _nr)
      ..arcToPoint(Offset(s.width, _ny + _nr),
          radius: const Radius.circular(_nr), clockwise: false)
      ..lineTo(s.width, s.height - r)
      ..arcToPoint(Offset(s.width - r, s.height),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(r, s.height)
      ..arcToPoint(Offset(0, s.height - r),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(0, _ny + _nr)
      ..arcToPoint(Offset(0, _ny - _nr),
          radius: const Radius.circular(_nr), clockwise: false)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),
          radius: const Radius.circular(r), clockwise: true)
      ..close();
  }
  @override
  bool shouldReclip(_TicketClipper o) => false;
}

// ─── Dotted line ───────────────────────────────────────────────────────────
class _DottedLine extends StatelessWidget {
  final Color color;
  const _DottedLine({required this.color});
  @override
  Widget build(BuildContext context) => CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DotPainter(color));
}

class _DotPainter extends CustomPainter {
  final Color color;
  _DotPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.3)..strokeWidth = 1.5;
    double x = 16;
    while (x < size.width - 16) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), p);
      x += 10;
    }
  }
  @override
  bool shouldRepaint(_DotPainter o) => o.color != color;
}

// ─── Pill ──────────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600, color: color)),
      );
}

// ─── Confetti particle ─────────────────────────────────────────────────────
class _Particle {
  final Color color;
  final double angle, speed, size, startX, startY, rot;
  const _Particle({
    required this.color, required this.angle, required this.speed,
    required this.size, required this.startX, required this.startY,
    required this.rot,
  });
}