import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmodersLoading extends StatefulWidget {
  const AmodersLoading({super.key, this.size = 50});

  final double size;

  @override
  State<AmodersLoading> createState() => _AmodersLoadingState();
}

class _AmodersLoadingState extends State<AmodersLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dotCount = 6;
    final radius = widget.size / 2;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(dotCount, (i) {
              final angle = (i / dotCount) * 2 * math.pi;
              final opacity =
                  ((i + _controller.value * dotCount) % dotCount) / dotCount;

              return Transform.translate(
                offset: Offset(
                  radius * 0.8 * math.cos(angle),
                  radius * 0.8 * math.sin(angle),
                ),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 32, 234, 14),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
