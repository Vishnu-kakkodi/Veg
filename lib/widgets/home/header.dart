
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/views/Notification/notification.dart';
// import 'package:veegify/views/NotificationScreen/notification_screen.dart';

// class HomeHeader extends StatelessWidget {
//   final String userId;
//   final VoidCallback onLocationTap;

//   const HomeHeader({
//     super.key,
//     required this.userId,
//     required this.onLocationTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           // Location section (left side)
//           Expanded(
//             child: _buildLocationWidget(context),
//           ),

//           // Notification icon (right side) – enable if needed
//           const SizedBox(width: 12),
//           InkWell(
//             borderRadius: BorderRadius.circular(20),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const NotificationScreen(),
//                 ),
//               );
//             },
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.notifications_none_outlined,
//                 size: 22,
//                 color: theme.colorScheme.onPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationWidget(BuildContext context) {
//     final theme = Theme.of(context);

//     return Consumer<LocationProvider>(
//       builder: (context, provider, _) {
//         return InkWell(
//           borderRadius: BorderRadius.circular(8),
//           onTap: onLocationTap,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.location_on_outlined,
//                 size: 24,
//                 color: const Color.fromARGB(255, 9, 255, 0),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (provider.isLoading)
//                       SizedBox(
//                         width: 14,
//                         height: 14,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: theme.colorScheme.primary,
//                         ),
//                       )
//                     else
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Flexible(
//                                 child: Text(
//                                   _getDisplayAddress(provider.address),
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Icon(
//                                 Icons.keyboard_arrow_down,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             provider.address.isNotEmpty
//                                 ? provider.address
//                                 : "Set location",
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: Colors.white,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   String _getDisplayAddress(String address) {
//     if (address.trim().isEmpty) {
//       return "Set location";
//     }

//     final cleanAddress = address.trim();
//     final parts = cleanAddress.split(',');

//     for (final part in parts) {
//       final trimmed = part.trim();

//       // Skip invalid / non-alphabetic starts
//       if (trimmed.isEmpty || !RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) {
//         continue;
//       }

//       // Skip irrelevant parts
//       final lower = trimmed.toLowerCase();
//       if (lower.contains('plot') ||
//           lower.contains('door') ||
//           lower.contains('building') ||
//           lower.contains('floor')) {
//         continue;
//       }

//       return trimmed;
//     }

//     // Fallback: first non-empty, letter-starting part
//     for (final part in parts) {
//       final trimmed = part.trim();
//       if (trimmed.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) {
//         return trimmed;
//       }
//     }

//     return "Location";
//   }
// }









import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/CouponProvider/coupon_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/views/Coupons/coupons.dart';
import 'package:veegify/views/NotificationScreen/notification_screen.dart';

class HomeHeader extends StatefulWidget {
  final String userId;
  final VoidCallback onLocationTap;

  const HomeHeader({
    super.key,
    required this.userId,
    required this.onLocationTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with TickerProviderStateMixin {
  // ── Pulse ring animation ─────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // ── Wiggle animation ─────────────────────────────────────────────────────
  late AnimationController _wiggleCtrl;
  late Animation<double> _wiggle;

  @override
  void initState() {
    super.initState();

    // Pulse ring — repeats forever
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    // Wiggle — repeats with a pause between each wiggle
    _wiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wiggle = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.12)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 0.12, end: -0.12)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: -0.12, end: 0.08)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: 0.08, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25),
    ]).animate(_wiggleCtrl);

    // Wiggle every 3 seconds
    _startWiggleLoop();
  }

  void _startWiggleLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      await _wiggleCtrl.forward(from: 0);
      if (!mounted) return;
      _wiggleCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _wiggleCtrl.dispose();
    super.dispose();
  }

  void _openCoupons() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CouponsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ── Location (left) ────────────────────────────────────────────
          Expanded(child: _buildLocationWidget(context)),

          const SizedBox(width: 10),

          // ── Animated coupon button (center, only if coupons exist) ─────
          Consumer<CouponProvider>(
            builder: (context, couponProvider, _) {
              final hasActive = couponProvider.coupons
                  .any((c) => c.isActive && !c.isExpired);

              if (!hasActive) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: _openCoupons,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ── Pulse ring ─────────────────────────────────
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Opacity(
                            opacity: _pulseOpacity.value,
                            child: Transform.scale(
                              scale: _pulseScale.value,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Wiggling icon button ────────────────────────
                        AnimatedBuilder(
                          animation: _wiggleCtrl,
                          builder: (_, child) => Transform.rotate(
                            angle: _wiggle.value,
                            child: child,
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_offer_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        // ── "NEW" badge top-right ───────────────────────
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Notification bell (right) ──────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 22,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onLocationTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 24,
                color: Color.fromARGB(255, 9, 255, 0),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isLoading)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _getDisplayAddress(provider.address),
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.address.isNotEmpty
                                ? provider.address
                                : 'Set location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDisplayAddress(String address) {
    if (address.trim().isEmpty) return 'Set location';

    final parts = address.trim().split(',');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty || !RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) continue;
      final lower = trimmed.toLowerCase();
      if (lower.contains('plot') ||
          lower.contains('door') ||
          lower.contains('building') ||
          lower.contains('floor')) continue;
      return trimmed;
    }

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) {
        return trimmed;
      }
    }

    return 'Location';
  }
}