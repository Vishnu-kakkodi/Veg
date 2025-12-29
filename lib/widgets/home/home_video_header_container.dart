import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeVideoHeaderContainer extends StatefulWidget {
  final Widget child;
  final String? videoUrl;
  final double height;

  const HomeVideoHeaderContainer({
    super.key,
    required this.child,
    this.videoUrl,
    this.height = 270,
  });

  @override
  State<HomeVideoHeaderContainer> createState() =>
      _HomeVideoHeaderContainerState();
}

class _HomeVideoHeaderContainerState
    extends State<HomeVideoHeaderContainer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  late AnimationController _bgAnimation;

  bool get _hasVideo =>
      widget.videoUrl != null && widget.videoUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    // 🌿 Background animation (fallback)
    _bgAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // 🎥 Video init only if URL exists
    if (_hasVideo) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      )..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _controller!
            ..setLooping(true)
            ..setVolume(0)
            ..play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _bgAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // =====================================================
            // 🎥 VIDEO BACKGROUND (if available)
            // =====================================================
            if (_hasVideo &&
                _controller != null &&
                _controller!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )

            // =====================================================
            // 🌿 FALLBACK BACKGROUND (light green animation)
            // =====================================================
            else
              AnimatedBuilder(
                animation: _bgAnimation,
                builder: (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            const Color(0xFFE6F4EA),
                            const Color(0xFFD0F0C0),
                            _bgAnimation.value,
                          )!,
                          Color.lerp(
                            const Color(0xFFDFF5E1),
                            const Color(0xFFC8EFD4),
                            _bgAnimation.value,
                          )!,
                        ],
                      ),
                    ),
                  );
                },
              ),

            // =====================================================
            // 🌑 OVERLAY FOR READABILITY
            // =====================================================
            Container(
              color: Colors.black.withOpacity(
                _hasVideo ? 0.35 : 0.15,
              ),
            ),

            // =====================================================
            // 🧩 HEADER + SEARCH CONTENT
            // =====================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
