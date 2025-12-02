import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reusable swinging banner widget, like a hanging "Currently CLOSED" board.
/// 
/// Usage:
///   SwingingClosedBanner(), 
/// or customize:
///   SwingingClosedBanner(
///     topText: 'Currently',
///     bottomText: 'OPEN',
///     backgroundColor: Colors.green,
///   );
class SwingingClosedBanner extends StatefulWidget {
  final String topText;
  final String bottomText;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double maxAngle; // in radians (0.3 ≈ 17 degrees)
  final Duration duration;

  const SwingingClosedBanner({
    Key? key,
    this.topText = 'Currently',
    this.bottomText = 'CLOSED',
    this.backgroundColor = const Color(0xFFE46A20), // orange-ish
    this.textColor = Colors.white,
    this.width = 200,
    this.height = 70,
    this.maxAngle = 0.3,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<SwingingClosedBanner> createState() => _SwingingClosedBannerState();
}

class _SwingingClosedBannerState extends State<SwingingClosedBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // continuous swing
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateAngle(double t) {
    // t goes 0 -> 1 (looping). Use sine wave to swing smoothly both sides.
    return math.sin(t * 2 * math.pi) * widget.maxAngle;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      // bit extra height for the pin above
      height: widget.height + 34,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _calculateAngle(_controller.value);

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // Small circle "pin" above the board
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              // Hanging board
              Positioned(
                top: 10,
                child: Transform.rotate(
                  angle: angle,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.topText,
                          style: TextStyle(
                            color: widget.textColor.withOpacity(0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.bottomText,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
